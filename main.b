implement cdc;

include "sys.m";
include "dial.m";
include "draw.m";
include "arg.m";

# Import handles
sys : Sys;
dial : Dial;

# Global variables
mode := 0;	# 0, 1 = silo, tractor
nusers := 0;

cdc: module {
	init:	fn(nil: ref Draw->Context, argv: list of string);
};

# Main
init(nil: ref Draw->Context, argv: list of string) {
	sys = load Sys Sys->PATH;
	dial = load Dial Dial->PATH;
	arg := load Arg Arg->PATH;
	if(arg == nil){
		sys->fprint(stderr(), "Error: cannot load %s ­ %r\n", Arg->PATH);
		exit;
	}

	# sysname := readfile("/dev/sysname");
	addr := "tcp!*!1337";

	# Process commandline arguments
	arg->init(argv);
	arg->setusage("cdc [-st]");
	while ((opt := arg->opt()) != 0) {
		case opt {
		's' =>
			mode = 0;
		't' =>
			mode = 1;
		'S' =>
			addr = arg->earg();
		* =>
			arg->usage();
		}
	}

	# Announce connection
	sys->print("Listening on %s\n", addr);
	ac := dial->announce(addr);
	if(ac == nil) {
		error(sys->sprint("Error: couldn't announce ­ %r\n"));
		exit;
	}

	for (;;) {
		lc := dial->listen(ac);
		if(lc == nil){
			error(sys->sprint("listen failed ­ %r"));
			exit;
		}

		sys->print("Incoming: %s\n", dial->netinfo(lc).raddr);
		# spawn client(lc);
	}

	exit;
}

# Error handling
error(e: string) {
	sys->fprint(stderr(), "Error: %s\n", e);
	raise "fail:error";
}

# Outputs stderr fd
stderr(): ref Sys->FD {
	return sys->fildes(2);
}

# Read from file and return a string
readfile(f: string): string {
	fd := sys->open(f, sys->OREAD);
	if(fd == nil)
		return nil;

	buf := array[8192] of byte;
	n := sys->read(fd, buf, len buf);
	if(n < 0)
		return nil;

	return string buf[0:n];	
}
