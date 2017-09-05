# -*- coding: utf-8 -*-

class TextWrapper(object):

    def __init__(self, ui_node):
        self.ui_node = ui_node

    @property
    def text(self):
        return self.ui_node.getString()

    @text.setter
    def text(self, t):
        return self.ui_node.setString(t)
    
    


