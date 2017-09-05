# -*- uft-8 -*-

from dispatch import Signal



class ContextMeta(type):

  
    registry = {}

    @classmethod
    def register_class(cls, target_class):
        cls.registry[target_class.__name__] = target_class


    def __new__(meta, name, bases, class_dict):

        cls = type.__new__(meta, name, bases, class_dict)
        ContextMeta.register_class(cls)
        print 'ContextMeta', ContextMeta.registry
        return cls

    @classmethod
    def create(cls, cls_name, *args, **kwargs):
        assert cls_name in cls.registry, cls_name
        return cls.registry[cls_name](*args, **kwargs)


class signalArgs(object):

    def __init__(self, prop, val):
        self.prop = prop
        self.val = val
        

class Context(object):


    __metaclass__ = ContextMeta

    def __init__(self, *args, **kwargs):
        super(Context, self).__init__()
        self.signal = Signal()


    def connect(self, receiver, sender=None, weak=True, dispatch_uid=None):
        self.signal.connect(receiver, sender, weak, dispatch_uid)


    def disconnect(self, receiver=None, sender=None, weak=True, dispatch_uid=None):
        self.signal.disconnect(receiver, sender, weak, dispatch_uid)

    def send(self, sender, **named):
        self.signal.send(sender, named)


