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

local client, screen               = client, screen
local awful                        = require("awful")
local lain                         = require("lain")
local gears                        = require("gears")

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
	local t = c and c.first_tag or nil
	if t then
		t:view_only()
	end
	client.focus = c
	c.visible    = true -- Except this, I added this.
	c:raise()
end

local quake                        = lain.util.quake({
														 app             = "konsole",
														 name            = "xterm-konsole",
														 extra           = "--hide-menubar --hide-tabbar",
														 followtag       = true,
														 vert            = "bottom",
														 keepclientattrs = true,
														 border          = 0,
														 screen          = awful.screen.focused() or screen[1],
														 settings        = function(c)

															 -- these don't work. don't know why.
															 c.opacity           = 0.7
															 c.border_width      = 2
															 c.border_color      = "#000000"
															 c.titlebars_enabled = false
															 c.skip_taskbar      = true
															 c.shape             = function(cc, w, h)
																 return gears.shape.partially_rounded_rect(
																		 cc, w, h, true, true, false, false, 10
																 )
															 end

															 ---- Make it smaller for the tv screen.
															 --local geo           = c:geometry()
															 --if c.screen.is_tv or c.screen.workarea.width > 3000 then
															 -- geo.x      = geo.x + (geo.width / 4)
															 -- geo.width  = geo.width / 2
															 -- geo.height = c.screen.workarea.height / 3
															 -- c:geometry(geo)
															 --end

															 --awful.placement.align(c, {
															 -- position       = "bottom",
															 -- honor_padding  = true,
															 -- honor_workarea = true,
															 --})
														 end
													 })

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
local reader_view_tall             = function(c)
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

local fancy_float_toggle           = function(c)

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
	c.original_screen = c.screen or awful.screen.focused()
	c.was_floating    = c.floating
	c.was_maximized   = c.maximized

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

return {
	popup_launcher               = require("special.popup-launcher"),
	focus_previous_client_global = focus_previous_client_global,
	quake                        = quake,
	toggle_wibar_slim            = toggle_wibar_slim,
	toggle_wibar_worldtimes      = toggle_wibar_worldtimes,
	reader_view_tall             = reader_view_tall,
	fancy_float_toggle           = fancy_float_toggle,
}