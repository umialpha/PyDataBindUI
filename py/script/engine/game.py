################################################################################
#                                    WARNING                                   #
#                                                                              #
#                          DO NOT MODIFY THIS FILE!                            #
#        OR YOU MAY LOSE THE IMPORTANT UPDATE MADE BY NEOX ENGINE TEAM         #
################################################################################
VERSION = 1

is_nvidia_shield = False  # 已废弃 为了兼容之前版本，保证patch流程
has_fd_gamepad = False  # 已废弃 为了兼容之前版本，保证patch流程

import sys
import game3d

platform = game3d.get_platform()
has_gamepad = False

MSG_MOUSE_DOWN = 1
MSG_MOUSE_UP = 2
MSG_MOUSE_WHEEL = 3
MSG_MOUSE_DBLCLK = 7
MSG_MOUSE_CLICK = 8

MSG_KEY_DOWN = 4
MSG_KEY_UP = 5
MSG_KEY_PRESSED = 6

MOUSE_BUTTON_LEFT = 1
MOUSE_BUTTON_RIGHT = 2
MOUSE_BUTTON_MIDDLE = 4

# ----------- Virtual Keys ------------------

VK_ENTER = 13
VK_SPACE = 32
VK_ESCAPE = 27
VK_BACKSPACE = 8
VK_TAB = 9
VK_CAPSLOCK = 20
VK_SHIFT = 16
VK_CTRL = 17
VK_ALT = 18
VK_LSHIFT = 160
VK_RSHIFT = 161
VK_LCTRL = 162
VK_RCTRL = 163
VK_LALT = 164
VK_RALT = 165

VK_INSERT = 45
VK_DELETE = 46
VK_HOME = 36
VK_END = 35
VK_PAGEUP = 33
VK_PAGEDOWN = 34
VK_SNAPSHOT = 44

VK_LEFT = 37
VK_UP = 38
VK_RIGHT = 39
VK_DOWN = 40

# letters' keys
sys.modules[__name__].__dict__.update(dict(
	[('VK_' + chr(idx), idx) for idx in xrange(ord('A'), ord('Z') + 1)]
))

# function keys
# VK_F1 -> 112
# ...
# VK_F12 -> 123
sys.modules[__name__].__dict__.update(dict(
	[('VK_F%d' % idx, 111 + idx) for idx in xrange(1, 13)]
))

# digits' keys
sys.modules[__name__].__dict__.update(dict(
	[('VK_' + chr(idx), idx) for idx in xrange(ord('0'), ord('9') + 1)]
))

VK_DEC = 189
VK_ADD = 187

VK_NUMLOCK = 144
VK_NUM0 = 96
VK_NUM1 = 97
VK_NUM2 = 98
VK_NUM3 = 99
VK_NUM4 = 100
VK_NUM5 = 101
VK_NUM6 = 102
VK_NUM7 = 103
VK_NUM8 = 104
VK_NUM9 = 105
VK_NUMDOT = 110
VK_NUMDIV = 111
VK_NUMMUL = 106
VK_NUMDEC = 109
VK_NUMADD = 107

global mouse_x, mouse_y, mouse_dx, mouse_dy, fps
mouse_x = 0
mouse_y = 0
mouse_dx = 0
mouse_dy = 0
fps = 60

## 退出处理
# close_query为非None时，通过Windows操作关闭窗口时会回调close_query，脚本可以询问用户是否确认关闭，然后调用game3d.exit()真正关闭客户端。
# 注意：此时关闭客户端的唯一正常途径就是调用game3d.exit()。要保证总有机会调用到game3d.exit()，否则只能强杀进程。
close_query = None
# 真正要退出时，回调给脚本做最后的清理工作
on_exit = lambda: None

## 鼠标消息
on_mouse_msg = lambda msg, key: None
on_mouse_wheel = lambda msg, delta, key_state: None
on_mouse_enter = lambda: None
on_mouse_leave = lambda: None
## 错误处理
on_error = lambda msg: None
on_warning = lambda msg: None
## 截图完成处理
on_capture_finish = lambda: None
## 控制台输入
on_debug_input = lambda cmd: None
## 窗口激活事件
on_activated = lambda: None
on_deactivated = lambda: None
## 操作系统登出事件
on_system_logout = lambda: None

key_msg_map = {}
full_handler = []

key_status_dic = dict()


def _default_on_key_msg(msg, key_code):
	print '[TH] on_key_msg', msg, key_code
	set_has_gamepad(True)
	if key_code not in key_status_dic:
		key_status_dic[key_code] = msg
	else:
		if key_status_dic[key_code] == msg:
			return
		key_status_dic[key_code] = msg
	global key_msg_map, full_handler
	try:
		handler = key_msg_map[msg][key_code]
	except KeyError:
		pass
	else:
		handler(msg, key_code)

	for handler in full_handler:
		handler(msg, key_code)


