---------------------------------------------------------------------------
-- Special
--
-- Special functions and (variable) instances that are primarily for me and how I like things.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod special
---------------------------------------------------------------------------

local os, tostring                 = os, tostring
local debug                        = debug
local client, screen               = client, screen
local awful                        = require("awful")
local gears                        = require("gears")
local naughty                      = require("naughty")
local ruled                        = require("ruled")
local wibox                        = require("wibox")

-- focus_previous_client_global is a function that returns the last
-- focused client _anywhere_.
-- It accesses the history list directly to
-- get the global history.
-- The usual function for "going back" (eg. Mod4+Tab),
-- uses awful.client.focus.history.previous(), which
-- (I assume) filters the history list, limiting the
-- clients to those of the same tag as the current client.
-- This is not what we want here.
-- I want to go back in history globally; no matter the tag or the screen.
-- Copy-pasta from https://unix.stackexchange.com/questions/623337/how-to-jump-to-previous-window-in-history-in-awesome-wm
local focus_previous_client_global = function()
	local c = awful.client.focus.history.list[2]
	if not c then
		return
	end
	local t = c and c.first_tag or nil
	if t then
		t:view_only()
	end
	client.focus = c
	c.visible    = true -- Except this, I added this.
	c:raise()
end

local toggle_wibar_slim            = function()
	local s = awful.screen.focused()
	if s.mywibox then
		s.mywibox.visible = not s.mywibox.visible
		if s.mywibox_slim then
			s.mywibox_slim.visible = not s.mywibox.visible
		end
	end
end

local toggle_wibar_worldtimes      = function()
	local s = awful.screen.focused()
	if s.mywibox_worldtimes then
		s.mywibox_worldtimes.visible = not s.mywibox_worldtimes.visible
	end
end

-- reader_view_tall is client function that positions the client
-- in a tall way, not taking up all the width though, especially
-- so that websites can be nice and skinny but use the height of the tv.
local reader_view_tall             = function(cc)
	local c = cc or client.focus

	awful.client.floating.toggle()
	awful.client.maximized = false

	if c.floating then
		-- place the screen in the middle
		local geo        = c:geometry()

		local screen_geo = c.screen.geometry

		geo.x            = screen_geo.x + screen_geo.width / 4
		geo.y            = screen_geo.y
		geo.width        = screen_geo.width * 2 / 4
		geo.height       = screen_geo.height

		c:geometry(geo)
	end
	client.focus = c
	c:raise()
end

-- reader_view_toggle places the currently focused client nicely in front of me.
local reader_view                  = function(cc)
	local c = client.focus
	if not c then
		return
	end

	local turning_off = c.reader_viewing ~= nil

	if turning_off then
		c.reader_viewing        = nil

		c.screen                = c.original_screen or awful.screen.focused()
		c.original_screen       = nil

		c.floating              = c.was_floating or false
		c.was_floating          = nil
		c.maximized             = c.was_maximized or false
		c.was_maximized         = nil
		c.ontop                 = c.was_ontop
		c.was_ontop             = nil
		c.border_color          = c.original_border_color
		c.border_width          = c.original_border_width
		c.original_border_color = nil
		c.original_border_width = nil
		c:geometry(c.was_geometry)
		c.was_geometry = nil

		return
	end

	-- Else: turning ona
	c.reader_viewing        = true

	c.was_geometry          = c:geometry()
	c.original_screen       = c.screen or awful.screen.focused()

	c.was_maximized         = c.maximized
	c.maximized             = false
	c.was_floating          = c.floating
	c.floating              = true
	c.was_ontop             = c.ontop
	c.ontop                 = true
	c.original_border_color = c.border_color
	c.border_color          = "#ffffff"
	c.original_border_width = c.border_width
	c.border_width          = 3


	-- Move to TV screen.
	if not c.screen.is_tv then
		for s in screen do
			if s.is_tv then
				c.screen = s
				c:raise()
				client.focus = c
			end
		end
	end

	-- On big screens (ie. the TV I use as a desktop monitor)
	-- adjust the window size and position to make for comfortable website reading.
	if c.screen.is_tv then
		local geo
		geo        = c:geometry()
		local sgeo
		sgeo       = c.screen.workarea

		geo.x      = sgeo.x + sgeo.width / 4
		geo.y      = sgeo.y + sgeo.height / 8
		geo.width  = sgeo.width / 2
		geo.height = sgeo.height * 7 / 8

		c:geometry(geo)
	end
end

local inspect_client               = function()
	if not client.focus then
		return
	end
	local c = client.focus
	local p = awful.popup {
		widget              = {
			{
				{
					text   = 'instance: ' .. c.instance,
					widget = wibox.widget.textbox,
				},
				{
					text   = 'class: ' .. c.class,
					widget = wibox.widget.textbox,
				},
				{
					text   = 'name: ' .. c.name,
					widget = wibox.widget.textbox,
				},
				{
					text   = 'window: ' .. c.window,
					widget = wibox.widget.textbox,
				},
				{
					text   = 'pid: ' .. (c.pid or 'n/a'),
					widget = wibox.widget.textbox,
				},
				{
					text   = 'role: ' .. (c.role or 'n/a'),
					widget = wibox.widget.textbox,
				},
				layout = wibox.layout.fixed.vertical,
			},
			margins = 10,
			widget  = wibox.container.margin,
		},
		screen              = client.focus.screen,
		placement           = awful.placement.bottom,
		visible             = true,
		ontop               = true,
		hide_on_right_click = true,

		border_color        = '#FF0000',
		border_width        = 10,
	}
	awful.keygrabber {
		autostart     = true,
		stop_key      = "Escape",
		stop_event    = "press",
		stop_callback = function()
			p.visible = false
			p         = nil
		end,
	}
