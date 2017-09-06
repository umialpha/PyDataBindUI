# -*- coding: utf-8 -*-
from dispatch import Signal
import const

class TextFieldWrapper(object):

	def __init__(self, node):
		self.node = node
		self.detect_signal = Signal()

	@property
	def text(self):
		return self.node.getString()

	@text.setter
	def text(self, t):
		self.node.setString(t)

	def detect_event(self, **kwargs):
		self.detect_signal.send(sender=self, **kwargs)


	def _event(self, node, e):
		if e == const.TEXTFIELD_EVENT_DETACH_WITH_IME:
			self.detect_event()