# 按键消息
on_key_msg = _default_on_key_msg


def add_key_handler(msg, key_codes, handler):
	global key_msg_map, full_handler
	if msg is None or key_codes is None:
		full_handler.append(handler)
	else:
		kdict = key_msg_map.setdefault(msg, {})
		for key in key_codes:
			kdict[key] = handler


def clear_key_handler():
	global key_msg_map, full_handler
	key_msg_map.clear()
	full_handler = []


def set_mouse_pos(x, y):
	global mouse_x, mouse_y
	mouse_x = x
	mouse_y = y


def set_mouse_delta(dx, dy):
	global mouse_dx, mouse_dy
	mouse_dx += dx
	mouse_dy += dy


def reset_mouse_delta():
	global mouse_dx, mouse_dy
	mouse_dx = 0
	mouse_dy = 0


NK_BUTTON_A = 96
NK_BUTTON_B = 97
NK_BUTTON_X = 99
NK_BUTTON_Y = 100
NK_BUTTON_L1 = 102
NK_BUTTON_R1 = 103
NK_BUTTON_L2 = 104
NK_BUTTON_R2 = 105
NK_BUTTON_THUMBL = 106
NK_BUTTON_THUMBR = 107

NK_BUTTON_TRIGGERL = 801
NK_BUTTON_TRIGGERR = 802

JOYSTICK_L = 1000  # 左摇杆
JOYSTICK_R = 1001  # 右摇杆
JOYSTICK_DPAD = 1002  # 上下左右十字形面板
JOYSTICK_TRIGGER = 1003
GAMEPAD_UP = 9001
GAMEPAD_DOWN = 9002
GAMEPAD_LEFT = 9003
GAMEPAD_RIGHT = 9004

dpad_up, dpad_down, dpad_left, dpad_right = None, None, None, None


def on_left_joystick(x, y):
	pass


def on_right_joystick(x, y):
	pass


def on_gamepad_event(src_id, x, y):
	print '[TH] on_gamepad_event', src_id, x, y
	set_has_gamepad(True)
	if src_id == JOYSTICK_DPAD:
		global dpad_up, dpad_down, dpad_left, dpad_right
		if dpad_up != MSG_KEY_DOWN and y < -0.9:
			dpad_up = MSG_KEY_DOWN
			on_key_msg(MSG_KEY_DOWN, GAMEPAD_UP)
		if dpad_down != MSG_KEY_DOWN and y > 0.9:
			dpad_down = MSG_KEY_DOWN
			on_key_msg(MSG_KEY_DOWN, GAMEPAD_DOWN)
		if dpad_up == MSG_KEY_DOWN and abs(y) < 0.1:
			dpad_up = MSG_KEY_UP
			on_key_msg(MSG_KEY_UP, GAMEPAD_UP)
		if dpad_down == MSG_KEY_DOWN and abs(y) < 0.1:
			dpad_down = MSG_KEY_UP
			on_key_msg(MSG_KEY_UP, GAMEPAD_DOWN)
		if dpad_left != MSG_KEY_DOWN and x < -0.9:
			dpad_left = MSG_KEY_DOWN
			on_key_msg(MSG_KEY_DOWN, GAMEPAD_LEFT)
		if dpad_right != MSG_KEY_DOWN and x > 0.9:
			dpad_right = MSG_KEY_DOWN
			on_key_msg(MSG_KEY_DOWN, GAMEPAD_RIGHT)
		if dpad_left == MSG_KEY_DOWN and abs(x) < 0.1:
			dpad_left = MSG_KEY_UP
			on_key_msg(MSG_KEY_UP, GAMEPAD_LEFT)
		if dpad_right == MSG_KEY_DOWN and abs(x) < 0.1:
			dpad_right = MSG_KEY_UP
			on_key_msg(MSG_KEY_UP, GAMEPAD_RIGHT)
	elif src_id == JOYSTICK_L:
		on_left_joystick(x, y)
	elif src_id == JOYSTICK_R:
		on_right_joystick(x, y)


def on_char(char_code):
	print '[TH] on_char', char_code


def on_gamepad_connect_change(status):
	print '[TH] on_gamepad_connect_change', status
	set_has_gamepad(status)


def on_has_gamepad_change(status):
	pass


def set_has_gamepad(status):
	if platform == game3d.PLATFORM_WIN32:
		return
	global has_gamepad
	has_gamepad = status
	on_has_gamepad_change(status)
