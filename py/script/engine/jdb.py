import os, sys
from jrepr import Repr as _Repr
from types import CodeType as _CodeType
import C_debug

S_CURR_POS      = 'c'
S_EXCEPTION     = 'e'
S_GLOBALS       = 'g'
S_CALL_STACK    = 'k'
S_LOCALS        = 'l'
S_MODULES       = 'm'
S_OBJECT        = 'o'
S_WATCH         = 'w'

#TODO: set repr length
#TODO: double click to modify
#TODO: reload
#TODO: ignores/hits
#TODO: bottom stack "run to return" error
#TODO: attribute/property/method
#TODO: last breakpoint stop once

class TDebugger(object):
	def __init__(self):
		self._caches = {}
		self._breaks = {}
		self._arepr = _Repr()
		self._maxargs = 15
		self._arepr.maxother = 40
		self._repr = self._arepr.repr
		
		fn = __file__
		fn = os.path.abspath(fn)
		fn = os.path.normcase(fn)
		
		p = fn.find('jdb.py')
		fn = fn[: p - 1]

		p1 = fn.rfind('/')
		p2 = fn.rfind('\\')
		p = p1 if p1 >= p2 else p2

		self._script_path = fn[: p + 1]
		
	############### public interface #############
	
	def _reset(self):
		self._bottom_frame = None
		self._stop_frame = None
		self._return_frame = None
		self._debugging = True
		self._forget()

	############### debugger utilities ###########

	def _forget(self):
		self._stack = []
		self._curr_index = 0
		self._curr_frame = None

	def _setup(self, frame, traceback):
		self._forget()
		self._stack, self._curr_index = self._get_stack(frame, traceback)
		self._curr_frame = self._stack[self._curr_index][0]
		
	def _response(self, data):
		for index, item in enumerate(data):
			if isinstance(item, str):
			    if index > 0:
					assert len(item) < 256
					data[index] = chr(len(item)) + item
			elif isinstance(item, int):
				int_s = ''
				for i in xrange(4):
					rem = item % 256
					item /= 256
					int_s += chr(rem)
					
				data[index] = int_s
			elif isinstance(item, type):
				s = `item`
				assert len(s) < 256
				data[index] = chr(len(s)) + s
			elif item is None:
				s = `None`
				data[index] = chr(len(s)) + s
			else:
				raise "unknown item type (%d)%s" % (index, str(type(item)))
				
		msg = ''.join(data)
		assert len(msg) < 65536
		C_debug.tell(msg)
		
	############### trace utilities ##############
		
	def trace_dispatch(self, frame, event, args):
		if self._debugging or self._break_somewhere():
			if event == 'call':
				if self._bottom_frame is None:
					self._bottom_frame = frame
				else:
					if not (self._stop_here(frame) or self._break_anywhere(frame)):
						return

				self._user_call(frame, args)
				
			elif event == 'line':
				if self._stop_here(frame) or self._break_here(frame):
					self._user_line(frame)
			
			elif event == 'exception':
				if not self._is_internal_module(args):
					self._debugging = True
					self._user_exception(frame, args)

			elif event == 'return':
				if self._stop_here(frame) or frame == self._return_frame:
					self._user_return(frame, args)

				if frame == self._bottom_frame:
					#print '--------------- End of debug round --------------'
					old_debugging = self._debugging
					try:
						self._reset()
					finally:
						self._debugging = old_debugging

			else:
				raise ValueError, 'Unknown event: %s' % event
				
			if not self._debugging:
				self._process_commands(frame)
		else:
			if event == 'call':
				if self._bottom_frame is None:
					#print 'none call'
					self._bottom_frame = frame
					
			elif event == 'exception':
				if not self._is_internal_module(args):
					self._debugging = True
					self._user_exception(frame, args)
				
			elif event == 'return':
				if frame == self._bottom_frame:
					#print 'none return'
					self._process_commands(frame)

					old_debugging = self._debugging
					try:
						self._reset()
					finally:
						self._debugging = old_debugging
			
		return self.trace_dispatch

	def _set_next(self, frame):
		self._stop_frame = frame
		self._return_frame = None
		self._debugging = True

	def _set_step(self):
		self._stop_frame = None
		self._return_frame = None
		self._debugging = True

	def _set_to_return(self, frame):
		self._stop_frame = frame.f_back
		self._return_frame = frame
		self._debugging = True

	def _set_continue(self):
		self._stop_frame = None
		self._return_frame = None
		self._debugging = False

		frame = sys._getframe().f_back
		while frame is not None and frame != self._bottom_frame:
			del frame.f_trace
			frame = frame.f_back
			if frame == self._bottom_frame:
				break

	def _set_quit(self):
		self._stop_frame = self._bottom_frame
		self._return_frame = None

		self._reset()
		self._debugging = False
		sys.settrace(None)
		
	def _set_break(self, filename, lineno, is_temp):
		bp = TBreakpoint(filename, lineno, is_temp)
		self._breaks[filename, lineno] = bp
		
		#print self._breaks
		
	def _remove_break(self, filename, lineno):
		try:
			del self._breaks[filename, lineno]
		except KeyError:
			pass
			
		#print self._breaks
		
	############### status checking ##############

	def _stop_here(self, frame):
		if not self._debugging:
			return False
			
		if frame == self._stop_frame:
		    return True

		while frame is not None and frame != self._stop_frame:
			if frame == self._bottom_frame:
			    return True
			    
			frame = frame.f_back

		return False
		
	def _break_anywhere(self, frame):
		name = self._norm_filename(frame.f_code.co_filename)
		return len([None for filename, lineno in self._breaks.iterkeys() \
			if filename == name]) > 0

	def _break_somewhere(self):
		return len([None for bp in self._breaks.itervalues() \
			if bp.enabled]) > 0

	def _break_here(self, frame):
		filename = self._norm_filename(frame.f_code.co_filename)
		lineno = frame.f_lineno

		#self._response([S_CURR_POS, lineno, filename])
		#C_debug.test(repr.repr(self._breaks.keys()))

		bp = self._breaks.get((filename, lineno), None)
		if bp is None:
		    return False

		ok = bp.effective(frame)
		if ok and bp.is_temporary():
			self._remove_break(filename, lineno)

		return ok
		
	############### custom interface #############

	def _interaction(self, frame, traceback):
		self._setup(frame, traceback)

		filename, lineno, funccall, result \
			= self._get_status(self._stack[self._curr_index])
		self._response([S_CURR_POS, lineno, filename])
		
		self._being_waited = True
		self._waiting = True
		while self._waiting:
			cmd = C_debug.wait_command()
			if cmd is None:
				return None

			#print 'recv: %s' % repr(cmd)
			
			func = getattr(self, 'do_' + cmd[0])
			if len(cmd) == 1:
				func()
			else:
			    func(cmd[1: ])

		self._forget()
		
	def _process_commands(self, frame):
		while True:
			cmd = C_debug.process_command()
			#print `cmd`
			if cmd is None or cmd == '':
				break
				
			func = getattr(self, 'do_' + cmd[0])
			if len(cmd) == 1:
				func()
			else:
				func(cmd[1: ])
				
			if cmd == 'e':
				break

	def _user_call(self, frame, args):
		if self._stop_here(frame):
			self._interaction(frame, None)

	def _user_line(self, frame):
		self._interaction(frame, None)

	def _user_return(self, frame, result):
		frame.f_locals['__return__'] = result
		self._interaction(frame, None)

	def _user_exception(self, frame, (exc_type, exc_value, exc_traceback)):
		frame.f_locals['__exception__'] = exc_type, exc_value
		if type(exc_type) == type(''):
			exc_type_name = exc_type
		else:
		    exc_type_name = exc_type.__name__

		self._response([S_EXCEPTION, exc_type_name, str(exc_value), \
			self._norm_filename(exc_traceback.tb_frame.f_code.co_filename), \
			exc_traceback.tb_lineno])
		self._interaction(frame, exc_traceback)
			
	############### information archive ##########
	
	def _is_internal_module(self, (exc_type, exc_value, exc_traceback)):
		filename = self._norm_filename(exc_traceback.tb_frame.f_code.co_filename)
		return filename.startswith(self._script_path + 'engine') \
		    or filename.startswith(self._script_path + 'lib')
	
	def _get_stack(self, frame, traceback):
		stack = []
		if traceback is not None and traceback.tb_frame == frame:
			traceback = traceback.tb_next

		while frame is not None:
			stack.append((frame, frame.f_lineno))
			
			if frame == self._bottom_frame:
			    break
			frame = frame.f_back

		stack.reverse()

		i = max(0, len(stack) - 1)

		while traceback is not None:
			stack.append((traceback.tb_frame, traceback.tb_lineno))
			traceback = traceback.tb_next

		return stack, i

	def _get_status(self, stack_item):
		frame, lineno = stack_item
		filename = self._norm_filename(frame.f_code.co_filename)

		if frame.f_code.co_name:
			funcname = frame.f_code.co_name
		else:
			funcname = "<lambda>"

		args = self._get_args(frame)

		if '__return__' in frame.f_locals:
			result = self._repr(frame.f_locals['__return__'])
		else:
			result = ''

		return filename, lineno, funcname + args, result

	def _get_args(self, frame):
		code = frame.f_code
		vars = frame.f_locals
		n = code.co_argcount
		if code.co_flags & 4:
		    n += 1
		if code.co_flags & 8:
		    n += 1

		result = []
		for i in xrange(n):
			name = code.co_varnames[i]

			try:
				value = self._repr(vars[name])
				if len(value) > self._maxargs:
					value = value[: self._maxargs - 3] + '...'
				result.append('%s = %s' % (name, value))
			except KeyError:
				result.append(name)

		return '(%s)' % (', '.join(result))
		
	def _get_type_name(self, obj):
		result = type(obj)
		try:
			result = result.__name__
		except KeyError:
			result = repr(result)
			
		return result
		
	def _get_space(self, space):
		result = []

		keys = space.keys()
		keys.sort(cmp, lambda x: x.lower())
		for key in keys:
			assert isinstance(key, str)
			value = space.get(key)
			result.extend([key, self._get_type_name(value), self._repr(value)])
			
		return result
		
	def _get_dir_dict(self, space):
		return dict([(key, getattr(space, key)) for key in dir(space)])
		
	def _get_sequence(self, seq):
		result = []
		
		for index, value in enumerate(seq):
			result.extend([index, self._get_type_name(value), self._repr(value)])
			
		return result
		
	def _get_dictionary(self, dic):
		result = []
		
		keys = dic.keys()
		keys.sort(cmp, lambda x: self._repr(x).lower())
		for key in keys:
			value = dic.get(key)
			result.extend([self._get_type_name(key), self._repr(key), \
			    self._get_type_name(value), self._repr(value)])
			    
		return result

	def _norm_filename(self, filename):
		if filename.startswith('<') and filename.endswith('>'):
			return filename

		try:
			result = self._caches[filename]
		except KeyError:
			result = os.path.abspath(filename)
			result = os.path.normcase(result)
			self._caches[filename] = result

		return result.lower()
		
	############### debug command ################
	
	def do_n(self):                  # Step over
		self._set_next(self._curr_frame)
		self._waiting = False
		
	def do_t(self):                  # Trace into
		self._set_step()
		self._waiting = False
		
	def do_e(self):                  # Stop debugging
		self._set_quit()
		self._waiting = False
		
	def do_r(self):                  # Run to return
		self._set_to_return(self._curr_frame)
		self._waiting = False
		
	def do_c(self):                  # Continue
		self._set_continue()
		self._waiting = False
		
	def do_k(self, info):            # Call stack
		result = [S_CALL_STACK, info, 0]

		data = []
		for stack_item in reversed(self._stack):
			data.extend(self._get_status(stack_item))
			
		result[-1] = len(data) / 4
		result.extend(data)
		
		self._response(result)
		
	def do_m(self, info):            # Modules
		#print 'show module'
		result = [S_MODULES, info, 0]

		keys = sys.modules.keys()
		keys.sort(cmp, lambda x: self._repr(x).lower())

		data = []
		for item in keys:
			module = sys.modules[item]
			try:
				filename = module.__file__
			except AttributeError:
				filename = `module`
			data.extend([item, self._norm_filename(filename)])

		result[-1] = len(data) / 2
		result.extend(data)
		
		self._response(result)
		
	def _do_space(self, info, is_locals):
		if is_locals:
			cmd = S_LOCALS
			space = self._curr_frame.f_locals
		else:
			cmd = S_GLOBALS
			space = self._curr_frame.f_globals
			
		result = [cmd, info, 0]
		
		data = self._get_space(space)
		result[2] = len(data) / 3
		result.extend(data)
		
		self._response(result)
		
	def do_l(self, info):            # Globals
		self._do_space(info, True)
		
	def do_g(self, info):            # Locals
		self._do_space(info, False)
		
	def do_o(self, info):            # Inspect object
		result = [S_OBJECT, info[: 4], info[4: ], None, None, 0]

		try:
			obj = eval(info[4: ], \
				self._curr_frame.f_globals, self._curr_frame.f_locals)
		except:
			exc_type, exc_value = sys.exc_info()[: 2]
			
			if not isinstance(exc_type, str):
				exc_type = exc_type.__name__
				
			result[-3] = '\0%s\0' % exc_type
			result[-2] = repr(exc_value)
		else:
			result[-3] = self._get_type_name(obj)
			result[-2] = self._repr(obj)
			
			if isinstance(obj, (tuple, list)):
				data = self._get_sequence(obj)
				result[-1] = len(data) / 3
			elif isinstance(obj, dict):
				data = self._get_dictionary(obj)
				result[-1] = len(data) / 4
			else:
				try:
					space = obj.__dict__
				except AttributeError:
					space = self._get_dir_dict(obj)

				data = self._get_space(space)
				result[-1] = len(data) / 3
				
			result.extend(data)
			
		self._response(result)
		
	def do_w(self, info):            # Watch
		result = [S_WATCH, info[: 8]]
		
		info = info[8: ]
		while info != '':
			expr_len = ord(info[0])
			expr = info[1: expr_len + 1]
			info = info[expr_len + 1: ]

			result.append(expr)
			try:
				obj = eval(expr, \
					self._curr_frame.f_globals, self._curr_frame.f_locals)
			except:
				exc_type, exc_value = sys.exc_info()[: 2]

				if not isinstance(exc_type, str):
					exc_type = exc_type.__name__

				result.extend(['\0%s\0' % exc_type, repr(exc_value)])
			else:
				result.extend([self._get_type_name(obj), self._repr(obj)])
			
		self._response(result)
		
	def do_b(self, info):            # Toggle breakpoints
		fl = ord(info[0])
		filename = self._norm_filename(info[1: 1 + fl])
		info = info[1 + fl: ]
		lineno = sum([ord(info[i]) << (i * 8) for i in xrange(4)])
		info = info[4: ]
		is_temp = ord(info[0]) <> 0
		is_remove = ord(info[1]) <> 0
		
		if is_remove:
			self._remove_break(filename, lineno)
		else:
			self._set_break(filename, lineno, is_temp)
			
	def do_p(self, info):            # Breakpoint properties
		fl = ord(info[0])
		filename = info[1: 1 + fl]
		info = info[1 + fl: ]
		lineno = sum([ord(info[i]) << (i * 8) for i in xrange(4)])
		info = info[4: ]
		enabled = ord(info[0]) <> 0
		info = info[1: ]
		cl = ord(info[0])
		condition = info[1: 1 + cl]
		info = info[1 + cl: ]
		hits = sum([ord(info[i]) << (i * 8) for i in xrange(4)])
		
		bp = self._breaks.get((filename, lineno), None)
		if bp is not None:
			bp.enabled = enabled
			bp.condition = condition
			bp.ignores = hits
			
	def do_f(self, info):
		active = ord(info[0])
		C_debug.set_profile_active(active)
			
		
