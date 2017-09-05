# -*- coding: utf-8 -*-

class PropWatcher(object):

    def __init__(self, view, view_attr, view_model, view_model_attr):
        self.view = view
        self.view_attr = view_attr
        self.view_model = view_model
        self.view_model_attr = view_model_attr
        self.view.connect(self.watch)

    def watch(self, *args, **kwargs):
        prop = args.get('prop')
        if prop and prop.prop_name == self.view_model_attr:
            setattr(self.view, self.view_attrm, prop.prop_val)

