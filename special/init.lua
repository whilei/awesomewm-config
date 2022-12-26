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

local os                           = require("os")
local client, screen               = client, screen
local awful                        = require("awful")
local naughty                      = require("naughty")
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

-- fancy_float_toggle places the currently focused client nicely in front of me.
local fancy_float_toggle           = function(cc)
	local c = client.focus
	if not c then
		return
	end

	local turning_off = c.fancy_floating ~= nil

	if turning_off then
		c.fancy_floating  = nil

		c.screen          = c.original_screen or awful.screen.focused()
		c.original_screen = nil

		c.floating        = c.was_floating or false
		c.was_floating    = nil
		c.maximized       = c.was_maximized or false
		c.was_maximized   = nil

		c:raise()
		client.focus = c
		return
	end

	-- Else: turning ona
	c.fancy_floating  = true
	c.was_floating    = c.floating
	c.was_maximized   = c.maximized
	c.original_screen = c.screen or awful.screen.focused()

	c.maximized       = false
	c.floating        = true

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
			position  = "bottom_left",
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
			position = "bottom_left",
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

--local function delayed_screenshot(args)
--	local ss    = saved_screenshot(args)
--	local notif = naughty.notification {
--		title   = "Screenshot in:",
--		message = tostring(args.auto_save_delay) .. " seconds"
--	}
--
--	ss:connect_signal("timer::tick", function(_, remain)
--		notif.message = tostring(remain) .. " seconds"
--	end)
--
--	ss:connect_signal("timer::timeout", function()
--		if notif then
--			notif:destroy()
--		end
--	end)
--
--	return ss
--end

return {
	popup_launcher               = require("special.popup-launcher"),
	focus_previous_client_global = focus_previous_client_global,
	quake                        = require("special.widgets").quake,
	weather                      = require("special.widgets").weather,
	meridian                     = require("special.meridian"),
	toggle_wibar_slim            = toggle_wibar_slim,
	toggle_wibar_worldtimes      = toggle_wibar_worldtimes,
	reader_view_tall             = reader_view_tall,
	fancy_float                  = fancy_float_toggle,
	inspect_client               = inspect_client,
	saved_screenshot             = saved_screenshot,
}