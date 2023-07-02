BEGIN {
	# Split base PCB: DIN connects to di_c3_r3, DOUT to do_c3_rt
	out2in["do_c3_r3"] = "di_c2_r3"
	out2in["do_c2_r3"] = "di_c1_r3"
	out2in["do_c1_r3"] = "di_c1_rt"
	out2in["do_c1_rt"] = "di_c1_r2"
	out2in["do_c1_r2"] = "di_c2_r2"
	out2in["do_c2_r2"] = "di_c3_r2"
	out2in["do_c3_r2"] = "di_c3_r1"
	out2in["do_c3_r1"] = "di_c2_r1"
	out2in["do_c2_r1"] = "di_c1_r1"
	out2in["do_c1_r1"] = "di_c2_rt"
	out2in["do_c2_rt"] = "di_c3_rt"
	# do_c3_rt connects to DOUT

	# Raised PCB: All the raised LEDs are connected first and the top
	# inner 6 LEDs are first among them to allow populating only some
	# LEDs as indicators rather than the full complement.
	# DOUT-left connects to do_c5_r2
	# DIN-left connects to DOUT-right
	# DIN-right is unused
	out2in["do_c4_r3"] = "di_c4_r2"
	out2in["do_c4_r2"] = "di_c5_r3"
	out2in["do_c5_r3"] = "di_mirror_c5_r3"
	out2in["do_mirror_c5_r3"] = "di_mirror_c4_r3"
	out2in["do_mirror_c4_r3"] = "di_mirror_c4_r2"
	out2in["do_mirror_c4_r2"] = "di_mirror_c5_r2"
	out2in["do_mirror_c5_r2"] = "di_mirror_c4_r1"
	out2in["do_mirror_c4_r1"] = "di_mirror_c4_rt"
	out2in["do_mirror_c4_rt"] = "di_mirror_c5_rt"
	out2in["do_mirror_c5_rt"] = "di_mirror_c5_r1"
	out2in["do_mirror_c5_r1"] = "di_c5_r1"
	out2in["do_c5_r1"] = "di_c5_rt"
	out2in["do_c5_rt"] = "di_c4_rt"
	out2in["do_c4_rt"] = "di_c4_r1"
	out2in["do_c4_r1"] = "di_c5_r2"
	# do_c5_r2 connect to DOUT-left

	footprint_found = 0
	in_net_expr = "\\(net [^\\)]*\"(di_.*)\"\\)"
	out_net_expr = "\\(net [^\\)]*\"(do_.*)\"\\)"
	debug = 0
}

/footprint|module/ && !footprint_found {
	footprint_found = 1
	if (debug)
		print "Footprint found, starting translation"
}
($0 ~ in_net_expr) && !footprint_found {
	match($0, in_net_expr, a)
	in_nets[a[1]] = a[0]
	if (debug)
		print a[1] " is " in_nets[a[1]]
	else
		print $0
	next
}
($0 ~ out_net_expr) && footprint_found {
	match($0, out_net_expr, a)
	in_net = out2in[a[1]]
	net = in_nets[in_net]
	if (net)
		gsub(out_net_expr, net)
	else
		print "no substitution for " a[1] > "/dev/stderr"
	print $0
	next
}
// {
	if (!debug)
		print $0
}
