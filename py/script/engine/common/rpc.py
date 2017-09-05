
on_return = lambda(handle, name, rpc_result, ret_value): None

class RPCObj:
	def __init__(self, remote_id, name=""):
		self.name = name
		self.remote_id = remote_id

	def __getattr__(self, name):
		if ( self.name == "" ):
			return RPCObj(self.remote_id, name)
		else:
			return RPCObj(self.remote_id, self.name + "." + name)

	def __str__(self):
		return self.name

	def __call__(self, *args):
		#print self.remote_id
		#print self.name
		return call(self.remote_id, self.name, args)

def remote(remote_id, name=""):
	return RPCObj(remote_id, name)

