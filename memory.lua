#!/usr/bin/env lua

local os = os
local capi = {
    mouse = mouse,
    screen = screen
}
local awful   = require("awful")
local lain    = require("lain")
local naughty = require("naughty")

local Memory = {}
Memory.__index = Memory

function Memory:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function Memory:init(args)
    self.fg_normal  = args.fg_normal or "#ffffff"
    self.fg_color   = args.fg_color or "#00ff00"
    self.font       = args.font or "monospace"

    return self
end

function Memory:fmt(free_stdout)
    local mem_table = {}

    -- > free # stdout example
    --               total        used        free      shared  buff/cache   available
    -- Mem:        1006536       69664      845824         428       91048      819760
    -- Swap:       2013180           0     2013180

    mem_table["\nTotal"],
        mem_table["Used"],
        mem_table["Free"],
        mem_table["Shared"],
        mem_table["Buff"], -- buff/cache
        mem_table["Available"],
        mem_table["Swap Total"],
        mem_table["Swap Used"],
        mem_table["Swap Free"] =
        free_stdout:match("(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

    local display_order = {
        "Used",
        "Buff",
        "Free",
        "\nTotal",
    }
    local t = {}

    for _, key in ipairs(display_order) do
        table.insert(
            t,
            lain.util.markup.fontfg(
                self.font,
                self.fg_normal,
                lain.util.markup.bold(key .. ":\t")
            )
        )

        -- 1 GB = 1048576 = 1024 * 1024 (since free prints in kB)
        table.insert(
            t,
            lain.util.markup.fontfg(
                self.font,
                self.fg_color,
                string.format(
                    "%.3f\t<b>GB</b>",
                    mem_table[key] / 1048576
                )
            ) .. "\n"
        )
    end

    return table.concat(t)
end

function Memory:show()
    awful.spawn.easy_async(
        [[ bash -c "free | grep -z Mem.*Swap.*" ]],
        function(stdout, stderr, reason, exit_code)
            local title = "Memory status"
            local mem_text = lain.util.markup.font(
                self.font,
                "\n" .. self:fmt(stdout)
            )

            if naughty.replace_text and self.notification then
                naughty.replace_text(
                    self.notification,
                    title,
                    mem_text
                )
            else
                self:hide()
                self.notification = naughty.notify({
                    title = title,
                    text = mem_text,
                    timeout = 2,
                    hover_timeout = 0.5,
                    screen = capi.mouse.screen
                })
            end
        end
    )
end

function Memory:hide()
    if self.notification then
        naughty.destroy(self.notification)
        self.notification = nil
    end
end

function Memory:attach(widget)
    local show = function()
        self:show()
    end

    local hide = function()
        self:hide()
    end

    widget:connect_signal("mouse::enter", show)
    widget:connect_signal("mouse::leave", hide)
    widget:buttons(awful.util.table.join(awful.button({}, 1, show)))
end

return setmetatable(
    Memory,
    {
        __call = Memory.new
    }
)
