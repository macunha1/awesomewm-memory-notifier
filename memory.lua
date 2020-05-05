#!/usr/bin/env lua

local os = os
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local naughty = require("naughty")

Memory = {}
Memory.__index = Memory

function Memory:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function Memory:init(args)
    self.num_lines = 0
    self.fg_normal = args.fg_normal or "#bbbbbb"
    self.fg_color = args.fg_color or "#00ff00"
    self.html = args.html or '<span font_desc="monospace">\n%s</span>'
    self.status_tpl = args.status_tpl or '<span color="' .. self.fg_color .. '">%s</span>'
    return self
end

function Memory:fmt(free_stdout)
    local mem_table = {}

    -- > free # stdout example
    --               total        used        free      shared  buff/cache   available
    -- Mem:        1006536       69664      845824         428       91048      819760
    -- Swap:       2013180           0     2013180

    mem_table["Total"],
        mem_table["Used"],
        mem_table["Free"],
        mem_table["Shared"],
        mem_table["Buff"], -- buff/cache
        mem_table["Available"],
        mem_table["Swap Total"],
        mem_table["Swap Used"],
        mem_table["Swap Free"] =
        free_stdout:match("(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

    local t = {}
    for key, value in pairs(mem_table) do
        table.insert(t, '<b><span color="')
        table.insert(t, self.fg_normal)
        table.insert(t, '">')
        table.insert(t, key)
        table.insert(t, ":</span></b>\t")
        -- 1 GB = 1048576 = 1024 * 1024 (since free prints in kB)
        table.insert(t, string.format(self.status_tpl:format("%.3f\tGB\n"), value / 1048576))
    end

    return table.concat(t)
end

function Memory:show()
    awful.spawn.easy_async(
        [[ bash -c "free | grep -z Mem.*Swap.*" ]],
        function(stdout, stderr, reason, exit_code)
            local mem_text = self.html:format(Memory:fmt(stdout))
            local num_lines = select(2, mem_text:gsub("\n", ""))

            if naughty.replace_text and self.notification then
                naughty.replace_text(self.notification, title, mem_text)
            else
                self:hide()
                self.notification =
                    naughty.notify(
                    {
                        title = "Memory status",
                        text = mem_text,
                        timeout = 0,
                        hover_timeout = 0.5,
                        screen = capi.mouse.screen
                    }
                )
                self.num_lines = num_lines
            end
        end
    )
end

function Memory:hide()
    if self.notification then
        naughty.destroy(self.notification)
        self.notification = nil
        self.num_lines = 0
    end
end

function Memory:attach(widget)
    widget:connect_signal(
        "mouse::enter",
        function()
            self:show()
        end
    )

    widget:connect_signal(
        "mouse::leave",
        function()
            self:hide()
        end
    )

    widget:buttons(
        awful.util.table.join(
            awful.button(
                {},
                1,
                function()
                    self:show()
                end
            )
        )
    )
end

return setmetatable(
    Memory,
    {
        __call = Memory.new
    }
)
