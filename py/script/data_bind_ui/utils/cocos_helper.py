# -*- coding: utf-8 -*-



def read_ui_file(ui_file):
    from cocosui import cc
    print 'read_ui_file start', ui_file
    node = cc.CSLoader.createNode(ui_file)
    print 'read_ui_file end', node
    return node




