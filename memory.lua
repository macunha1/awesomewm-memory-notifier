-- captures
local os   = os
local capi = {
    mouse = mouse,
    screen = screen,
}
local awful = require("awful")
local naughty = require("naughty")

------------------------------------------
-- memory popup widget
------------------------------------------

local memory = {}

function memory:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function memory:init(args)
    self.num_lines  = 0
    self.fg_normal  = args.fg_normal  or "#bbbbbb"
    self.fg_color   = args.fg_color   or "#00ff00"
    -- first day of week: monday=1, …, sunday=7
    self.html       = args.html       or '<span font_desc="monospace">\n%s</span>'
    -- highlight current date:
    self.status_tpl = args.status_tpl or '<span color="' .. self.fg_color .. '">%s</span>'
    return self
end

function memory:show()
    awful.spawn.easy_async([[ bash -c "free | grep -z Mem.*Swap.*" ]],
        function(stdout, stderr, reason, exit_code)
            total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
                stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')

            local mem_display = string.format(
            '<b><span color="' .. self.fg_normal .. '">Used:</span></b>\t' ..
            self.status_tpl:format("%.3f\tGB\n") ..
            '<b><span color="' .. self.fg_normal .. '">Buff:</span></b>\t' ..
            self.status_tpl:format("%.3f\tGB\n") ..
            '<b><span color="' .. self.fg_normal .. '">Free:</span></b>\t' ..
            self.status_tpl:format("%.3f\tGB\n") ..
            '<b><span color="' .. self.fg_normal .. '">Swap:</span></b>\t' ..
            self.status_tpl:format("%06.3f\tMB\n\n") ..
            '<b><span color="' .. self.fg_normal .. '">Total:</span></b>\t' ..
            self.status_tpl:format("%.3f\tGB"),
            used/1048576, buff_cache/1048576, free/1048576, used_swap/1024, total/1048576 -- 1048576 = 1024 * 1024 (since free prints in kB)
            )
            local mem_text = self.html:format(mem_display)

            -- NOTE: `naughty.replace_text` does not update bounds and can therefore
            -- not be used when the size increases (before #1756 was merged):
            local num_lines = select(2, mem_text:gsub('\n', ''))
            if naughty.replace_text and self.notification then
                naughty.replace_text(self.notification, title, mem_text)
            else
                self:hide()
                self.notification = naughty.notify({
                    title = "Memory status",
                    text = mem_text,
                    timeout = 0,
                    hover_timeout = 0.5,
                    screen = capi.mouse.screen,
                })
                self.num_lines = num_lines
            end
    end)
end

function memory:hide()
    if self.notification then
        naughty.destroy(self.notification)
        self.notification = nil
        self.num_lines = 0
    end
end

function memory:attach(widget)
    widget:connect_signal('mouse::enter', function() self:show() end)
    widget:connect_signal('mouse::leave', function() self:hide() end)
    widget:buttons(awful.util.table.join(
        awful.button({         }, 1, function() self:show() end)
    ))
end

return setmetatable(memory, {
    __call = memory.new,
})
