# -*- coding: utf-8 -*-

"""
A heapq-based scheduler for asyncore.

Author: Giampaolo Rodola' <g.rodola [AT] gmail [DOT] com>
License: MIT
"""

import sys
import time
import heapq
import asyncore
import traceback
import errno

_tasks = []
_cancelled_num = 0

class CallLater(object):
    """Calls a function at a later time.

    It can be used to asynchronously schedule a call within the polling
    loop without blocking it. The instance returned is an object that
    can be used to cancel or reschedule the call.
    """

    def __init__(self, seconds, target, *args, **kwargs):
        """
         - (int) seconds: the number of seconds to wait
         - (obj) target: the callable object to call later
         - args: the arguments to call it with
         - kwargs: the keyword arguments to call it with; a special
           '_errback' parameter can be passed: it is a callable
           called in case target function raises an exception.
        """
        assert callable(target), "%s is not callable" % target
        assert sys.maxint >= seconds >= 0, "%s is not greater than or equal " \
                                           "to 0 seconds" % seconds
        self._delay = seconds
        self._target = target
        self._args = args
        self._kwargs = kwargs
        self._errback = kwargs.pop('_errback', None)
        self._repush = False
        # seconds from the epoch at which to call the function
        self.timeout = time.time() + self._delay
        self.cancelled = False
        self.expired = False
        heapq.heappush(_tasks, self)

    def __le__(self, other):
        return self.timeout <= other.timeout

    def call(self):
        """Call this scheduled function."""
        assert not self.cancelled, "Already cancelled"
        try:
            try:
                self._target(*self._args, **self._kwargs)
            except (KeyboardInterrupt, SystemExit, asyncore.ExitNow):
                raise
            except:
                if self._errback is not None:
                    self._errback()
                else:
                    raise
        finally:
            if not self.cancelled:
                self.expire()
                
    def reset(self):
        """Reschedule this call resetting the current countdown."""
        assert not self.cancelled, "Already cancelled"
        self.timeout = time.time() + self._delay
        self._repush = True

    def delay(self, seconds):
        """Reschedule this call for a later time."""
        assert not self.cancelled, "Already cancelled."
        assert sys.maxint >= seconds >= 0, "%s is not greater than or equal " \
                                           "to 0 seconds" % seconds
        self._delay = seconds
        newtime = time.time() + self._delay
        if newtime > self.timeout:
            self.timeout = newtime
            self._repush = True
        else:
            # XXX - slow, can be improved
            self.timeout = newtime
            heapq.heapify(_tasks)

    def cancel(self):
        """Unschedule this call manully."""
        assert not self.cancelled, "Already cancelled."
        assert not self.expired, "Already expired"
        
        self.cancelled = True
        del self._target, self._args, self._kwargs, self._errback
        
        #if the number of cancelled is too much, remove them
        global _cancelled_num, _tasks
        _cancelled_num += 1
        if _cancelled_num > 10 and float(_cancelled_num)/len(_tasks) > 0.25:
            _remove_cancelled_tasks()
        
    def expire(self):
        """Has been scheduled"""
        assert not self.cancelled, "Already cancelled."
        assert not self.expired, "Already expired"
        self.expired = True
        del self._target, self._args, self._kwargs, self._errback   


class CallEvery(CallLater):
    """Calls a function every x seconds.
    It accepts the same arguments as CallLater and shares the same API.
    """

    def call(self):
        # call this scheduled function and reschedule it right after
        assert not self.cancelled, "Already cancelled"
        exc = False
        try:
            try:
                self._target(*self._args, **self._kwargs)
            except (KeyboardInterrupt, SystemExit, asyncore.ExitNow):
                exc = True
                raise
            except:
                if self._errback is not None:
                    self._errback()
                else:
                    exc = True
                    raise
        finally:
            if not self.cancelled:
                if exc:
                    self.cancel()
                else:
                    self.timeout = time.time() + self._delay
                    heapq.heappush(_tasks, self)

def _remove_cancelled_tasks():
    """Remove cancelled tasks and rebuild heap"""
    global _tasks
    global _cancelled_num
    tmp_tasks = []
    for t in _tasks:
        if not t.cancelled:
            tmp_tasks.append(t)
    _tasks = tmp_tasks
    heapq.heapify(_tasks)
    _cancelled_num = 0

def _scheduler():
    """Run the scheduled functions due to expire soonest (if any)."""
    global _cancelled_num
    now = time.time()
    while _tasks and now >= _tasks[0].timeout:
        call = heapq.heappop(_tasks)
        if call.cancelled:
            _cancelled_num -= 1
            continue
        if call._repush:
            heapq.heappush(_tasks, call)
            call._repush = False
            continue
        try:
            call.call()
        except (KeyboardInterrupt, SystemExit, asyncore.ExitNow):
            raise
        except:
            print traceback.format_exc()

