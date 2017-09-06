# -*- coding: utf-8 -*-


def prop_watch(view, view_attr, vmodel, vmodel_attr):

    def watch(*args, **kwargs):
        prop = kwargs.get('prop')
        if prop and prop.prop_name == vmodel_attr:
            setattr(view, view_attr, prop.prop_val)

    vmodel.connect(watch, weak=False)


class PropWatcher(object):

    def __init__(self, view, view_attr, view_model, view_model_attr):
        self.view = view
        self.view_attr = view_attr
        self.view_model = view_model
        self.view_model_attr = view_model_attr
        self.view_model.connect(self.watch, weak=False)

    def watch(self, *args, **kwargs):
        prop = kwargs.get('prop')
        if prop and prop.prop_name == self.view_model_attr:
            setattr(self.view, self.view_attr, prop.prop_val)

