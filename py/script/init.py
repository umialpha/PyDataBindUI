#
# encoding: utf-8

def init(arg):
	import logoutput
	logoutput.init()

	import game3d
	game3d.load_plugin('world.dll')
	game3d.load_plugin('cocosui.dll')
	# if 1:
	#     import sys
	#     sys.path.append('C:/Python27/Lib')
	#     sys.path.append("debug/pydev")
	#     sys.path.append('script/pycharm-debug.egg')
	#     import pydevd
	#     pydevd.settrace('localhost', port=6789, stdoutToServer=True, stderrToServer=True, suspend=False)

UI = None

def start():

	if 1:
		import sys
		sys.path.append('script/pycharm-debug.egg')
		import pydevd
		pydevd.settrace('localhost', port=6789, stdoutToServer=True, stderrToServer=True, suspend=False)

	global UI
	import sys
	sys.path.append('script/data_bind_ui')
	from cocos.chatui import ChatUI
	ui = ChatUI()
	UI = ui
	from cocosui import cc
	scene = cc.Scene.create()
	director = cc.Director.getInstance()
	director.runWithScene(scene)
	view = director.getOpenGLView()
	view.setDesignResolutionSize(1344, 750, cc.RESOLUTIONPOLICY_SHOW_ALL)
	layer = cc.Layer.create()
	scene.addChild(layer)
	layer.addChild(ui.widget)
	import render
	render.logic = logic

def logic():
	global UI
	import random
	# UI.viewmodel.output = str(random.random())


