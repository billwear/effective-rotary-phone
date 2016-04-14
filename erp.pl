#!/bin/perl
use strict;
use warnings;
use POSIX;
use File::Basename;
use File::stat;
use Getopt::Long;
Getopt::Long::Configure qw(gnu_getopt);
use Encode;
use POSIX;

# what are the global variables?
our $designator  = "none"; 
our $matchingTag = "*";      
our $phonebook   = ".phonebook";
our $verboseFlag = 0;
our $helpFlag    = 0;
our $usageMsg    = 0;
our $continOK    = 0;
our $cdow = strftime( "%a", localtime());
our $cmoy = strftime( "%b", localtime());
our $cday = strftime( "%d", localtime());
our $cmonth = strftime( "%m", localtime());
our $cyear = strftime( "%Y", localtime());
our $ndow = strftime( "%u", localtime());

# what's the usage message?
$usageMsg = 
	  "erp 0.13 - Copyright (C) 2016, Bill Wear\n"
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
   . "             three letters of the day; nonsense numbers (10) won't match.\n\n"
   . "   Nmon oct  Nth day of given month; month can be string or number, only matches\n"
   . "             first three letters of a string; nonsense month won't match.\n\n"
   . "   weekday   every monday through friday; holidays not considered, so ymmv.\n\n"
   . "   weekend   every saturday and sunday.\n\n"
   . "   Nweekend  Nth weekend of every month; nonsense numbers won't match.\n\n";
  

# subs - listed above main code to squelch prototype complaints

# process a line that isn't name, note, todo, or continuation
sub dateLine( $ )
{
	# don't process if another designator is selected
	if( $designator =~ /note/ 
		|| $designator =~ /name/
		|| $designator =~ /todo/ ) {
		return;
	}

	# needed global variables
	my $year=0;
   my $day=0;
   my $month=0;
	my $dow = "blank";
	my $printflag = 0;
	my $nth = 0;
	my $moy = "blank";

	# retrieve the line
	my $line = shift;

	# reject continuation lines (bug)
	if( $line =~ /^\t/ ) {
		return;
	}

	# break the line into parts
	$line =~ /^(.*)\t(.*)\n/;
	my $date = $1;
	my $item = $2;

	# recognize the date, if possible
	#
	
	# is it yyyymmdd?
	if( $date =~ /[0-9]{8}/ ) {

		# parse the date
		$date =~ /^([0-9]{4})([0-9]{2})([0-9]{2})/;
		$year = $1; $month = $2; $day = $3;

		# does it match today?
		if($day == $cday && $month == $cmonth && $day == $cday) {
			$printflag = 1;
		}
	}

	# is it a dayname?
	if( $date =~ /^mon/ 
		|| $date =~ /^tue/
		|| $date =~ /^wed/
		|| $date =~ /^thu/
		|| $date =~ /^fri/
		|| $date =~ /^sat/
		|| $date =~ /^sun/ ) {

		# parse the day
		$date =~ /^([A-Za-z]{3})/;
		$dow = $1;

		# does it match?
		if(uc($dow) =~ uc($cdow)) {
			$printflag = 1;
		}
	}

	# is it an nth dayname?
	if( $date =~ /^([0-9]) *mon *$/ 
		|| $date =~ /^([0-9]) *tue *$/
		|| $date =~ /^([0-9]) *wed *$/
		|| $date =~ /^([0-9]) *thu *$/
		|| $date =~ /^([0-9]) *fri *$/
		|| $date =~ /^([0-9]) *sat *$/
		|| $date =~ /^([0-9]) *sun *$/ ) {
		
		# parse the count and day
		$date =~ /(^[0-9]) *([A-Za-z]{3})/;
		$nth = $1;
		$dow = $2;

		# does it match?
		if(uc($dow) =~ uc($cdow)) {
			my $rstart = 7*($nth-1);
			if($cday > $rstart && $cday <= $rstart+7) {
				$printflag = 1;
			}
		}
	}

	# is it an nth dayname of a specific month?
	if( $date =~ /^[0-9]* *mon[a-zA-Z]* [a-zA-Z]*/ 
		|| $date =~ /^[0-9]* *tue[a-zA-Z]* [a-zA-Z]*/
		|| $date =~ /^[0-9]* *wed[a-zA-Z]* [a-zA-Z]*/
		|| $date =~ /^[0-9]* *thu[a-zA-Z]* [a-zA-Z]*/
		|| $date =~ /^[0-9]* *fri[a-zA-Z]* [a-zA-Z]*/
		|| $date =~ /^[0-9]* *sat[a-zA-Z]* [a-zA-Z]*/
		|| $date =~ /^[0-9]* *sun[a-zA-Z]* [a-zA-Z]*/ ) {
		
		# parse the count, day, month
		$date =~ /(^[0-9]) *([A-Za-z]{3})[A-Za-z]* *([A-Za-z]{3})/;
		$nth = $1;
		$dow = $2;
		$moy = $3;

		# does it match?
		if(uc($dow) =~ uc($cdow)) {
			if(uc($moy) =~ uc($cmoy)) {
				my $rstart = 7*($nth-1);
				if($cday > $rstart && $cday <= $rstart+7) {
					$printflag = 1;
				}
			}
		}
	}

	# is it a weekday?
	if( $date =~ /^weekday/ ) {
		
		# is this a weekday?
		if($ndow >= 1 && $ndow <= 5) {
			$printflag = 1;
		}
	}

	# is it a weekend?
	if( $date =~ /^weekend/ ) {
		# is this a weekend?
		if($ndow >= 6 && $ndow <= 7) {
			$printflag = 1;
		}
	}

	# is it an nth weekend?
	if( $date =~ /^[0-9] *weekend/ ) {

		# parse the nth
		$date =~ /(^[0-9])/;
		$nth = $1;

		# does this match?
		if($ndow >= 6 && $ndow <= 7) {
			my $rstart = 7*($nth-1);
			if($cday > $rstart && $cday <= $rstart+7) {
				$printflag = 1;
			}
		}
	}

	# is it mmm(...) nn, yyyy? (0.14)
	# is it yyyy-mm-dd? (0.14)
	# is it mm/dd/yy or dd/mm/yy? (0.14)
	# is it mm/dd/yyyy or dd/mm/yy? (0.14)
	# is it mm-dd-yy or dd-mm-yy? (0.14)
	# is it mm-dd-yyyy or dd-mm-yy? (0.14)
	# is it mmm(...) nn? (0.15)
	# is it mmm(...) with no other qualifiers? (0.15)
	# is it dd with no other qualifiers? (0.15)
	
	# should we print this line?
	if( $printflag == 1 ) {
		print "$item\n";
	}

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