end

local function saved_screenshot(args)
	local ss = awful.screenshot(args)

	local function notify(self)
		naughty.notification {
			title     = self.file_path,
			message   = "Screenshot saved",
			icon      = self.surface,
			bg        = "#ffffff",
			fg        = "#000000",
			icon_size = 128,
			position  = "bottom_right",
		}
	end

	local function copy_to_clipboard(self)
		local cmd = "xclip -selection clipboard -t image/png -i " .. self.file_path
		print("copying screenshot to clipboard", self.file_path)
		os.execute(cmd)

		naughty.notification {
			title    = self.file_name,
			message  = "Screenshot copied to clipboard",
			bg       = "#058B04",
			fg       = "#000000",
			position = "bottom_right",
		}
	end

	if args.auto_save_delay > 0 then
		ss:connect_signal("file::saved", notify)
		ss:connect_signal("file::saved", copy_to_clipboard)
	else
		notify(ss)
		copy_to_clipboard(ss)
	end

	return ss
end

local function delayed_screenshot(args)
	local ss    = saved_screenshot(args)
	local notif = naughty.notification {
		title    = "Screenshot in:",
		message  = tostring(args.auto_save_delay) .. " seconds",
		bg       = "#ffffff",
		fg       = "#000000",
		position = "bottom_right",
	}

	ss:connect_signal("timer::tick", function(_, remain)
		notif.message = tostring(remain) .. " seconds"
	end)

	ss:connect_signal("timer::timeout", function()
		if notif then
			notif:destroy()
		end
	end)

	return ss
end

local time_instance = os.clock()

-- log_load_time logs the time since this function was last called.
-- An optional message may be provided for context.
local function log_load_time(message)
	-- '2' goes up one level in the stack (thread=2).
	--[[
	level 0 is the current function (getinfo itself);
	level 1 is the function that called getinfo; and so on
	http://www.lua.org/manual/5.1/manual.html#pdf-debug.getinfo
	--]]
	local d       = debug.getinfo(2)
	local src     = string.gsub((d.short_src or d.source), gears.filesystem.get_configuration_dir(), "")
	local line    = d.currentline
	local msg     = string.format("⏲  %s:%4d %.2fs %s",
								  src,
								  line,
								  os.clock() - time_instance,
								  (message and "[" .. message .. "]" or "")
	)
	time_instance = os.clock()
	print(msg)
end

local function log_load_time_reset()
	time_instance = os.clock()
end

-- raise raises the client for some rules if it exists.
-- If it does not exist, a notification is displayed.
local function raise(client_rules)
	return function()
		local filter = function(c)
			return ruled.client.match(c, client_rules)
		end
		for c in awful.client.iterate(filter) do
			c:jump_to(false)
			return -- early because there can/should be only one
		end

		-- No client was matched.
		naughty.notification {
			title   = "No " .. (client_rules.name or client_rules.class or "unhandled printy sorry") .. " client found",
			message = "Is it started? This function does not run anything, just finds and focuses stuff.",
			preset  = naughty.config.presets.normal,
			timeout = 3,
		}
	end
end

--function copy(obj, seen)
--	if type(obj) ~= 'table' then
--		return obj
--	end
--	if seen and seen[obj] then
--		return seen[obj]
--	end
--	local s   = seen or {}
--	local res = setmetatable({}, getmetatable(obj))
--	s[obj]    = res
--	for k, v in pairs(obj) do
--		res[copy(k, s)] = copy(v, s)
--	end
--	return res
--end

-- Save copied tables in `copies`, indexed by original table.
-- http://lua-users.org/wiki/CopyTable
local function deepcopy(orig, copies)
	copies          = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy         = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
			end
			setmetatable(copy, deepcopy(getmetatable(orig), copies))
		end
	else
		-- number, string, boolean, etc
		copy = orig
	end
	return copy
end

return {
	popup_launcher               = require("special.popup-launcher"),
	quake                        = require("special.widgets").quake,
	weather                      = require("special.widgets").weather,
	meridian                     = require("special.meridian"),
	pretty                       = require("special.pretty"),
	focus_previous_client_global = focus_previous_client_global,
	toggle_wibar_slim            = toggle_wibar_slim,
	toggle_wibar_worldtimes      = toggle_wibar_worldtimes,
	reader_view_tall             = reader_view_tall,
	reader_view                  = reader_view,
	inspect_client               = inspect_client,
	saved_screenshot             = saved_screenshot,
	delayed_screenshot           = delayed_screenshot,
	log_load_time                = log_load_time,
	log_load_time_reset          = log_load_time_reset,
	raise                        = raise,
	deepcopy                     = deepcopy,
}