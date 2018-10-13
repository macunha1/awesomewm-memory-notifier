# AwesomeWM Memory Notifier plug-in
---

Simple and minimalistic memory (RAM) popup notifier for Awesome window manager.

![Screenshot](/screenshot.png?raw=true "Screenshot")

This plugin was adapted from [deficient/calendar](https://github.com/deficient/calendar.git),
which is based on `calendar2.lua` module by Bernd Zeimetz and Marc Dequènes.

### Installation

Drop the script into your awesome config folder. Suggestion:

```bash
[ ! -d ~/.config/awesome/plugins ] && mkdir ~/.config/awesome/plugins
cd ~/.config/awesome/plugins
git clone https://github.com/macunha1/awesomewm-memory-notifier ~/.config/awesome/plugins/memory-notifier
```

### Usage

In your `rc.lua`:

```lua
-- load the widget code
local memory_wid = require("plugins.memory-notifier")

-- attach it as popup to your memory widget:
memory_wid({
    fg_color  = theme.fg_focus,  -- You can customize it with your theme's colors
    fg_normal = theme.fg_normal, -- Just like these, quite simple
}):attach(some_memory_widget)
```


### Requirements

* [awesome 4.0](http://awesome.naquadah.org/). May work on 3.5 with minor changes.

## Authors

* [**Matheus Cunha** ](https://github.com/macunha1)

See also the list of [contributors](https://github.com/macunha1/awesomewm-memory-notifier/contributors) who participated in this project.<Paste>
