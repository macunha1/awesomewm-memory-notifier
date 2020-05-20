<h1 align="center">AwesomeWM Memory Notifier plug-in</h1>

Simple and minimalistic Memory (RAM) notifier for AwesomeWM.
Using [Wibox widget piechart](https://awesomewm.org/apidoc/widgets/wibox.widget.piechart.html) to display memory usage in GB and percentage.

![Screenshot](/screenshot.png?raw=true "Screenshot")

RAM notifier plugin code was initially based on [deficient/calendar](https://github.com/deficient/calendar.git),
displaying a small text using [Naughty](https://awesomewm.org/doc/api/libraries/naughty.html).

Later it evolved into a pie chart notification using [streetturtle](https://github.com/streetturtle/awesome-wm-widgets/blob/master/ram-widget/ram-widget.lua) implementation as an inspiration.

### Installation

Drop the plugin code into your AwesomeWM config folder. e.g.:

```bash
[[ -d ~/.config/awesome/plugins ]] || mkdir ~/.config/awesome/plugins
cd ~/.config/awesome/plugins
git clone https://github.com/macunha1/awesomewm-memory-notifier ~/.config/awesome/plugins/memory-notifier
```

If your AwesomeWM config is a git repository, you can add as a submodule with

``` bash
cd ~/.config/awesome

git submodule add -b master \
    -f --name memory-plugin \
    https://github.com/macunha1/awesomewm-memory-notifier \
    plugins/memory-notifier

git submodule sync --recursive .
```

### Usage

And then import the plugin into your `rc.lua`:

```lua
-- load the widget code
local memory_widget = require("plugins.memory-notifier")

-- attach it as popup to your memory widget:
mem_widget({
    colors = {
        theme.fg_focus,
        theme.bg_normal,
        theme.fg_normal,
    },
    font  = theme.font, -- not supported
    fg    = theme.fg_normal,
    bg    = theme.bg_focus,

    border_width = theme.border_width,
    border_color = theme.border_color
}):attach(ram_wid)
```

### Requirements

* [awesome 4.0](http://awesome.naquadah.org/). May work on 3.5 with minor changes.
