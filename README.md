# erp
<pre>
erp 0.14 - Copyright (C) 2016, Bill Wear
   [e]ffective [r]otary [p]hone - calls up data from structured todo.txt file
   erp is licensed under the MIT License, with no warranty.

   command line options:

      -d designator  show items of type [designator] (see below)

      -s tag         show only items containing [tag]
      
      -f phonebook   load [phonebook] instead of ~/.phonebook

      -t todofile    print output to [todofile] in a format compatible with
                     todo.txt apps using the due: and t: (threshold) notations

      -v             verbose output

      -h             print this usage message and exit

   phonebook structure:

      designator\\tinformation

      \\tcontinuation of last designator

      Note that lines without a tab are treated as comments and ignored.

   where [designator] is one of the following:
   
      name   someone's contact information
      [date] a date in one of the formats described below
      note   a note to keep & call up later
      todo   a to-do item

   date formats:

      yyyymmdd a specific date; substituting dashes for a digit has the
               effect of ignoring that part of the date (allowing repeats);
               for example, 0000mmdd = annual; 000000dd = ddth day of each month;
               00000000 matches every day of the year, but "daily" is easier.

      daily    every day of the year

      mon      name of any day; only looks at first three letters of the day.

      Nmon     Nth day of every month (eg, Nth monday); only looks at first
               three letters of the day; nonsense numbers (10) won't match.

      Nmon oct Nth day of given month; month can be string or number, only matches
               first three letters of a string; nonsense month won't match.

      weekday  every monday through friday; holidays not considered, so ymmv.

      weekend  every saturday and sunday.

      Nweekend Nth weekend of every month; nonsense numbers won't match.

   todo.txt output structure:

      the todo.txt output uses the +project, due: and t: meta-elements to encode
      erp items. [name] and [note] items are concatenated into one line (if there
      are continuation lines) and marked with [+name] or [+note] respectively.
      [todo] items are simply transferred to the todo.txt file with no changes. 
      Any todo.txt information in the line is treated as plain text and passed on;
      for example, if an erp line has [+cleangarage] in it, that will be passed to
      the todo.txt file as is, and presumably recognized as a project by the todo app.

      Items which imply a future date (such as "monday") are added to the todo.txt
      file for the next occurence of that date, with the threshold and due date set
      to the relevant day. Items which recur (such as "weekday" or "daily") are added 
      to the todo.txt file in the same manner, but repeated for seven days forward. 
      
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
      <td>PLANNED<br>
      1. read long usage statement out of README.md in /usr/share/erp<br>
      2. show short usage statement if README.md not found<br>
      3. add processing for "daily" date format<br>
		4. add processing for annual entries (0000mmdd)<br>
		5. add processing for all-month entries (000000dd)<br>
		6. add processing for daily wildcard date (00000000)<br>
      7. add todo.txt output format</td>
      <td></td>
   </tr>
</table>

