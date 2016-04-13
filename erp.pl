#!/bin/perl
use strict;
use warnings;
use POSIX;
use File::Basename;
use File::stat;
use Getopt::Long;
Getopt::Long::Configure qw(gnu_getopt);
use Encode;

# what are the global variables?
our $targetDates = "today"; 
our $matchingTag = "*";      
our $phonebook   = ".phonebook";
our $verboseFlag = 0;
our $helpFlag    = 0;
our $usageMsg    = 0;

# what's the usage message?
$usageMsg = 
	  "erp 0.1 - Copyright (C) 2016, Bill Wear\n"
   . "   [e]ffective [r]otary [p]hone - consults '.phonebook' for stored info\n"
	. "   erp is licensed under the MIT License, with no warranty.\n\n"
	. "   -d designator show items of type <designator> (see below)\n"
   . "   -t tag        show only items containing <tag>\n"
   . "   -f phonebook  load <phonebook> instead of ~/.phonebook\n"
   . "   -v            verbose output\n"
   . "   -h            print this usage message and exit\n\n"
	. "phonebook structure:\n"
   . "   designator\\tinformation\n"
   . "   \\tcontinuation of last designator\n\n"
   . "where <designator> is one of the following:\n"
   . "   name   someone's contact information\n"
	. "   [date] a date in one of the formats described below\n"
   . "   note   a note to keep & call up later\n"
   . "   todo   a to-do item\n\n"
	. "date formats:\n"
   . "   yyyymmdd  a specific date; substituting dashes for a digit has the \n"
   . "             effect of ignoring that part of the date (allowing repeats);\n"
   . "             for example, 0000mmdd = annual; 000000dd = ddth day of each month.\n\n"
   . "   mon       name of any day; only looks at first three letters of the day.\n\n"
   . "   Nmon      Nth day of every month (eg, Nth monday); only looks at first \n"
   . "             three letters of the day; nonsense numbers match last such day.\n\n"
   . "   Nmon oct  Nth day of given month; month can be string or number, only matches\n"
   . "             first three letters of a string; nonsense month = every month.\n\n"
   . "   weekday   every monday through friday; holidays not considered, so ymmv.\n\n"
   . "   weekend   every saturday and sunday.\n\n"
   . "   Nweekend  Nth weekend of every month; defaults to last if N is nonsensical.\n\n";
  

# subs - listed above to squelch prototype complaints
sub doCmdLineArgs()
{
	GetOptions(
		'd=s' => \$targetDates, # one date or a range of dates
		't=s' => \$matchingTag, # filter lines by a string
		'f=s' => \$phonebook,   # instead of ~/.phonebook
		'v'   => \$verboseFlag, # verbose mode
		'h'   => \$helpFlag     # print usage and quit
	) or die $usageMsg;

	if($verboseFlag) {
		print "target dates = $targetDates\n";
		print "regex        = $matchingTag\n";
		print "phonebook    = $phonebook\n";
		print "verbose      = $verboseFlag\n";
		print "help         = $helpFlag\n";
	}
}

### main thread

# are there command line args?
doCmdLineArgs( );

if( $helpFlag ) {
	print $usageMsg;
	exit;
}

# found the phone book?
open my $fh, "<", $phonebook
	or die "can't open phonebook $phonebook: $!";

# for every line in the phonebook...
while( my $line = <$fh> ) {
	print $line;

}

# close the phone book
close $fh; 

