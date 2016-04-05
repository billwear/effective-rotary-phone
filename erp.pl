#!/bin/perl
use strict;
use warnings;
use POSIX;
use File::Basename;
use File::stat;
use Getopt::Long;
Getopt::Long::Configure qw(gnu_getopt);
use Encode;

# what global vars would i like to have?
our $targetDates = "today"; 
our $regex = "*";      
our $altCalendar = ".bigmeal";
our $verboseFlag = 0;
our $helpFlag = 0;
our $usageMsg = 0;

# what's the usage message?
$usageMsg = 
	  "erp 0.1 - Copyright (C) 2016, Bill Wear\n"
	. "   erp is licensed under the MIT License, with no warranty.\n\n"
	. "   -d dates    show events only for the given date range\n"
   . "               e.g, 20160404, apr 4, apr 4-16, etc.\n"
   . "   -r regex    show only events containing regex, obeying -r\n"
   . "   -f meal     load <meal> instead of ~/.bigmeal\n"
   . "   -v          verbose output\n"
   . "   -h          print this usage message and exit\n\n";
  

# subs - listed above to squelch prototype complaints
sub doCmdLineArgs()
{
	GetOptions(
		'd=s' => \$targetDates, # one date or a range of dates
		'r=s' => \$regex,       # filter lines by a string
		'f=s' => \$altCalendar, # instead of ~/.bigmeal
		'v'   => \$verboseFlag, # verbose mode
		'h'   => \$helpFlag     # print usage and quit
	) or die $usageMsg;
}

### main thread

# are there command line args?
doCmdLineArgs( );

print "target dates = $targetDates\n";
print "regex        = $regex\n";
print "meal file    = $altCalendar\n";
print "verbose      = $verboseFlag\n";
print "help         = $helpFlag\n";
