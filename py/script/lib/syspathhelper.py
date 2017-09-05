# -*- coding: utf-8 -*-

def addpath(new_path):  
	""" AddSysPath(new_path)：给Python的sys.path增加一个"目录"  
	如果此目录不存在或者已经在sys.path中了，则不操作  
	返回1表示成功，-1表示new_path不存在，0表示已经在sys.path中了  
	"""
	import sys, os  
	# 避免加入一个不存在的目录  
	if not os.path.exists(new_path): return -1  
	# 将路径标准化。 Windows是大小写不敏感的，所以若确定在  
	# Windows下，将其转成小写  
	new_path = os.path.abspath(new_path)  
	if sys.platform == 'win32':  
		new_path = new_path.lower( )  
		# 检查当前所有的路径  
		for x in sys.path:  
			x = os.path.abspath(x)  
			if sys.platform == 'win32':  
				x = x.lower( )  
				if new_path in (x, x + os.sep):  
					return 0  
	sys.path.append(new_path)
	return 1  

def addpathes(*pathes):  
	""" AddSysPath(new_path)：给Python的sys.path增加一个"目录"  
	如果此目录不存在或者已经在sys.path中了，则不操作  
	返回1表示成功，-1表示new_path不存在，0表示已经在sys.path中了  
	"""
	for path in pathes:
		addpath(path)  
	return 1  