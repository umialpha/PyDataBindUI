# -*- coding: utf-8 -*-
from dispatch import Signal
import const


class TextFieldWrapper(object):
	def __init__(self, node):
		self.node = node
		self.detect_signal = Signal()
		self.node.addEventListener(self._event)

	@property
	def text(self):
		return self.node.getString()

	@text.setter
	def text(self, t):
		self.node.setString(t)

	def connect_detect(self, receiver, sender=None, weak=True, dispatch_uid=None):
		self.detect_signal.connect(receiver, sender, weak, dispatch_uid)

	def _event(self, node, e):
		if e == const.EVENT_TYPE.TEXTFIELD_EVENT_DETACH_WITH_IME:
			self.detect_signal.send(sender=self)
