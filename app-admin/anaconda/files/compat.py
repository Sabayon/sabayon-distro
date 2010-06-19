# compatability aliases for python-selinux
try:
        import selinux_aux

        enabled = selinux_aux.enabled

	get_lsid = selinux_aux.get_lsid
	get_sid = selinux_aux.get_sid
	set_sid = selinux_aux.set_sid
	secure_rename = selinux_aux.secure_rename
	secure_copy = selinux_aux.secure_copy
	secure_mkdir = selinux_aux.secure_mkdir
	secure_symlink = selinux_aux.secure_symlink
	setexec = selinux_aux.setexec
	getcontext = selinux_aux.getcontext

except:
	pass
