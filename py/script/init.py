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
    sys.path.append('script/PyDataBindUI')
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
    UI.viewmodel.output = str(random.random())
    ############ test
    # from cocosui import cc, ccui, ccs
    # reader = ccs.GUIReader.getInstance()
    # # 这个 json 文件是由 cocostudio 导出的
    # widget = reader.widgetFromJsonFile("ui/json/animationui.json")
    # print 'widget', widget
    # scene = cc.Scene.create()
    # director = cc.Director.getInstance()
    # director.runWithScene(scene)
    # layer = cc.Layer.create()
    # scene.addChild(layer)
    # layer.addChild(widget)
    # # button_a = ccui.Helper.seekWidgetByName(widget, "Button_a")
    #
    # m = ccs.ActionManagerEx.getInstance()
    # #
    # actionObj = m.playActionByName("ui/json/animationui.json", "Animation1")
    #
    # img = ccui.Helper.seekWidgetByName(widget, "ImageView")
    # img.runAction(cc.FadeOut.create(1))
