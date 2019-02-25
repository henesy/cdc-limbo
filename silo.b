implement SmartSilo;

include "silo.m";

include "sys.m";

sys : Sys;

# stdbool
false	:= 0;
true	:= 1;
invalid := "err: invalid argument";

# Initialize the module
init() {
	sys = load Sys Sys->PATH;

	# Init silo
	s.status	= "idle";
	s.lights	= false;
	s.humid	= 30;
	s.temp	= 20;
	s.supply	= 0;
	s.cont	= "corn";
}

# Process a command
docmd(fd: ref Sys->FD, msg: string, width: int) {
	str := "ok.";
	msg = tr(msg, '\r', ' ');

	# Process commands
	(n, argv) := sys->tokenize(msg, " \t");
	n--;	# Assume we get a \n as per AGRO spec

	case n {
	0 =>
		str = "err: no command";
	* =>

	# Switch on command
	case hd argv {
	"lights" =>
		case n {
		1=>
			if(s.lights)
				str = "on";
			else
				str = "off";
		* =>
			case hd tl argv {
			"on" =>
				s.lights = true;
			"off" =>
				s.lights = false;
			* =>
				str = invalid;
			}
		}
	* =>
		# sys->print("got: %s with %d\n", hd argv, n);
		str = "err: command not found";
	};
	};
	
	# Write out response
	str += "\n";

	w := width;
	if(len str < width)
		w = len str;

	sys->write(fd, array of byte str, w);
}

# Replace within a string
tr(s: string, a: int, b: int): string {
	for(i := 0; i < len s; i++) {
		if(s[i] == a)
			s[i] = b;
	}

	return s;
}
