# erp
<pre>
erp 0.14 - Copyright (C) 2016, Bill Wear
   [e]ffective [r]otary [p]hone - calls up data from structured todo.txt file
   erp is licensed under the MIT License, with no warranty.

   -p project    show items matching +project
   -c context    show items matching @context
   -f todofile   load [todofile] instead of ~/todo.txt
   -v            verbose output
   -h            print this usage message and exit

   todo.txt structure:
      (P) yyyy-mm-dd task @context +project due:yyyy-mm-dd t:yyyy-mm-dd

   the following designators get special processing from erp:

      due:...   the item prints only if today's date matches the due date,
                e.g., due:2006-04-16 prints only on april 16, 2006.

      t:....    (threshold date) the item prints from threshold date forward,
                e.g., t:2006-05-17 prints from may 17, 2006 onward.

      due: t:   if both are present, the item prints from the threshold date
                until the due date has passed.

		+dow      (a day of the week) the item prints if dow matches the current
                day of the week, e.g., +thu prints every thursday.

      +Ndow     (nth day of the week) the item prints only on that particular day
                each month, e.g., +3sat prints on 3rd saturday of each month.

      +Ndowmon  (nth day of a particular month each year) the item prints only on
                the Nth occurence of that day of the week in the stated month, 
                e.g., 3satoct prints only on the third saturday in october.

      +weekday  (the word "weekday") the item prints on monday thru friday;
                erp is not aware of weekday holidays, so ymmv.

      +weekend  (the word "weekend") the item prints on saturday and sunday;
                the nth weekend function in previous versions has been deprecated.

      +0000mmdd an annual event; prints every year on this calendar date.

      +000000dd a monthly event; prints every month on this calendar day.

      +warnN    (the word "less" followed by a number) warning days; if any 
                recognizable dates are found in the line, erp will print the line
                for N days preceding the earliest date referenced.

      +nagN     (the word "nag" followed by a number) nag-after days: erp will
                continue to print the item for N days after the latest due date
                given in the line.


</pre>

**version history**
<table>
	<tr>
		<th>Version</th>
		<th>date</th>
		<th>what changed?</th>
		<th>known bugs</th>
	</tr>
	<tr>
		<td>0.1</td>
		<td>20160405</td>
		<td>screens & captures command line options (gotta start somewhere, right?)</td>
		<td>---</td>
	</tr>
	<tr>
		<td>0.11</td>
		<td>20160413</td>
		<td>prints usage; reads phonebook file & prints it out</td>
		<td>---</td>
	</tr>
	<tr>
		<td>0.12</td>
		<td>20160413</td>
		<td>processes name, note, & todo designators correctly, including contin lines</td>
		<td>---</td>
	</tr>
	<tr>
		<td>0.13</td>
		<td>20160414</td>
		<td>date input working; today's date default (no option) output</td>
		<td>contin lines are making it through to the date processor(?)</td>
	</tr>
	<tr>
		<td>0.14</td>
		<td>PLANNED</td>
		<td>convert erp to be compatible with todo.txt files (pre-existing mobile app)</td>
		<td></td>
	</tr>
</table>

