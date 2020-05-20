#!/usr/bin/env lua

local awful     = require("awful")
local dpi       = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local naughty   = require("naughty")
local watch     = require("awful.widget.watch")
local wibox     = require("wibox")

local Memory = {}
Memory.__index = Memory

function Memory:new(args)
	return setmetatable({}, {__index = self}):init(args)
end

function Memory:init(args)
	self.colors = args.colors or {
		beautiful.fg_focus,
		beautiful.fg_normal,
		beautiful.bg_focus,
	}

	self.border_width = args.border_width or beautiful.border_width or 0
	self.border_color = args.border_color or beautiful.border_color or 0
	self.font = args.font or beautiful.font

	-- change the widget size, pie chart is resized by the height
	local widget_height = args.height or 150
	
	self.widget = wibox {
		height  = dpi(widget_height),
		width   = dpi(widget_height * 3),
		ontop   = true,
		expand  = true,
		
		fg = args.fg or beautiful.fg_normal,
		bg = args.bg or beautiful.bg_normal,
		
		border_width    = self.border_width,
		border_color    = self.border_color,
		max_widget_size = 500
	}

	self.widget:setup {
		border_width = self.border_width,
		colors       = self.colors,
		font         = self.font,

		display_labels = true,
		id             = 'pie',
		widget         = wibox.widget.piechart
	}

	self.visible = false

	return self
end

function Memory:format(free_stdout)
	local mem_table = {}

	-- > free # stdout example, some whitespaces omitted
	--        total    used   free     shared  buff/cache  available
	-- Mem:   1006536  69664  845824   428     91048       819760
	-- Swap:  2013180  0      2013180

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

	local format = function(t, key)
		local value = t[key]
		local str = string.format(
			"%s: %3.2f%% (%3.1f GB)",
			key,
			(value / t["Total"]) * 100,
			(value / 1048576)
		)

		return { str, value }
	end

	local display_fields = {
		"Used",
		"Free",
		"Shared",
		"Buff"
	}
	
	local t = {}

	for _, key in ipairs(display_fields) do
		table.insert(t, format(mem_table, key))
	end
	
	return t
end

function Memory:show()
	self.visible = true

	-- placement goes here to "follow" the focused screen
	awful.placement.top_right(
		self.widget,
		{
			margins = {top = 25, right = 10},
			parent = awful.screen.focused()
		}
	)

	awful.spawn.easy_async(
		[[ bash -c "free | grep -z Mem.*Swap.*" ]],
		function(stdout, stderr, reason, exit_code)
			self.widget.pie.data_list = self:format(stdout)
			-- avoids race conditions
			self.widget.visible = self.visible
		end
	)
end

function Memory:hide()
	self.visible = false
	self.widget.visible = false
end

function Memory:toggle()
	self.widget.visible = not self.widget.visible
end

function Memory:attach(widget)
	local show = function()
		self:show()
	end

	local hide = function()
		self:hide()
	end

	local toggle = function()
		self:toggle()
	end

	widget:connect_signal("mouse::enter", show)
	widget:connect_signal("mouse::leave", hide)
	widget:buttons(awful.util.table.join(awful.button({}, 1, toggle)))
end

return setmetatable(Memory, { __call = Memory.new })
