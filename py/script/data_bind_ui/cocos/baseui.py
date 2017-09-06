# -*- coding: utf-8 -*-

from utils import cocos_helper
from utils import xml_helper


class BaseUI(object):

    CSB_FILE = ''
    BIND_XML = ''


    def __init__(self):

        self.read_csb()
        self.parse_xml()


    def read_csb(self):
        self._node_dict = dict()
        self.widget = cocos_helper.read_ui_file(self.CSB_FILE)
        def bfs(node, prefix):
            fullname = prefix + '.' + node.getName()
            self._node_dict[fullname] = node
            for child in node.getChildren():
                bfs(child, fullname)
        bfs(self.widget, '')

    def parse_xml(self):
        xml_helper.parse_xml(self, self.BIND_XML)


    def get_node(self, node_name):
        return self._node_dict.get(node_name, None)

    




