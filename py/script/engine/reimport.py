def reimport(module_name):
	import types, gc
	
	def isclass(object):
		return isinstance(object, types.ClassType) \
			or hasattr(object, '__bases__')
			
	def update_list(alist, old_obj, new_obj):
		found = False

		for index, item in enumerate(alist):
			if item == old_obj:
				found = True
				alist[index] = new_obj

		assert found, 'maybe error, no item match %s' % str(alist)
		
	def update_dict(adict, old_obj, new_obj):
		found = False

		for key, value in adict.iteritems():
			if key == old_obj:
				found = True
				adict[new_obj] = adict[old_obj]
				del adict[old_obj]
			elif value == old_obj:
				found = True
				adict[key] = new_obj

		assert found, 'maybe error, no key or value match %s' % str(adict)
			
	def process_method(func, new_func):
		objs = gc.get_referrers(func)
		
		for obj in objs:
			if isinstance(obj, list):
				update_list(obj, func, new_func)
			elif isinstance(obj, dict):
				update_dict(obj, func, new_func)
			elif isinstance(obj, types.FrameType):
				pass
			else:
				raise 'process method error: %s(%s)' % (str(obj), str(type(obj)))

	def process_class(old_cls, new_cls):
		objs = gc.get_referrers(old_cls)

		for obj in objs:
			if isinstance(obj, dict):
				update_dict(obj, old_cls, new_cls)
			elif isinstance(obj, list):
				update_list(obj, old_cls, new_cls)
			elif isinstance(obj, old_cls):
				obj.__class__ = new_cls
			elif isinstance(obj, (types.MethodType, types.UnboundMethodType)):
				obj.im_self.__class__ = new_cls
				process_method(obj, getattr(obj.im_self, obj.im_func.func_name))
#			elif isinstance(obj, type):
#				assert obj.__base__ == old_cls
#				obj.__base__ = new_cls
			elif isinstance(obj, (tuple, types.FrameType)) \
			    	or type(obj).__name__ == 'getset_descriptor':
				pass
			else:
				raise 'process class error: %s(%s)\nold: %s\nnew:%s' \
					% (str(obj), str(type(obj)), str(old_cls), str(new_cls))

	def process_namespace(update_items):
		for key, value in update_items.iteritems():
			if isclass(value):
				process_class(value, getattr(module, key))
			elif isinstance(value, \
					(dict, str, types.NoneType, types.FunctionType)):
				pass
			else:
				raise 'process namespace error: %s(%s)' % (str(value), str(type(value)))

	gc.disable()
	try:
		module = __import__(module_name)
		update_items = dict(module.__dict__)
		reload(module)

		process_namespace(update_items)
	finally:
		gc.enable()