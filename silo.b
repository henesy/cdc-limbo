implement Silo;

include "silo.m";

include "sys.m";

sys : Sys;

# Initialize the module
init() {
	sys = load Sys Sys->PATH;
}

# Process a command
docmd(fd: ref Sys->FD, msg: string, width: int) {
	str := "<nil>";

	# Process commands
	
	
	# Write out response
	str += "\n";

	w := width;
	if(len str < width)
		w = len str;

	sys->write(fd, array of byte str, w);
}
