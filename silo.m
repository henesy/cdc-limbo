SmartSilo: module {
	s: Silo;

	# Functions
	init: fn();
	docmd: fn(msg: string): string;
	
	# Types
	Silo: adt {
		# Variables
		power:	int;		# power on/off
		lights:	int;		# lights on/off
		status:	string;	# status message
		humid:	int;		# humidity %
		temp:	int;		# temp °C
		supply:	int;		# supply in bushels
		cont:		string;	# contents name
		schan:	chan of string;	# channel for statusen

		# Methods
	};
};