def close_all(map=None, ignore_all=False):
    """Close all scheduled functions and opened sockets."""
    if map is None:
        map = asyncore.socket_map
    for x in map.values():
        try:
            x.close()
        except OSError, x:
            if x[0] == errno.EBADF:
                pass
            elif not ignore_all:
                raise
        except (asyncore.ExitNow, KeyboardInterrupt, SystemExit):
            raise
        except:
            if not ignore_all:
                asyncore.socket_map.clear()
                del _tasks[:]
                raise
    map.clear()

    for x in _tasks:
        try:
            if not x.cancelled and not x.expired:
                x.cancel()
        except (asyncore.ExitNow, KeyboardInterrupt, SystemExit):
            raise
        except:
            if not ignore_all:
                del _tasks[:]
                raise
    del _tasks[:]


def poll(timeout=0.0, map=None):
    if map is None:
        map = asyncore.socket_map
    if map:
        r = []; w = []; e = []
        for fd, obj in map.items():
            is_r = obj.readable()
            is_w = obj.writable()
            if is_r:
                r.append(fd)
            # accepting sockets should not be writable
            if is_w and not obj.accepting:
                w.append(fd)
            if is_r or is_w:
                e.append(fd)
        if [] == r == w == e:
            time.sleep(timeout)
            return

        try:
            r, w, e = asyncore.select.select(r, w, e, timeout)
        except asyncore.select.error, err:
            if err.args[0] != EINTR:
                raise
            else:
                return

        for fd in r:
            obj = map.get(fd)
            if obj is None:
                continue
            read(obj)

        for fd in w:
            obj = map.get(fd)
            if obj is None:
                continue
            write(obj)

        for fd in e:
            obj = map.get(fd)
            if obj is None:
                continue
            _exception(obj)

def poll2(timeout=0.0, map=None):
    # Use the poll() support added to the select module in Python 2.0
    if map is None:
        map = socket_map
    if timeout is not None:
        # timeout is in milliseconds
        timeout = int(timeout*1000)
    pollster = select.poll()
    if map:
        for fd, obj in map.items():
            flags = 0
            if obj.readable():
                flags |= select.POLLIN | select.POLLPRI
            # accepting sockets should not be writable
            if obj.writable() and not obj.accepting:
                flags |= select.POLLOUT
            if flags:
                # Only check for exceptions if object was either readable
                # or writable.
                flags |= select.POLLERR | select.POLLHUP | select.POLLNVAL
                pollster.register(fd, flags)
        try:
            r = pollster.poll(timeout)
        except select.error, err:
            if err.args[0] != EINTR:
                raise
            r = []
        for fd, flags in r:
            obj = map.get(fd)
            if obj is None:
                continue
            readwrite(obj, flags)
            
def loop(timeout=0.1, use_poll=True, map=None, count=None):
    """Start asyncore and scheduler loop.
    Use this as replacement of the original asyncore.loop() function.
    """
    if use_poll and hasattr(asyncore.select, 'poll'):
        poll_fun = asyncore.poll2
    else:
        poll_fun = asyncore.poll
    if map is None:
        map = asyncore.socket_map
    if count is None:
        while (map or _tasks):
            poll_fun(timeout, map)
            _scheduler()
    else:
        while (map or _tasks) and count > 0:
            poll_fun(timeout, map)
            _scheduler()
            count -= 1


if __name__ == '__main__':

    # ==============================================================
    # schedule a function
    # ==============================================================

    def foo():
        print "I'm called after 2.5 seconds"

    CallLater(2.5, foo)
    #loop()


    # ==============================================================
    # call a function every second
    # ==============================================================

    def bar():
        print "I'm called every second"

    CallEvery(1, bar)
    #loop()

    # ==============================================================
    # scheduled functions can be resetted, delayed or cancelled
    # ==============================================================

    fun = CallLater(1, foo)
    fun.reset()
    fun.delay(1.5)
    fun.cancel()

    # ==============================================================
    # example of a basic asyncore client shutting down if
    # server does not reply for more than 3 seconds
    # ==============================================================

    import socket

    class UselessClient(asyncore.dispatcher):

        timeout = 3

        def __init__(self, address):
            asyncore.dispatcher.__init__(self)
            self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
            self.connect(address)
            self.callback = CallLater(self.timeout, self.handle_timeout)

        def handle_timeout(self):
            print "no response from server; disconnecting"
            self.close()

        def handle_connect(self):
            print "connected"

        def writable(self):
            return not self.connected

        def handle_read(self):
            # reset timeout on data received
            self.callback.reset()
            data = self.recv(8192)
            self.in_buffer.append(data)

        def handle_close(self):
            if self.in_buffer:
                print "".join(self.in_buffer)
            self.close()

        def handle_error(self):
            raise

        def close(self):
            if not self.callback.cancelled:
                self.callback.cancel()
            asyncore.dispatcher.close(self)

    UselessClient(('google.com', 80))

    # ==============================================================
    # close this demo after 5 seconds
    # ==============================================================

    CallLater(5, close_all)
    #loop()


    # ==============================================================
    # finally, start the loop to take care of all the functions
    # (and connections) scheduled so far
    # ==============================================================
    loop()