class TBreakpoint(object):
	def __init__(self, filename, lineno, is_temp):
		self._filename = filename
		self._linenoe = lineno
		self._is_temp = is_temp
		self._enabled = True
		self._condition = ''
		self._hits = 0
		self._ignores = 0

	def effective(self, frame):
		if not self._enabled:
		    return False

		self._hits += 1

		if self._condition != '':
			try:
				value = eval(self._condition, frame.f_globals, frame.f_locals)
			except:
				return False
			if not value:
			    return False

		if self._ignores > 0:
			self._ignores -= 1
			return False
		else:
			return True

	def is_temporary(self):
		return self._is_temp

	def _get_enabled(self):
		return self._enabled
	def _set_enabled(self, enabled):
		self._enabled = enabled
	enabled = property(_get_enabled, _set_enabled)
	
	def _get_condition(self):
		return self._condition
	def _set_condition(self, condition):
		self._condition = condition
	condition = property(_get_condition, _set_condition)
	
	def _get_ignores(self):
		return self._ignores
	def _set_ignores(self, ignores):
		self._ignores = ignores
	ignores = property(_get_ignores, _set_ignores)
	

def start():
	global _debugger
	try:
		_debugger
	except NameError:
		_debugger = TDebugger()
		
	_debugger._reset()
	sys.settrace(_debugger.trace_dispatch)
	

def stop():
	sys.settrace(None)
