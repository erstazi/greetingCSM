# greetingCSM
Greeting CSM for Minetest Linux-Forks Server

## Installation
First, change directory to your minetest directory:
```
cd /path/to/your/minetest/
```
or
```
cd ~/.minetest/
```

Next, clone the repo to clientmods directory as follows:
```
git clone https://github.com/erstazi/greetingCSM ./clientmods/greeting
```
Note: it is best that the directory was named *greeting* in your clientmods directory.

Next, edit **clientmods/mods.conf** and add the following at the end:
```
load_mod_greeting = true
```

Optional: In **init.lua**, change the color to your favorite text color or what you use in colour_chat mod:
```
greeting.MY_COLOR = "#CCFFFF"
```

Then restart your client.


## Commands

### SetGreet
Set the Greet by either:

On (enables automatic greeting on new player join):
```
.setgreet on
```

Off (disables automatic greeting on new player join):
```
.setgreet off
```

Status:
```
.setgreet status
```

Set your favorite text color:
```
.setgreet color #CCFFFF
```

See what your text color is currently:
```
.setgreet color
```

Reset:
```
.setgreet reset
```

Full list of commands:
```
.setgreet [0|1|on|off|enable|disable|reset|debug|color|status|help]
```

### Intro (e.g. greeting)

Simplest command. Your default language used. Change *greeting.default_lang* from "en" default.
```
.intro username
```
or switch the language to do a greeting.
```
.intro de username
```
or allow override of the timeout/delay to do a greeting.
```
.intro de username override
```
or
```
.intro de username true
```
