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
our $designator  = "none"; 
our $matchingTag = "*";      
our $phonebook   = ".phonebook";
our $verboseFlag = 0;
our $helpFlag    = 0;
our $usageMsg    = 0;
our $continOK    = 0;

# what's the usage message?
$usageMsg = 
	  "erp 0.12 - Copyright (C) 2016, Bill Wear\n"
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
  

# subs - listed above main code to squelch prototype complaints

# process a line that isn't name, note, todo, or continuation
sub dateLine( $ )
{
	my $line = shift;
}

# process command line arguments
sub doCmdLineArgs()
{
	GetOptions(
		'd=s' => \$designator,  # one date or a range of dates
		't=s' => \$matchingTag, # filter lines by a string
		'f=s' => \$phonebook,   # instead of ~/.phonebook
		'v'   => \$verboseFlag, # verbose mode
		'h'   => \$helpFlag     # print usage and quit
	) or die $usageMsg;

	if($verboseFlag) {
		print "target dates = $designator\n";
		print "regex        = $matchingTag\n";
		print "phonebook    = $phonebook\n";
		print "verbose      = $verboseFlag\n";
		print "help         = $helpFlag\n";
	}
}

# process a contact line
sub nameLine( $ )
{
	# reset the continuation flag
	$continOK = 0;

	# is this my line?
	if( $designator =~ /name/ ) {
	
		# mark the designator for continuation lines
		$continOK = 1;

		# retrieve the line
		my $line = shift;

		# for now, just print the line
		print $line;
	}
}

# process a note line
sub noteLine( $ )
{
	# reset the continuation flag
	$continOK = 0;

	# is this my line?
	if( $designator =~ /note/ ) {

		# mark the designator for continuation lines
		$continOK = 1;

		# retrieve the line
		my $line = shift;

		# for now, just print the line
		print $line;
	}
}

# process a todo line
sub todoLine( $ )
{
	# reset the continuation flag
	$continOK = 0;

	# is this my line?
	if( $designator =~ /todo/ ) {

		# mark the designator for continuation lines
		$continOK = 1;

		# retrieve the line
		my $line = shift;

		# for now, just print the line
		print $line;
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

	# is this a comment?
	if( $line !~ /\t/ ) {
		next;
	}

	# is this a contact line?
	if( $line =~ /^name/ ) {
		nameLine( $line );
	}

	# is this a note line?
	elsif( $line =~ /^note/ ) {
		noteLine( $line );
	}

	# is this a todo line?
	elsif( $line =~ /^todo/ ) {
		todoLine( $line );
	}

	# is this a continuation line?
	elsif( $line =~ /^\t/ && $continOK == 1 ) {
		print $line;
	}

	# okay, either a date or garbage
	else {
		dateLine( $line );
	}
}

# close the phone book
close $fh; 

