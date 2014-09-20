Welcome to RandomFortune v@VERSION@

This addon will post a random fortune to guild about once an hour.

http://www.fortunecookiemessage.com/

Revision History
0.4     Options to say / use party/raid
        Options pane
0.3     BNSetCustomMessage
0.2     Options
0.1     Initial

Known Bugs:
Bug# - ver	- Desc
0001 - 0.03 - Crashed WoW Client if it tried to post a fortune when none was 
              in the age range.  Fixed for build #26.


To do:



FAQ:
(Or really, any question that has been asked)
Q: I hate to be ignorant but what do the numbers mean?
Count: 3
A: I just giggled.


/run BNSetCustomMessage("Hello friends!")


ToDo:
-- CronJOB style timer entry On Max time
--- Also use some extended syntax for this simular to Jenkins new style
--- S * * * *    <--- post hourly on the start minute (when you first login)
--- S/30 * * * * <--- post every 30 minutes based on start minute (rougly how it works now)
--- L * * * *    <--- post hourly on the minute of the last update (changed by forcing an update)
--- 
