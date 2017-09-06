# -*- coding: utf-8 -*-
from dispatch import Signal


class ButtonWrapper(object):
    def __init__(self, node):
        self.node = node
        self.begin_singal = Signal()
        self.moved_singal = Signal()
        self.end_singal = Signal()
        self.node.addTouchEventListener(self._event)

    def _event(self, node, event):
        if event == 0:
            self.begin_singal.send(sender=self)
        elif event == 1:
            self.moved_singal.send(sender=self)
        elif event == 2:
            self.end_singal.send(sender=self)

    def connect_end(self, receiver, sender=None, weak=True, dispatch_uid=None):
        self.end_singal.connect(receiver, sender, weak, dispatch_uid)
