# -*- coding: utf-8 -*-

class ButtonWrapper(object):
    def __init__(self, node):
        self.node = node
        self.event_begin_singal = Signal()
        self.event_moved_singal = Signal()
        self.event_end_singal = Singal()
        self.node.addEventListener(self._event)

    def _event(self, node, event):
        if event == 0:
            self.event_begin_singal.send(sender=self)
        elif event == 1:
            self.event_moved_singal.send(sender=self)
        elif event == 2:
            self.event_end_singal.send(sender=self)

    def add_event_listener(self, event_type, fktion):
        if event_type == 0:
            self.event_begin_singal.connect(fktion)
        elif event_type == 1:
            self.event_moved_singal.connect(fktion)
        elif event_type == 2:
            self.event_end_singal.connect(fktion)
