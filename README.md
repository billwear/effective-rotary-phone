# erp
<pre>
erp 1.01 - Copyright (C) 2016, Bill Wear
   [e]ffective [r]otary [p]hone - calls up data from bsd-calendar-like file
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

      designator\\tinformation (lines without a tab are ignored)

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
      erp items. [name] and [note] items are marked with [+name] or [+note], 
		respectively.  [todo] items are simply passed through with no changes.
      Dated items are passed through with "due:" and "t:" items set to today.
      Any todo.txt information in the line is treated as plain text and passed on;
      for example, if an erp line has [+cleangarage] in it, that will be passed to
      the todo.txt file as is, and presumably recognized as a project by the todo app.
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
      <td>20160418</td>
      <td colspan="2">-read long usage statement out of README.md in /usr/share/erp<br>
      -show short usage statement if README.md not found<br>
      -add processing for "daily" date format<br>
		-add processing for annual entries (0000mmdd)<br>
		-add processing for all-month entries (000000dd)<br>
		-add processing for daily wildcard date (00000000)<br>
      -eliminate continuation lines, too long for todo.txt apps<br>
      -add todo.txt output format</td>
   </tr>
   <tr>
      <td>1.00</td>
      <td>20160418</td>
      <td>promoting version 0.14 to version 1.0 (sufficient functionality)</td>
      <td></td>
   </tr>
   <tr>
      <td>1.01</td>
      <td>PLANNED</td>
      <td>enable rudimentary feedback capability:<br>
      *write the unix time for all entries as a #nnn...# entry at line end<br>
       (timestamp used for later sync capability)<br>
      *scan the todo.txt file for entries with no timestamp<br>
		*append newer items back to the .phonebook 
      -append newer items using relevant "+" entries<br>
       -- "+note" becomes a note item<br>
       -- "+name" becomes a name item<br>
       -- "+weekday","+daily","+[dow]","+[Ndow]","+[Ndow mon]","+weekend",<br>
          "+Nweekend","+yyyymmdd" become date designators in the .phonebook<br>
       -- "due:" or "t:" dates become date designators, also<br>
       -- "+todo" becomes a todo item<br>
       -- entries not marked with one of the above become todo items<br>
       -- if an item has multiple matches, the first one matched in the order<br>
          given above is the one used.
      </td>
   </tr>
</table>

