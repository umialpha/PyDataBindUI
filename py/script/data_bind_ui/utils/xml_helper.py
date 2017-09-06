# -*- coding: utf-8 -*-
import importlib
import xml.etree.ElementTree as ET


def get_class(fullname):
	i = fullname.rfind('.')
	pkgname, modname = fullname[:i], fullname[i + 1:]
	mod = importlib.import_module(pkgname)
	cls_name = mod.__dict__[modname]
	return cls_name


def prop_watch(view, view_attr, vmodel, vmodel_attr):
	def watch(*args, **kwargs):
		prop = kwargs.get('prop')
		if prop and prop.prop_name == vmodel_attr:
			setattr(view, view_attr, prop.prop_val)

	vmodel.connect(watch, weak=False)


def view_listener(view, view_attr, vmodel, vmodel_attr, listner):
	def bind(*args, **kwargs):
		setattr(vmodel, vmodel_attr, getattr(view, view_attr))

	getattr(view, listner)(bind, weak=False)


def event_bind(view, view_fktion, vmodel, vmodel_fktion):
	getattr(view, view_fktion)(getattr(vmodel, vmodel_fktion), weak=False)


def parse_xml(ui, xml_name):
	tree = ET.parse(xml_name)
	root = tree.getroot()

	# context
	context_fullname = root.attrib.get('name')
	setattr(ui, 'viewmodel', get_class(context_fullname)())

	for node in root:
		node_type = node.attrib.get('type')
		node_name = node.attrib.get('name')
		if node_type == 'node':

			ui_node = ui.get_node(node_name)

			for data_bind in node.find('bind-type').findall('data-bind'):
				view = get_class(data_bind.find('view').find('name').text)(ui_node)
				view_attr = data_bind.find('view').find('attr').text
				vmodel = ui.viewmodel
				vmodel_attr = data_bind.find('view-model').find('attr').text
				prop_watch(view, view_attr, vmodel, vmodel_attr)

			for event_listener in node.find('bind-type').findall('event-listener'):
				view = get_class(event_listener.find('view').find('name').text)(ui_node)
				view_attr = event_listener.find('view').find('attr').text
				listener = event_listener.find('view').find('fktion').text
				vmodel = ui.viewmodel
				vmodel_attr = event_listener.find('view-model').find('attr').text
				view_listener(view, view_attr, vmodel, vmodel_attr, listener)

			for e in node.find('bind-type').findall('event-bind'):
				view = get_class(e.find('view').find('name').text)(ui_node)
				vfktion = e.find('view').find('fktion').text
				vmodel = ui.viewmodel
				vmfktion = e.find('view-model').find('fktion').text
				event_bind(view, vfktion, vmodel, vmfktion)




		elif node_type == 'animation':
			pass
