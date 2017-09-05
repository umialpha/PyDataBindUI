"""Redo the `...` (representation) but with limits on most sizes."""

__all__ = ["Repr","repr"]

import sys

class Repr(object):
	def __init__(self):
		self.maxlevel = 6
		self.maxtuple = 6
		self.maxlist = 6
		self.maxarray = 5
		self.maxdict = 4
		self.maxstring = 30
		self.maxlong = 40
		self.maxother = 20
		self.maxtotal = 192
		
	def repr(self, x):
		return self.repr1(x, self.maxlevel)
		
	def repr1(self, x, level):
		typename = type(x).__name__
		if ' ' in typename:
			parts = typename.split()
			typename = '_'.join(parts)
		if hasattr(self, 'repr_' + typename):
			return getattr(self, 'repr_' + typename)(x, level)
		else:
			s = `x`
			if len(s) > self.maxother:
				i = max(0, (self.maxother-3)//2)
				j = max(0, self.maxother-3-i)
				s = s[:i] + '...' + s[len(s)-j:]
			return s
			
	def repr_tuple(self, x, level):
		n = len(x)
		if n == 0:
			return '()'
		if level <= 0:
			return '(...)'
			
		no_all = n > self.maxtuple
		s = ''
		for i in range(min(n, self.maxtuple)):
			old_s = s
			if s:
				s = s + ', '
			s = s + self.repr1(x[i], level-1)
			
			if len(s) > self.maxtotal - 7:
				s = old_s
				no_all = True
				break
			
		if no_all:
			s = s + ', ...'
		elif n == 1:
			s = s + ','
			
		return '(' + s + ')'
		
	def repr_list(self, x, level):
		n = len(x)
		if n == 0:
			return '[]'
		if level <= 0:
			return '[...]'
			
		no_all = n > self.maxlist
		s = ''
		for i in range(min(n, self.maxlist)):
			old_s = s
			if s:
				s = s + ', '
			s = s + self.repr1(x[i], level-1)
			
			if len(s) > self.maxtotal - 7:
				s = old_s
				no_all = True
				break
			
		if no_all:
			s = s + ', ...'
			
		return '[' + s + ']'

	def repr_array(self, x, level):
		n = len(x)
		header = "array('%s', [" % x.typecode
		if n == 0:
			return header + "])"
		if level <= 0:
			return header + "...])"
			
		no_all = n > self.maxarray
		s = ''
		for i in range(min(n, self.maxarray)):
			old_s = s
			if s:
				s += ', '
			s += self.repr1(x[i], level-1)
			
			if len(s) > self.max_total - 7:
				s = old_s
				no_all = True
				break
				
		if no_all:
			s += ', ...'
			
		return header + s + "])"

	def repr_dict(self, x, level):
		n = len(x)
		if n == 0:
			return '{}'
		if level <= 0:
			return '{...}'
			
		no_all = n > self.maxdict
		s = ''
		keys = x.keys()
		keys.sort()
		for i in range(min(n, self.maxdict)):
			old_s = s
			if s:
				s = s + ', '
			key = keys[i]
			s = s + self.repr1(key, level-1)
			s = s + ': ' + self.repr1(x[key], level-1)
			
			if len(s) > self.maxtotal - 7:
				s = old_s
				no_all = True
				break
			
		if no_all:
			s = s + ', ...'
			
		return '{' + s + '}'
		
	def repr_str(self, x, level):
		s = `x[: self.maxstring]`
		
		if len(s) > self.maxstring:
			i = max(0, (self.maxstring-3) // 2)
			j = max(0, self.maxstring - 3 - i)
			s = `x[: i] + x[len(x) - j: ]`
			s = s[: i] + '...' + s[len(s) - j: ]
			
		return s
		
	def repr_long(self, x, level):
		s = `x` # XXX Hope this isn't too slow...
		
		if len(s) > self.maxlong:
			i = max(0, (self.maxlong-3) // 2)
			j = max(0, self.maxlong - 3 - i)
			s = s[: i] + '...' + s[len(s) - j: ]
			
		return s
		
	def repr_instance(self, x, level):
		try:
			s = `x`
			# Bugs in x.__repr__() can cause arbitrary
			# exceptions -- then make up something
		except:
			# On some systems (RH10) id() can be a negative number. 
			# work around this.
			MAX = 2L * sys.maxint + 1
			return '<' + x.__class__.__name__ + ' instance at %x>' % (id(x) & MAX)
			
		if len(s) > self.maxstring:
			i = max(0, (self.maxstring - 3) // 2)
			j = max(0, self.maxstring - 3 - i)
			s = s[: i] + '...' + s[len(s) - j: ]
			
		return s

aRepr = Repr()
repr = aRepr.repr
