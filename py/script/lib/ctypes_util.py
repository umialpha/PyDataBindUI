######################################################################
#  This file should be kept compatible with Python 2.3, see PEP 291. #
######################################################################
import sys, os

# find_library(name) returns the pathname of a library, or None.
if os.name == "nt":
    def find_library(name):
        # See MSDN for the REAL search order.
        for directory in os.environ['PATH'].split(os.pathsep):
            fname = os.path.join(directory, name)
            if os.path.exists(fname):
                return fname
            if fname.lower().endswith(".dll"):
                continue
            fname = fname + ".dll"
            if os.path.exists(fname):
                return fname
        return None

if os.name == "ce":
    # search path according to MSDN:
    # - absolute path specified by filename
    # - The .exe launch directory
    # - the Windows directory
    # - ROM dll files (where are they?)
    # - OEM specified search path: HKLM\Loader\SystemPath
    def find_library(name):
        # Does it make sense to implement this correctly?  For now we
        # fake.
        #
        # The proper solution (also for windows) would be to call
        # LoadLibraryEx(name, NULL, LOAD_LIBRARY_AS_DATAFILE), then
        # get the module name with GetModuleFileName and return that.
        #
        # OTOH, why use find_library on windows at all?
        if not "." in name:
            name += ".dll"
        return os.path.exists(name)

if os.name == "posix" and sys.platform == "darwin":
    from ctypes.macholib.dyld import dyld_find as _dyld_find
    def find_library(name):
        possible = ['lib%s.dylib' % name,
                    '%s.dylib' % name,
                    '%s.framework/%s' % (name, name)]
        for name in possible:
            try:
                return _dyld_find(name)
            except ValueError:
                continue
        return None

elif os.name == "posix":
    # Andreas Degert's find functions, using gcc, /sbin/ldconfig, objdump
    import re, tempfile, errno

    def _findLib_gcc(name):
        expr = '[^\(\)\s]*lib%s\.[^\(\)\s]*' % name
        fdout, ccout = tempfile.mkstemp()
        os.close(fdout)
        cmd = 'if type gcc &>/dev/null; then CC=gcc; else CC=cc; fi;' \
              '$CC -Wl,-t -o ' + ccout + ' 2>&1 -l' + name
        try:
            fdout, outfile =  tempfile.mkstemp()
            os.close(fdout)
            fd = os.popen(cmd)
            trace = fd.read()
            err = fd.close()
        finally:
            try:
                os.unlink(outfile)
            except OSError, e:
                if e.errno != errno.ENOENT:
                    raise
            try:
                os.unlink(ccout)
            except OSError, e:
                if e.errno != errno.ENOENT:
                    raise
        res = re.search(expr, trace)
        if not res:
            return None
        return res.group(0)

    def _findLib_ld(name):
        expr = '/[^\(\)\s]*lib%s\.[^\(\)\s]*' % name
        res = re.search(expr, os.popen('/sbin/ldconfig -p 2>/dev/null').read())
        if not res:
            # Hm, this works only for libs needed by the python executable.
            cmd = 'ldd %s 2>/dev/null' % sys.executable
            res = re.search(expr, os.popen(cmd).read())
            if not res:
                return None
        return res.group(0)

    def _get_soname(f):
        cmd = "objdump -p -j .dynamic 2>/dev/null " + f
        res = re.search(r'\sSONAME\s+([^\s]+)', os.popen(cmd).read())
        if not res:
            return None
        return res.group(1)

    def find_library(name):
        lib = _findLib_ld(name) or _findLib_gcc(name)
        if not lib:
            return None
        return _get_soname(lib)
