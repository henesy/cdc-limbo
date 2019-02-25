implement cdc;

include "sys.m";
include "dial.m";
include "draw.m";
include "arg.m";

include "silo.m";

# Import handles
sys : Sys;
dial : Dial;

silo : SmartSilo;

# Global variables
mode := 0;	# 0, 1 = silo, tractor
nusers := 0;
width := 1024;
prompt := "> ";

# Module definition
cdc: module {
	init:	fn(nil: ref Draw->Context, argv: list of string);
};

# Main
init(nil: ref Draw->Context, argv: list of string) {
	sys = load Sys Sys->PATH;
	dial = load Dial Dial->PATH;
	arg := load Arg Arg->PATH;
	if(arg == nil)
		error(sys->sprint("cannot load %s ­ %r\n", Arg->PATH));

	addr := "tcp!*!1337";

	# Process commandline arguments
	arg->init(argv);
	arg->setusage("cdc [-st] [-w size] [-p prompt]");
	while ((opt := arg->opt()) != 0) {
		case opt {
		's' =>
			mode = 0;
		't' =>
			mode = 1;
		'S' =>
			addr = arg->earg();
		'w' =>
			width = int arg->earg();
		'p' =>
			prompt = arg->earg();
		* =>
			arg->usage();
		}
	}

	# Load necessary modules
	case mode {
	0 =>
		silo = load SmartSilo "./silo.dis";
		silo->init();
	* =>
		;
	}

	# Announce connection
	sys->print("Listening on %s\n", addr);
	ac := dial->announce(addr);
	if(ac == nil) 
		error(sys->sprint("couldn't announce ­ %r\n"));

	# Accept all connections forever
	for (;;) {
		lc := dial->listen(ac);
		if(lc == nil)
			error(sys->sprint("listen failed ­ %r"));

		sys->print("Incoming: %s\n", dial->netinfo(lc).raddr);
		spawn client(lc);
	}

	exit;
}

# Client handler
client(c: ref Dial->Connection) {
	dfd := dial->accept(c);
	if(dfd == nil)
		error(sys->sprint("%s failed to accept ­ %r", c.dir));

	buf := array[Sys->ATOMICIO] of byte;

	sys->write(dfd, array of byte prompt, 2);

	# Loop and read forever
	# TODO ­ use msgio(2)
	while((n := sys->read(dfd, buf, len buf)) > 0) {
		msg := string buf[:n];

		case mode {
		0 =>
			silo->docmd(dfd, msg, width);
		* =>
			sys->write(dfd, buf, n);
		}
		
		sys->write(dfd, array of byte prompt, 2);
	}
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
