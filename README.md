# AwesomeWM Memory Notifier plug-in
---

Simple and minimalistic Memory (RAM) notifier for AwesomeWM.

![Screenshot](/screenshot.png?raw=true "Screenshot")

RAM notifier plugin code initially was based on [deficient/calendar](https://github.com/deficient/calendar.git),
later Lain came in place to render markup easily.

### Installation

Drop the plugin code into your AwesomeWM config folder. e.g.:

```bash
[[ -d ~/.config/awesome/plugins ]] || mkdir ~/.config/awesome/plugins
cd ~/.config/awesome/plugins
git clone https://github.com/macunha1/awesomewm-memory-notifier ~/.config/awesome/plugins/memory-notifier
```

### Usage

And then import the plugin into your `rc.lua`:

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
