# -*- coding: utf-8 -*-

class PyImporter(object):
	ext = '.py'
	
	def __init__(self, path):
		self._path = path
		try:
			import redirect
			self.npk_importer = redirect.NpkImporter(path)
		except:
			self.npk_importer = None
		
	def find_module(self, fullname, path = None):
		import C_file
		if path is None:
			path = self._path
		
		mod_name = fullname.replace('.', '/')
		pkg_name = mod_name + "/__init__" + PyImporter.ext
		if C_file.find_file(pkg_name, path):
			return self

		mod_name += PyImporter.ext
		
		if C_file.find_file(mod_name, path):
			return self
		
		if self.npk_importer:
			return self.npk_importer.find_module(fullname, path)

		return None
		
	def load_module(self, fullname):
		import C_file
		mod_name = fullname
		is_pkg = True
		mod_path = fullname.replace('.', '/') + "/__init__"
		if not C_file.find_file(mod_path + PyImporter.ext, self._path):
			is_pkg = False
			mod_path = fullname.replace('.', '/')
		
		if C_file.find_file(mod_path + PyImporter.ext, self._path):
			data = C_file.get_file(mod_path + PyImporter.ext, self._path)
			data = data.replace("\r\n", "\n")
			data = compile(data, mod_name, "exec")
			
			path = None
			if is_pkg:
				path = [self._path]
		
			m = C_file.new_module(mod_name, data, path)
				
			return m
		
		if self.npk_importer:
			return self.npk_importer.load_module(fullname)

		return None
		