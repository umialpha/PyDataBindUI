# -*- coding: utf-8 -*-

class TextFieldWrapper(object):

    def __init__(self, node):
        self.node = node

    @property
    def text(self):
        return self.ui_node.getString()

    @text.setter
    def text(self, t):
        return self.ui_node.setString(t)


    
