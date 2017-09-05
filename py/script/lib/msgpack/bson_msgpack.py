# -*- coding: utf-8 -*-
import bson.objectid as objectid
import datetime
import msgpack

ExtType = msgpack.ExtType

def msgpackext(obj):
	if isinstance(obj, objectid.ObjectId):
		return ExtType(42, str(obj))
	elif isinstance(obj, datetime.datetime):
		return ExtType(43, obj.strftime('%Y-%m-%d-%H-%M-%S-%f'))
	return repr(obj)

def ext_hook(code, data):
	if code == 42:
		return objectid.ObjectId(str(data))
	if code == 43:
		strlist = str(data).split('-')
		return datetime.datetime(int(strlist[0]), int(strlist[1]), int(strlist[2]), int(strlist[3]), int(strlist[4]), int(strlist[5]), int(strlist[6]))
	return ExtType(code, data)
