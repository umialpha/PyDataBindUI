#!/usr/bin/env python
"""
Script to trace Python memory allocations when running a Python program.

Usage: python tracemalloc_runner.py /path/to/program [arg1 arg2 ...]
"""
from __future__ import print_function
filename_pattern = "/tmp/tracemalloc-%d-%04d.pickle"  # % (pid, counter)
init_delay = 10
snapshot_delay = 30
nframes = 50

# Cleanup sys.argv and sys.path
import os.path
del sys.argv[0]
if sys.path[0] == os.path.dirname(__file__):
    del sys.path[0]

# The first step is to start tracing memory allocations
import tracemalloc
tracemalloc.start(nframes)

import atexit
import gc
import os
import pickle
import runpy
import signal
import threading
import time

class TakeSnapshot(threading.Thread):
    daemon = True

    def __init__(self):
        threading.Thread.__init__(self)
        self.counter = 1

    def take_snapshot(self):
        filename = (filename_pattern
                    % (os.getpid(), self.counter))
        t0 = time.time()
        print("Write snapshot into %s..." % filename, file=sys.__stderr__)
        gc.collect()
        snapshot = tracemalloc.take_snapshot()
        with open(filename, "wb") as fp:
            # Pickle version 2 can be read by Python 2 and Python 3
            pickle.dump(snapshot, fp, 2)
        snapshot = None
        dt = time.time() - t0
        print("Snapshot written into %s (%.1f sec)" % (filename, dt),
              file=sys.__stderr__)
        self.counter += 1

    def run(self):
        self.take_snapshot()
        if hasattr(signal, 'pthread_sigmask'):
            # Available on UNIX with Python 3.3+
            signal.pthread_sigmask(signal.SIG_BLOCK, range(1, signal.NSIG))
        time.sleep(init_delay)
        while True:
            self.take_snapshot()
            time.sleep(snapshot_delay)

print("Start thread taking snapshots every %.1f seconds" % snapshot_delay)
print("Filename pattern: %s" % filename_pattern)
print("")
print("Run:", sys.path)

thread = TakeSnapshot()
thread.start()
atexit.register(thread.take_snapshot)

runpy.run_path(sys.argv[0])
