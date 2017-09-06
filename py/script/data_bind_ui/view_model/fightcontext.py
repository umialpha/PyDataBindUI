# -*- coding: utf-8 -*-
from internal.context import Context, SignalArgs

class FightContext(Context):

   
    # __proxy__ = {
    #     'output': { 'default': '', }
    #     'input': {'default': '', }
    # }

    def __init__(self, *args, **kwargs):

        super(FightContext, self).__init__(*args, **kwargs)
        self._output = ''
        self._input = ''


    @property
    def output(self):
        return self._output
        

    @output.setter
    def output(self, _t):
        if _t == self._output:
            return
        self._output = _t
        self.send(sender=self, prop=SignalArgs('output', self._output))


    @property
    def input(self):
        return self._input
        

    @input.setter
    def input(self, _t):
        if _t == self._input:
            return
        self._input = _t
        self.send(sender=self, prop=SignalArgs('input', self._input))


    def field_end_event(self, text):
        self.input = text


    def send_event(self, *args, **kwargs):
        self.output = self.input

        

