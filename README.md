# CDC Smart Farm in Limbo

This is an implementation of the smart farm software for ISU2 2019 CDC implemented in Limbo on Inferno ([Purgatorio](http://code.9front.org/hg/purgatorio/)) to the tune of the AGRO specification. 

Currently only the silo functionality is supported. 

## Build

	mk

## Install

Don't. 

This runs out of its working directory for now. Write a wrapper to call it, or call it directly from emu(1). 

## Usage

	./main.dis

You can connect from a unix machine via telnet(1) or similar:

	telnet localhost 1337
