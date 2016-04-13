# erp

erp 0.11 - Copyright (C) 2016, Bill Wear
   [e]ffective [r]otary [p]hone - consults '.phonebook' for stored info
   erp is licensed under the MIT License, with no warranty.

   -d designator show items of type <designator> (see below)
   -t tag        show only items containing <tag>
   -f phonebook  load <phonebook> instead of ~/.phonebook
   -v            verbose output
   -h            print this usage message and exit

   phonebook structure:
      designator\tinformation
      \tcontinuation of last designator

   where <designator> is one of the following:
      name   someone's contact information
      [date] a date in one of the formats described below
      note   a note to keep & call up later
      todo   a to-do item

   date formats:
      yyyymmdd  a specific date; substituting dashes for a digit has the
                effect of ignoring that part of the date (allowing repeats);
                for example, 0000mmdd = annual; 000000dd = ddth day of each month.

      mon       name of any day; only looks at first three letters of the day

      Nmon      Nth day of every month (eg, Nth monday); only looks at first
                three letters of the day; nonsense numbers match last such day.

      Nmon oct  Nth day of given month; month can be string or number, only matches
                first three letters of a string; nonsense month = every month.

      weekday   every monday through friday; holidays not considered, so ymmv.

      weekend   every saturday and sunday.

      Nweekend  Nth weekend of every month; defaults to last if N is nonsensical.

**version history**
<table><tr>
<th>Version</th><th>date</th><th>what changed?</th>
</tr><tr>
<td>0.1</td><td>20160405</td><td>screens & captures command line options<br>
(gotta start somewhere, right?)</td>
<td>0.11</td><td>20160413</td><td>prints usage; reads phonebook file & prints it out<br>
</tr>
</table>

