# erp
<pre>
erp 1.00 - Copyright (C) 2016, Bill Wear
   [e]ffective [r]otary [p]hone - calls up data from structured todo.txt file
   erp is licensed under the MIT License, with no warranty.

   command line options:

      -d designator  show items of type [designator] (see below)

      -f phonebook   load [phonebook] instead of ~/.phonebook

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
      <td>1.10</td>
      <td>IN PROGRESS</td>
      <td>swich to command line "command-words"<br>
      <td>refactor the code a bit</td>
      <td>---</td>
   </tr>
</table>

