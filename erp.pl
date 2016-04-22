#!/bin/perl
use strict;
use warnings;
use POSIX;
use File::Basename;
use File::stat;
use Encode;
use POSIX;

sub lookup( $ ) {
	my $input = shift;
	my @xref;

	if($input =~ "agendas" || $input =~ "243-6327") {
		@xref = ( "agendas", "243-6327" );
	}
	elsif($input =~ "calorie" || $input =~ "225-6743") {
		@xref = ( "calorie", "225-6743" );
	}
	elsif($input =~ "cuisine" || $input =~ "284-7463") {
		@xref = ( "cuisine", "284-7463" );
	}
	elsif($input =~ "finance" || $input =~ "346-2623") {
		@xref = ( "finance", "346-2623" );
	}
	elsif($input =~ "glucose" || $input =~ "458-2673") {
		@xref = ( "glucose", "458-2673" );
	}
	elsif($input =~ "grocery" || $input =~ "476-4379") {
		@xref = ( "grocery", "476-4379" );
	}
	elsif($input =~ "listing" || $input =~ "547-8464") {
		@xref = ( "listing", "547-8464" );
	}
	elsif($input =~ "kitchen" || $input =~ "548-2436") {
		@xref = ( "kitchen", "548-2436" );
	}
	elsif($input =~ "journal" || $input =~ "568-7625") {
		@xref = ( "journal", "568-7625" );
	}
	elsif($input =~ "remarks" || $input =~ "736-2757") {
		@xref = ( "remarks", "736-2757" );
	}
	else {
		@xref = ( "listing", "547-8464" );
	}

	return @xref;
}

my $input;

if (not defined $ARGV[0]) {
	$input = "listing";
}
else {
	$input = lc $ARGV[0];
}

# set the input keyword
my ($mnemonic, $number) = lookup( $input );

# open the phonebook
open my $fh, "<", ".phonebook"
    || die "couldn't open .phonebook: $!\n";

while(my $line = <$fh>) {
	if( $line =~ /^$number / || $line =~ /^$mnemonic / ) {
		$line =~ s/^[A-Za-z0-9\-]* *//g;
		print $line;
	}
}

close $fh;

=cut

# what are the global variables?
our $designator  = "none"; 
#our $matchingTag = "none";      
our $phonebook   = ".phonebook";
our $todofile    = "none";
our $todofp;
our $verboseFlag = 0;
our $helpFlag    = 0;
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
	my $printflag = 0;
	my $nth = 0;
	my $moy = "blank";

	# retrieve the line
	my $line = shift;

	# break the line into parts
	$line =~ /^(.*)\t(.*)\n/;
	my $date = $1;
	my $item = $2;

	# recognize the date, if possible
	#
	
	# is it "daily"?
	if( $date =~ /daily/ ) {
		$printflag = 1;
	}
	
	# is it yyyymmdd?
	if( $date =~ /[0-9]{8}/ ) {

		# parse the date
		$date =~ /^([0-9]{4})([0-9]{2})([0-9]{2})/;
		$year = $1; $month = $2; $day = $3;

		# parse the wildcards
		if( $year == 0 && $month == 0 && $day == 0 ) {
			$printflag = 1;
		}

		# does it match today?
		if($day == $cday 
		  	&& ($month == $cmonth || $month == 0) 
		  	&& ($year == $cyear || $year == 0)) {
		
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
		# print to todo.txt file, if requested
		#if( $todofile !~ "none" ) {
			#$line =~ /^(.*)\t(.*)\n/;
			#my $desig = $1;
			#my $item = $2;
			#print $todofp "$item due:$cyear-$cmonth-$cday t:$cyear-$cmonth-$cday #$epoch#\n";
		#}
	}

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

		# for now, just print the line
		print $line;

		# print to todo.txt file, if requested
		#if( $todofile !~ "none" ) {
			#$line =~ /^(.*)\t(.*)\n/;
			#my $desig = $1;
			#my $item = $2;
			#print $todofp "$item +$desig #$epoch#\n";
		#}
	}
}

# process a note line
sub noteLine( $ )
{
	# is this my line?
	if( $designator =~ /note/ ) {

		# retrieve the line
		my $line = shift;

		# for now, just print the line
		print $line;

		# print to todo.txt file, if requested
		#if( $todofile !~ "none" ) {
			#$line =~ /^(.*)\t(.*)\n/;
			#my $desig = $1;
			#my $item = $2;
			#print $todofp "$item +$desig #$epoch#\n";
		#}
	}
}

# process a todo line
sub todoLine( $ )
{
	# is this my line?
	if( $designator =~ /todo/ ) {

		# retrieve the line
		my $line = shift;

		# for now, just print the line
		print $line;

		# print to todo.txt file, if requested
		#if( $todofile !~ "none" ) {
			#$line =~ /^(.*)\t(.*)\n/;
			#my $desig = $1;
			#my $item = $2;
			#print $todofp "$item +$desig #$epoch#\n";
		#}
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

# open the phonebook to append
#open my $fh, ">>", $phonebook
	#or die "can't open phonebook $phonebook: $!";

# open the todo.txt file, if requested
#if( $todofile !~ "none" ) {
	
	# read in the todo.txt file, if it exists
	#if(open $todofp, "<", $todofile) {
		#while( my $todoline = <$todofp>) {

			# is there a timestamp?
			#if($todoline =~ /\#([0-9]*)\#/) {
				#my $timestamp = $1;
			#}

			# if no timestamp, this one is a new item
			#else {
				#my $outline = $todoline;
				#my $prefix = "todo";
				#chomp($outline);
				#if($outline =~ /\+note/) {
					#$prefix = "note";
					#$outline =~ s/\+note//g);
				#}
				#elsif($outline =~ /\+name/) {
					#$prefix = "name";
				#}
				#elsif($outline =~ /\+todo/) {
					#$prefix = "todo";
				#}
				#elsif($outline =~ /\+weekday/) {
					#$prefix = "weekday";
				#}
				#elsif($outline =~ /\+weekend/) {
					#$prefix = "weekend";
				#}
				#elsif($outline =~ /\+daily/) {
					#$prefix = "daily";
				#}
				#print $fh "$prefix\t$outline #$epoch#\n";
			#}
		#}
		#close $todofp;
	#}

	# re-open the todo file for writing
	#if(!open $todofp, ">", $todofile) {
		#print "couldn't open todo.txt file!\n";
		#$todofile = "none";
	#}
#}

