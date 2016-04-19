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
use File::Slurp;

# what are the global variables?
our $designator  = "none"; 
#our $matchingTag = "none";      
our $phonebook   = ".phonebook";
our $todofile    = "none";
our $todofp;
our $verboseFlag = 0;
our $helpFlag    = 0;
our @upperlist;
our @lowerlist;
our $cdow = strftime( "%a", localtime());
our $cmoy = strftime( "%b", localtime());
our $cday = strftime( "%d", localtime());
our $cmonth = strftime( "%m", localtime());
our $cyear = strftime( "%Y", localtime());
our $ndow = strftime( "%u", localtime());
our $epoch = strftime( "%s", localtime());

# subs - listed above main code to squelch prototype complaints

# process a line that isn't name, note, or todo item
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
	my $nth = 0;
	my $moy = "blank";
	my $hastime = 0;

	# retrieve the line
	my $line = shift;

	# break the line into parts
	$line =~ /^(.*)\t(.*\n)/;
	my $date = $1;
	my $item = $2;

	# does this item have a valid time?
	if( $item =~ /^([0-2][0-9])\:([0-5][0-9]) / ) {
		my $hour = $1;
		my $minute = $2;
		if( $hour >= 0 && $hour <=24 && $minute >=0 && $minute <= 59 ) {
			$hastime = 1;
		}
	}

	# recognize the date, if possible
	#
	
	# is it "daily"?
	if( $date =~ /daily/ ) {

		# push it on the appropriate list
		if( $hastime == 1 ) {
			push @upperlist, $item;
		}
		else {
			push @lowerlist, $item;
		}
	}
	
	# is it yyyymmdd?
	if( $date =~ /[0-9]{8}/ ) {

		# parse the date
		$date =~ /^([0-9]{4})([0-9]{2})([0-9]{2})/;
		$year = $1; $month = $2; $day = $3;

		# parse the wildcards
		if( $year == 0 && $month == 0 && $day == 0 ) {

			# push it on the appropriate list
			if( $hastime == 1 ) {
				push @upperlist, $item;
			}
			else {
				push @lowerlist, $item;
			}
		}

		# does it match today?
		if($day == $cday 
		  	&& ($month == $cmonth || $month == 0) 
		  	&& ($year == $cyear || $year == 0)) {
		
			# push it on the appropriate list
			if( $hastime == 1 ) {
				push @upperlist, $item;
			}
			else {
				push @lowerlist, $item;
			}
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

			# push it on the appropriate list
			if( $hastime == 1 ) {
				push @upperlist, $item;
			}
			else {
				push @lowerlist, $item;
			}
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

				# push it on the appropriate list
				if( $hastime == 1 ) {
					push @upperlist, $item;
				}
				else {
					push @lowerlist, $item;
				}
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

					# push it on the appropriate list
					if( $hastime == 1 ) {
						push @upperlist, $item;
					}
					else {
						push @lowerlist, $item;
					}
				}
			}
		}
	}

	# is it a weekday?
	if( $date =~ /^weekday/ ) {
		
		# is this a weekday?
		if($ndow >= 1 && $ndow <= 5) {
			# push it on the appropriate list
			if( $hastime == 1 ) {
				push @upperlist, $item;
			}
			else {
				push @lowerlist, $item;
			}
		}
	}

	# is it a weekend?
	if( $date =~ /^weekend/ ) {
		# is this a weekend?
		if($ndow >= 6 && $ndow <= 7) {
			# push it on the appropriate list
			if( $hastime == 1 ) {
				push @upperlist, $item;
			}
			else {
				push @lowerlist, $item;
			}
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
				# push it on the appropriate list
				if( $hastime == 1 ) {
					push @upperlist, $item;
				}
				else {
					push @lowerlist, $item;
				}
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
	
}

# process command line arguments
sub doCmdLineArgs()
{
	GetOptions(
		'd=s' => \$designator,  # one date or a range of dates
#		's=s' => \$matchingTag, # filter lines by a string
		'f=s' => \$phonebook,   # instead of ~/.phonebook
		#'t=s' => \$todofile,    # where to write todo.txt output
		'v'   => \$verboseFlag, # verbose mode
		'h'   => \$helpFlag     # print usage and quit
	) or printUsage();

	if($verboseFlag) {
		print "target dates = $designator\n";
#		print "regex        = $matchingTag\n";
		print "phonebook    = $phonebook\n";
		#print "todofile     = $todofile\n";
		print "verbose      = $verboseFlag\n";
		print "help         = $helpFlag\n";
	}
}

# process a contact line
sub nameLine( $ )
{
	# is this my line?
	if( $designator =~ /name/ ) {
	
		# retrieve the line
		my $line = shift;

		# process the line
		$line =~ /^.*\t(.*\n)/;
		my $content = $1;

		# put the line in the lower list
		push @lowerlist, $content;

	}
}

# process a note line
sub noteLine( $ )
{
	# is this my line?
	if( $designator =~ /note/ ) {

		# retrieve the line
		my $line = shift;

		# process the line
		$line =~ /^.*\t(.*\n)/;
		my $content = $1;

		# put the line in the lower list
		push @lowerlist, $content;

	}
}

# process a todo line
sub todoLine( $ )
{
	# is this my line?
	if( $designator =~ /todo/ ) {

		# retrieve the line
		my $line = shift;

		# process the line
		$line =~ /^.*\t(.*\n)/;
		my $content = $1;

		# put the line in the lower list
		push @lowerlist, $content;

	}
}

# print the usage message
sub printUsage( )
{
	# file pointer
	my $fp;

	# attempt to open the readme file
	if(!open $fp, "<", "/usr/share/erp/README.md") {
		shortUsage();
	}

	my $pflag = 0;

	# read & print all lines between <pre> and </pre>
	while(my $line = <$fp>) {
		if($line =~ /^<pre>/) {
			$pflag = 1;
			next;
		}
		if($line =~ /^<\/pre>/) {
			$pflag = 0;
			next;
		}
		if($pflag == 1) {
			print "$line";
		}
	}
	exit;
}

# backup usage message if README.md can't be found
sub shortUsage( )
{
	print "erp -d designator -f phonebook -v -h\n";
	exit;
}

### main thread

# are there command line args?
doCmdLineArgs( );

if( $helpFlag ) {
	printUsage();
}

# memorize the phone book
open my $fh, "<", $phonebook
	or die "can't open phonebook $phonebook: $!";
my @lines = read_file($phonebook);
close $fh;

# for every line in the phonebook...
foreach my $line (@lines) {

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

	# okay, either a date or garbage
	else {
		dateLine( $line );
	}
}

## print the lists
#
# sort and print the upper list
my @sortedlist = sort @upperlist;
print "\n--------------- TIMED APPOINTMENTS ---------------\n";
print @sortedlist;
print "\n";

# print the lower list
print @lowerlist;

