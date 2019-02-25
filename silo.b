implement SmartSilo;

include "silo.m";
include "util.m";

include "sys.m";

sys : Sys;
util : Util;

# stdbool
false	:= 0;
true	:= 1;
invalid := "err: invalid argument";

# Initialize the module
init() {
	sys = load Sys Sys->PATH;
	util = load Util "./util.dis";

	# Init silo
	s.power	= false;
	s.status	= "idle";
	s.lights	= false;
	s.humid	= 30;
	s.temp	= 20;
	s.supply	= 0;
	s.cont	= "corn";
	s.schan	= chan of string;	# might be unnecessary
}

# Process a command
docmd(msg: string): string {
	str := "ok.";

	msg = util->tr(msg, '\r', ' ');

	# Process commands
	(n, argv) := sys->tokenize(msg, " \t");
	n--;		# Assume we get a \n as per AGRO spec

	case n {
	0 =>
		return "err: no command";
	* =>

	cmd := hd argv;

	# Update status, if any queued
	alt {
	s.status = <-s.schan =>
		;
	* =>
		;
	};

	# Block on status updates, bar a whitelist of cmds
	if(!s.power) {
		errstr := "err: powered off";

		case cmd {
		"power" =>
			;
		"status" =>
			;
		* =>
			return errstr;
		};
	}

	# Switch on command
	case cmd {
	"lights" =>
		case n {
		1=>
			if(s.lights)
				str = "on";
			else
				str = "off";
		* =>
			# argv[1]
			case hd tl argv {
			"on" =>
				s.lights = true;
			"off" =>
				s.lights = false;
			* =>
				str = invalid;
			}
		}

	"power" =>
		case n {
		1=>
			if(s.power)
				str = "on";
			else
				str = "off";
		* =>
			# argv[1]
			case hd tl argv {
			"on" =>
				s.power = true;
			"off" =>
				s.power = false;
			* =>
				str = invalid;
			}
		}

	"status" =>
		str = s.status;
	
	* =>
		return "err: command not found";
	};
	};

	return str;
}
