import C_debug

class OutputToLog(object):
	def __init__(self):
		self.buf = ''

	def write(self, data):
		lines = data.splitlines(True)
		for ll in lines:
			if ll[-1] == '\n':
				msg = ll[0:-1]
				if self.buf:
					msg = self.buf + msg
					self.buf = ""
				C_debug.message(msg)
			else:
				self.buf += ll
	def flush(self):
		self.write('')

class CloseOutPutLog(OutputToLog):

	def write(self, data):
		return

	def flush(self):
		return

def init(open_log_flag=True):
	if open_log_flag:
		open_log()
	else:
		close_log()

def close_log():
	import sys
	import logging
	logging.disable(logging.ERROR)
	sys.stderr = sys.stdout = CloseOutPutLog()

def open_log():
	import sys
	import logging
	logging.disable(logging.DEBUG)
	sys.stderr = sys.stdout = OutputToLog()
