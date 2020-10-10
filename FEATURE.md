# Features

## Options
Move the options to the options panel.

### Delay
Make the delay field display and take a string with  #<unit> #<unit> format.
30m 5s   would be valid

5s30m would also be valid, but would convert to 30m 5s when used.

No unit would default to number of seconds, but would still expand to the formatted number when used.

### Commands
``/rf status`` and ``/rf`` will now open the options panel.

## ChatInterface
Allow {RF} and {RF#nnnn} tokens to be expanded to random fortunes in chat.

## Guild
Gives an option to black list a guild on a realm.

## postNum
Allow the user to post a specific fortune by number.
Use ``\rf find <string>`` to find the fortune entry.
Use ``\rf now <number>`` to post that number fortune.

