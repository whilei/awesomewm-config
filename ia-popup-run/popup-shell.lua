-------------------------------------------------
-- Popup Shell for Awesome Window Manager
-- Makes it easier for me to see my Run prompt

-- @author IA
-- @copyright 2022 IA
-------------------------------------------------

local awful = require("awful")
local gfs = require("gears.filesystem")
local wibox = require("wibox")
local gears = require("gears")

local my_shell_prompt_widget = awful.widget.prompt()

local w = wibox {
	bg = '#0000ff',
	border_width = 1,
	border_color = '#e019c9',
	max_widget_size = 500,
	ontop = true,
	height = 50,
	width = 250,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 3)
	end
}

w:setup {
	{
		layout = wibox.container.margin,
		left = 10,
		my_shell_prompt_widget,
	},
	id = 'left',
	layout = wibox.layout.fixed.horizontal
}

local function clear()
	w.visible = false
end

local function launch()
	w.visible = true

	awful.placement.bottom(w, { margins = {bottom = 40}, parent = awful.screen.focused()})
	awful.prompt.run{
		prompt = "$ ",
		bg_cursor = '#e019c9',
		fg_cursor = '#e019c9',
		textbox = my_shell_prompt_widget.widget,
		history_path = gfs.get_cache_dir() .. '/history',
		history_max = 500,
		completion_callback = awful.completion.shell,
		done_callback = clear
	}
end

return {
	launch = launch
}
