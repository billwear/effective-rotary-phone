#!/bin/perl
use strict;
use warnings;
use POSIX;
use File::Basename;
use File::stat;
use Encode;

sub information() {
	print"SPECIAL NUMBERS\n";
	print"  Agendas.................6327\n";
	print"  Calorie.................6743\n";
	print"  Cuisine.................7463\n";
	print"  Finance.................2623\n";
	print"  Glucose.................2673\n";
	print"  Grocery.................4379\n";
	print"  Information..............411\n";
	print"  Listing.................8464\n";
	print"  Kitchen.................2436\n";
	print"  Journal.................7625\n";
	print"  Remarks.................2757\n";
}

sub agendas($) {
	my $cdow = strftime( "%a", localtime());
   my $cmoy = strftime( "%b", localtime());
   my $cday = strftime( "%d", localtime());
   my $cmonth = strftime( "%m", localtime());
   my $cyear = strftime( "%Y", localtime());
   my $ndow = strftime( "%u", localtime());
   my $epoch = strftime( "%s", localtime());

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
   $line =~ /^[^ ]* *([^ ]*) (.*)\n/;
   my $date = $1;
   my $item = $2;

   # recognize the date, if possible
   #

   # is it "daily"?
   if( $date =~ /daily/ ) {
   	$printflag = 1;
   }

   # is it a to-do item?
   if( $date =~ /todo/ ) {
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

   if( $printflag == 1 ) {
      $item =~ /([^:]*) *:([^:]*) *:([^\n]*)/;
      my $task = $1; my $value = $2; my $context = $3;
      if(!$value) { $value = "all"; }
      if(!$context) { $context = "anywhere"; }
      printf("%-8.8s | %-8.8s | %s\n", $value, $context, $task);
   }
}

sub calorie($) {
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ /([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\n]*)/;
	my $date=$1; my $time=$2;
   my $food=$3; my $portion=$4; my $gl=$5; my $carbs=$6; my $calories=$7; 
 	my $perishability=$8; my $sodium=$9;
   printf("%8.8s | %4.4s | %15.15s | %6.6s | GL %3.3s | %3.3s carbs | %3.3s cals | perish %4.4s | Na %5.5s\n",
        $date, $time, $food, $portion, $gl, $carbs, $calories, $perishability, $sodium );
}

sub cuisine($) {
	#cuisine food:serving:GL:GI:carbs:calories
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ /([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\n]*)/;
   my $food=$1; my $serving=$2; my $gl=$3; my $gi=$4; my $carbs=$5; my $calories=$6;
   printf("%15.15s | %6.6s | GL %3.3s | GI %3.3s | %3.3s carbs | %3.3s calories\n",
        $food, $serving, $gl, $gi, $carbs, $calories);
}

sub finance($) {
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ /([^\:]*): *([^\:]*): *([^\:]*): *([^\n]*)/;
   my $date=$1; my $description=$2; my $category=$3; my $amount=$4;
   printf("%8.8s | %12.12s | %12.12s | %6.6s\n", $date, $description, $category, $amount);
}

sub glucose($) {
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ /([^\:]*): *([^\:]*): *([^\n]*)/;
   my $date=$1; my $time=$2; my $bsr=$3; 
   printf("%8.8s | %4.4s | %3.3s\n", $date, $time, $bsr);
}

sub grocery($) {
	#grocery item:quantity needed
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ /([^\:]*): *([^\n]*)/;
   my $item=$1; my $quantity=$2;
   printf("%20.20s | %-20.20s\n", $item, $quantity);
}

sub listing($) {
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ s/\:/\n/g;
   print "$line\n";
}

sub kitchen($) {
	#kitchen food:portion:GL:carbs:calories:perishability:sodium
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   $line =~ /([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\:]*): *([^\n]*)/;
   my $food=$1; my $portion=$2; my $gl=$3; my $carbs=$4; my $calories=$5; 
 	my $perishability=$6; my $sodium=$7;
   printf("%15.15s | %6.6s | GL %3.3s | %3.3s carbs | %3.3s cals | perish %4.4s | Na %5.5s\n",
        $food, $portion, $gl, $carbs, $calories, $perishability, $sodium );
}

sub journal($) {
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   print $line;
}

sub remarks($) {
   my $line = shift;
   $line =~ s/^[A-Za-z0-9\-]* *//g;
   print $line;
}

sub lookup( $ ) {
   my $input = shift;
   my @xref;

   if($input =~ "agendas" || $input =~ "6327") {
      @xref = ( "agendas", "6327", \&agendas );
   }
   elsif($input =~ "information" || $input =~ "info" || $input =~ "411") {
      @xref = ( "information", "411", \&information );
   }
   elsif($input =~ "calorie" || $input =~ "6743") {
      @xref = ( "calorie", "6743", \&calorie );
   }
   elsif($input =~ "cuisine" || $input =~ "7463") {
      @xref = ( "cuisine", "7463", \&cuisine );
   }
   elsif($input =~ "finance" || $input =~ "2623") {
      @xref = ( "finance", "2623", \&finance );
   }
   elsif($input =~ "glucose" || $input =~ "2673") {
      @xref = ( "glucose", "2673", \&glucose );
   }
   elsif($input =~ "grocery" || $input =~ "4379") {
      @xref = ( "grocery", "4379", \&grocery );
   }
   elsif($input =~ "listing" || $input =~ "8464") {
      @xref = ( "listing", "8464", \&listing );
   }
   elsif($input =~ "kitchen" || $input =~ "2436") {
      @xref = ( "kitchen", "2436", \&kitchen );
   }
   elsif($input =~ "journal" || $input =~ "7625") {
      @xref = ( "journal", "7625", \&journal );
   }
   elsif($input =~ "remarks" || $input =~ "2757") {
      @xref = ( "remarks", "2757", \&remarks );
   }
   else {
      @xref = ( "listing", "8464", \&listing );
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
my ($mnemonic, $number, $coderef) = lookup( $input );

# answer an information call
if($number =~ 411) {
	information();
	exit();
}

# open the phonebook
open my $fh, "<", ".phonebook"
    || die "couldn't open .phonebook: $!\n";

while(my $line = <$fh>) {
   if( $line =~ /^$number / || $line =~ /^$mnemonic / ) {
      &$coderef($line);
   }
}

close $fh;
