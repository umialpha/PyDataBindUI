def view_result(data_file, result_file):
	print data_file
	print result_file
	import hotshot, hotshot.stats
	stats = hotshot.stats.load(data_file)
	stats.sort_stats('time', 'calls')
	
	f = open(result_file, 'wt')
	try:
		for (file_name, lineno, func_name), \
				(cc, ncalls, tottime, curtime, callers) \
				in stats.stats.iteritems():
			f.write('"%s" %d %s %d %f %f ' \
				% (file_name, lineno, func_name, ncalls, tottime, curtime))

			for (caller_file, caller_lineno, caller_func), caller_calls \
					in callers.iteritems():
				f.write('"%s" %d %s %d;' \
					% (caller_file, caller_lineno, caller_func, caller_calls))
					
			f.write('\n')

	finally:
		f.close()
