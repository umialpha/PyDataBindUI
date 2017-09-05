# -*- coding: utf-8 -*-
#Owner: rlei@corp.netease.com (雷雨)
#
# 热更新的目标：
#   支持：
#   (1)更新代码定义(function/method/static_method/class_method)
#   (2)不更新数据(除了代码定义外的类型都当作是数据)；
#   (3)第一次import，调用模块的__first_import__函数;
#      执行更新前，调用模块的__before_update__函数；
#      执行更新后，调用模块的__after_update__函数
#   (4)本模块自身也支持同样规则的热更新；但需要慎重更改本模块
#   不支持：
#   (1)不支持命名空间的命名删除；reload本身决定了修改文件来删除命名是不生效的。
#   (2)不支持中途新添的代码定义的[重定向]后再热更新。
#   (3)不支持类的继承关系的修改
#   (4)meta class update未完善
#
# TODO:
# (1) 可以通过一些编码约定来实现模块级的 dict / list / set 更新
# (2) 如果(1)可以实现，怎么实现 tuple frozenset 之类的固态容器更新？
# (3) 检查两次update之间是否存在对象泄漏
#
# by AKara 2010.05.14
#
import sys
import types

# 取得一个对象的字符串描述
def _S(obj):
	return str(obj)[:50]

# 支持缩进打印的log函数
def _log(msg, depth=0):
	return
	print "%s %s" % ("--" * depth, msg)

# 用新的函数对象内容更新旧的函数对象中的内容，保持函数对象本身地址不变
def update_function(oldobj, newobj, depth=0):
	setattr(oldobj, "func_code", newobj.func_code)
	setattr(oldobj, "func_defaults", newobj.func_defaults)
	setattr(oldobj, "func_doc", newobj.func_doc)

	_log("[U] func_code", depth)
	_log("[U] func_defaults", depth)
	_log("[U] func_doc", depth)

# 更改旧的方法对象，保持地址不变
def update_method(oldobj, newobj, depth=0):
	update_function(oldobj.im_func, newobj.im_func, depth)

# 用新类内容更新旧类内容，保持旧类本身地址不变
def _update_new_style_class(oldobj, newobj, depth):
	handlers = get_valid_handlers()
	for k, v in newobj.__dict__.iteritems():
		# 如果新的key不在旧的class中，添加之
		if k not in oldobj.__dict__:
			setattr(oldobj, k, v)
			_log("[A] %s : %s"%(k, _S(v)), depth)
			continue
		oldv = oldobj.__dict__[k]

		# 如果key对象类型在新旧class间不同，那留用旧class的对象
		if type(oldv) != type(v):
			_log("[RD] %s : %s"%(k, _S(oldv)), depth)
			continue

		# 更新当前支持更新的对象
		v_type = type(v)
		handler = handlers.get(v_type)
		if handler:
			_log("[U] %s : %s"%(k, _S(v)), depth)
			handler(oldv, v, depth + 1)
			# 由于是直接改oldv的内容，所以不用再setattr了。
		else:
			_log("[RC] %s : %s : %s"%(k, type(oldv), _S(oldv)), depth)

# 用新类内容更新旧类内容，旧类本身地址不变
def _update_old_style_class(oldobj, newobj, depth):
	_update_new_style_class(oldobj, newobj, depth)


def _update_staticmethod(oldobj, newobj, depth):
	# TODO: 这方法好hack，不知还有其他办法不?
	# 一个staticmethod对象，它的 sm.__get__(object)便是那个function对象
	oldfunc = oldobj.__get__(object)
	newfunc = newobj.__get__(object)
	update_function(oldfunc, newfunc, depth)


def _update_classmethod(oldobj, newobj, depth):
	# 继续很hack的做法-_-
	oldfunc = oldobj.__get__(object).im_func
	newfunc = newobj.__get__(object).im_func
	update_function(oldfunc, newfunc, depth)

# 因为types模块中没有
# (1)StaticMethodType
# (2)ClassMethodType
# 所以又要自己动手了
class CFoobar(object):
	@ staticmethod
	def i_am_static_method(): pass
	@ classmethod
	def i_am_class_method(cls): pass # classmethod必须定义至少一个隐式cls参数

# 既然暂时不能更新dict类型的对象，
# 为了使得这个模块本身成为完全可以update的整体，
# 这个映射性质的dict就通过函数来返回吧
def get_valid_handlers():
	_StaticMethodType = type(CFoobar.__dict__["i_am_static_method"])
	_ClassMethodType = type(CFoobar.__dict__["i_am_class_method"])
	return {
		types.FunctionType : update_function,
		types.MethodType : update_method,
		types.TypeType : _update_new_style_class,
		_StaticMethodType : _update_staticmethod,
		_ClassMethodType: _update_classmethod,
		types.ClassType : _update_old_style_class,
		#	types.DictType : _update_dict,
		#	types.ListType : _update_list,
	}

#
# 热更新模块
# 日志标志说明：
# F: First import
# U: Update
# S: Saving old key
# A: Adding new key
# RD: Restore old key because Different object type between old & new
# RC: Restore old key because Can't handle the object type
#
def _call_module_func(module, func_name):
	func = module.__dict__.get(func_name, None)
	if type(func) != types.FunctionType:
		_log(">>>[%s] have no %s function, skip call<<<"%(str(module), func_name))
		return

	_log(">>>[%s] call %s function ok<<<"%(str(module), func_name))
	func()

def update(module_name, update_module_top_level_data=False):
	depth = 1

	module = sys.modules.get(module_name, None)
	if not module: # 第一次import，不存在更新问题
		module = __import__(module_name)
		_call_module_func(module, "__first_import__")
		_log("[F] %s : %s"%(module_name, module), depth)
		return module

	# 执行before update
	_call_module_func(module, "__before_update__")

	# 不是第一次，需要更新
	_log("[U] %s : %s"%(module_name, module), depth)

	# 记录update之前的原模块全部顶层对象
	old_module = {}
	for key, obj in module.__dict__.iteritems():
		old_module[key] = obj
		_log("[S] %s : %s"%(key, _S(obj)), depth)

	# 调用reload重新解释模块
	new_module = reload(module)

	assert id(module) == id(new_module)

	handlers = get_valid_handlers()

	for key, newobj in new_module.__dict__.iteritems():
		# 如果新的key不在旧模块中，不处理即可(其实相当于添加新对象)
		if key not in old_module:
			_log("[A] %s : %s"%(key, _S(newobj)), depth)
			continue
		oldobj = old_module[key]

		# 如果key对象类型在新旧模块间不同，那留旧对象
		# 这里会跳过new style objects
		if type(newobj) != type(oldobj):
			new_module.__dict__[key] = oldobj # 特殊地，这里需要替换，因为reload后的module对象和reload前是同一个地址
			_log("[RD] %s : %s"%(key, _S(oldobj)), depth)
			continue

		# 更新当前支持更新的对象
		obj_type = type(newobj)

		#
		# 如果有__metaclass__，当作 type.TypeType 吧
		#
		if hasattr(newobj, "__metaclass__"):
			obj_type = types.TypeType

		handler = handlers.get(obj_type)
		if handler:
			_log("[U] %s : %s"%(key, _S(oldobj)), depth)
			handler(oldobj, newobj, depth + 1)
			new_module.__dict__[key] = oldobj
		else: # 未支持的对象类型更新，复用旧对象
			new_module.__dict__[key] = oldobj
			_log("[RC] %s : %s"%(key, _S(oldobj)), depth)

	_call_module_func(module, "__after_update__")

	return new_module