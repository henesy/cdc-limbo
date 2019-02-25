SmartSilo: module {
	s: Silo;

	# Functions
	init: fn();
	docmd: fn(fd: ref Sys->FD, msg: string, width: int);
	
	# Types
	Silo: adt {
		# Variables
		lights:	int;		# lights on/off
		status:	string;	# status message
		humid:	int;		# humidity %
		temp:	int;		# temp °C
		supply:	int;		# supply in bushels
		cont:		string;	# contents name

		# Methods
	};
};
