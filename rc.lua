--[[

     Awesome WM configuration template
     github.com/lcpz

--]]

-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- {{{ Required libraries
local awesome, screen, client, mouse, screen, tag, titlebar = awesome, screen, client, mouse, screen, tag, titlebar
local ipairs, pairs, string, os, table                      = ipairs, pairs, string, os, table
local tostring, tonumber, tointeger, type, math             = tostring, tonumber, tointeger, type, math
local gears                                                 = require("gears")

-- This chunk adds this path (of the current configuration)
-- to the Lua packages search path, enabling the loading of local libs.
local prefix                                                = gears.filesystem.get_configuration_dir() .. ""
package.path                                                = package.path .. ";" .. prefix .. "?.lua;" .. prefix .. "?/init.lua"

local awful                                                 = require("awful")
local a_util_table                                          = awful.util.table or gears.table -- 4.{0,1} compatibility
local _                                                     = require("awful.autofocus")
local wibox                                                 = require("wibox")
local beautiful                                             = require("beautiful")
local naughty                                               = require("naughty")
local lain                                                  = require("lain")
local freedesktop                                           = require("freedesktop")
local hotkeys_popup                                         = require("awful.hotkeys_popup").widget
local revelation                                            = require("revelation")
local hints                                                 = require("hints")
local cairo                                                 = require("lgi").cairo

local ia_layout_swen                                        = require("layout-swen")
local ia_layout_vcolumns                                    = require("columns-layout")
local layout_titlebars_conditional                          = require("layout-titlebars-conditional")
local special                                               = require("special")

local icky_keys                                             = require("icky.keys")
local icky_fns                                              = require("icky.fns").global

local modality                                              = require("modality")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
					   preset = naughty.config.presets.critical,
					   title  = "Awesome errored during startup",
					   text   = awesome.startup_errors
				   })
end

do
	local in_error = false
	awesome.connect_signal("debug::error",
						   function(err)
							   if in_error then
								   return
							   end
							   in_error = true

							   naughty.notify({
												  preset = naughty.config.presets.critical,
												  title  = "Awesome error",
												  text   = tostring(err)
											  })
							   in_error = false
						   end)
end
-- }}}

if not awful.client.focus.history.is_enabled() then
	awful.client.focus.history.enable_tracking()
end


-- {{{ Variable definitions

local chosen_theme      = "ia"
local modkey            = "Mod4"
local altkey            = "Mod1"
local terminal          = "xterm"
local editor            = os.getenv("EDITOR") or "vim"
local gui_editor        = "code"
local browser           = "ffox"
local guieditor         = "code"
local scrlocker         = "xlock"

local clientkeybindings = {}
-- clientkeybindings["z"] = "Konsole"
-- clientkeybindings["a"] = "Google Chrome"
-- clientkeybindings["e"] = "Emacs"

for key, app in pairs(clientkeybindings) do
	awful.key({ "Control", "Shift" },
			  key,
			  function()
				  local matcher = function(c)
					  return awful.rules.match(c, { class = app })
				  end
				  awful.client.run_or_raise(app, matcher)
			  end)
end

awful.util.terminal = terminal

-- These tag names are now only used for reference by widgets and things
-- that need to name the indexes of the tags.
-- The logic here is assumed to be tightly coupled with
-- the tag screen-setup logic defined in ia/theme.lua,
-- which assigns tags per screen, using custom naming tables.
awful.util.tagnames = { "1", "2", "3", "4", "5" }
--awful.util.tagnames = { "●", "●", "●", "●", "●" }
--awful.util.tagnames = { "❶", "❷", "❸", "❹", "❺" }
--awful.util.tagnames = { "▇", "▇", "▇", "▇", "▇" }

local _layouts      = {
	tiler = layout_titlebars_conditional { layout = awful.layout.suit.tile },
	swen  = layout_titlebars_conditional { layout = ia_layout_swen },
}

tag.connect_signal("request::default_layouts",
				   function()
					   awful.layout.append_default_layouts {
						   _layouts.tiler,
						   _layouts.swen,
						   lain.layout.centerwork,
						   awful.layout.suit.magnifier,
						   awful.layout.suit.floating,
					   }
				   end)

awful.util.taglist_buttons  = a_util_table.join(
		awful.button({}, 1, function(t)
			t:view_only()
		end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({}, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),
		awful.button({}, 4, function(t)
			awful.tag.viewnext(t.screen)
		end),
		awful.button({}, 5, function(t)
			awful.tag.viewprev(t.screen)
		end))

awful.util.tasklist_buttons = a_util_table.join(
		awful.button({}, 1, function(c)
			if c == client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no senseF
				c.minimized = false
				if not c:isvisible() and c.first_tag then
					c.first_tag:view_only()
				end
				-- This will also un-minimize
				-- the client, if needed
				client.focus = c
				c:raise()
			end
		end))

local theme_path            = gears.filesystem.get_configuration_dir() .. "themes/" .. chosen_theme .. "/theme.lua"
beautiful.init(theme_path)
--revelation.init()
--hints.init()
modality.init()

local toggle_wibar_slim_fn = function()
	local s                = awful.screen.focused()
	s.mywibox.visible      = not s.mywibox.visible
	s.mywibox_slim.visible = not s.mywibox.visible
end

local fullscreen_fn        = function(c)
	c.fullscreen = not c.fullscreen
	c:raise()

	if c.screen and c.screen.mywibox.visible then
		toggle_wibar_slim_fn()
	end
end

local toggle_worldtimes_fn = function()
	local s                      = awful.screen.focused()
	s.mywibox_worldtimes.visible = not s.mywibox_worldtimes.visible
end

local fancy_float_toggle   = function(c)

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


-- Modality

local modalbind            = require("modalbind")
modalbind.init()
modalbind.set_location("bottom")
modalbind.hide_default_options()

local imodal_main
local imodal_awesomewm
local imodal_client_focus
local imodal_client_move_resize
local imodal_client_move
local imodal_client_toggle
local imodal_bars
local imodal_layout
local imodal_layout_adjust
local imodal_power
local imodal_screenshot
local imodal_tag
local imodal_toggle
local imodal_useless
local imodal_widgets
local imodal_volume

local to_main_menu        = { "<", function()
	modalbind.grab { keymap = imodal_main, name = "", stay_in_mode = false }
end, "main menu" }

local imodal_separator    = { "separator", "" }

imodal_awesomewm          = {
	--{ "i",, "inspect client" },

	--{ "k", hotkeys_popup.show_help, "hotkeys" },
	--{ "m", function()
	--	awful.util.mymainmenu:show()
	--end, "menu" },
	--{ "r", awesome.restart, "restart" },
}

imodal_client_move_resize = {
	--{ "1", function()
	--	if client.focus then
	--		local tag = client.focus.screen.tags[1]
	--		if tag then
	--			client.focus:move_to_tag(tag)
	--		end
	--	end
	--end, "move to " .. awful.util.tagnames[1] },
	--{ "2", function()
	--	if client.focus then
	--		local tag = client.focus.screen.tags[2]
	--		if tag then
	--			client.focus:move_to_tag(tag)
	--		end
	--	end
	--end, "move to " .. awful.util.tagnames[2] },
	--{ "3", function()
	--	if client.focus then
	--		local tag = client.focus.screen.tags[3]
	--		if tag then
	--			client.focus:move_to_tag(tag)
	--		end
	--	end
	--end, "move to " .. awful.util.tagnames[3] },
	--{ "4", function()
	--	if client.focus then
	--		local tag = client.focus.screen.tags[4]
	--		if tag then
	--			client.focus:move_to_tag(tag)
	--		end
	--	end
	--end, "move to " .. awful.util.tagnames[4] },
	--{ "5", function()
	--	if client.focus then
	--		local tag = client.focus.screen.tags[5]
	--		if tag then
	--			client.focus:move_to_tag(tag)
	--		end
	--	end
	--end, "move to " .. awful.util.tagnames[5] },

	--{ "f", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.floating = not client.focus.floating
	--	client.focus:raise()
	--end, "floating" },

	--{ "h", function()
	--	if not client.focus then
	--		return
	--	end ;
	--	client.focus.floating = true;
	--	client.focus.width    = client.focus.width - client.focus.screen.workarea.height / 10
	--	awful.placement.no_offscreen(client.focus)
	--end, "shrink ←" },
	--
	--{ "j", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.floating = true;
	--	client.focus.height   = client.focus.height + client.focus.screen.workarea.height / 10
	--	awful.placement.no_offscreen(client.focus)
	--end, "grow ↓" },
	--{ "k", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.floating = true;
	--	client.focus.height   = client.focus.height - client.focus.screen.workarea.height / 10
	--	awful.placement.no_offscreen(client.focus)
	--end, "shrink ↑" },
	--{ "l", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.floating = true;
	--	client.focus.width    = client.focus.width + client.focus.screen.workarea.height / 10
	--	awful.placement.no_offscreen(client.focus)
	--end, "grow →" },

	--{ "m", function()
	--	modalbind.close_box({})
	--	modalbind.grab { keymap = imodal_client_move, name = "Move client", stay_in_mode = true, hide_default_options = true }
	--end, "+move" },

	--{ "m", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.maximized = not client.focus.maximized
	--end, "maximized" },

	--{ "n", function()
	--	local cc = client.focus
	--	if not cc then
	--		return
	--	end
	--	awful.client.focus.history.previous()
	--	cc.focus = false
	--	cc:lower()
	--	cc.minimized = true
	--end, "minimized" },

	--{ "r", function()
	--	local c = awful.client.restore()
	--	-- Focus restored client
	--	if c then
	--		client.focus = c
	--		c:raise()
	--	end
	--end, "restore" },
	--
	--{ "s", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus:move_to_screen()
	--end, "swap screen" },

	--{ "C", function()
	--	if not client.focus then
	--		return
	--	end ;
	--	client.focus.floating = true;
	--	awful.placement.centered(client.focus)
	--end, "center" },
	--
	--{ "H", function()
	--	if not client.focus then
	--		return
	--	end ;
	--	client.focus.floating = true;
	--	awful.placement.left(client.focus)
	--end, "left" },
	--
	--{ "J", function()
	--	if not client.focus then
	--		return
	--	end ;
	--	client.focus.floating = true;
	--	awful.placement.bottom(client.focus)
	--end, "bottom" },
	--{ "K", function()
	--	if not client.focus then
	--		return
	--	end ;
	--	client.focus.floating = true;
	--	awful.placement.top(client.focus)
	--end, "top" },
	--{ "L", function()
	--	if not client.focus then
	--		return
	--	end ;
	--	client.focus.floating = true;
	--	awful.placement.right(client.focus)
	--end, "right" },
	--
	--{ "V", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.maximized_vertical = true
	--end, "maximize vertical" },
	--
	--{ "W", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.maximized_horizontal = true
	--end, "maximize horizontal" },
}

imodal_client_move        = {

}

imodal_client_toggle      = {
	--{ "f", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.floating = not client.focus.floating
	--	client.focus:raise()
	--end, "floating" },

	--{ "m", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.maximized = not client.focus.maximized
	--	client.focus:raise()
	--end, "maximized" },

	--{ "n", function(c)
	--	-- The client currently has the input focus, so it cannot be
	--	-- minimized, since minimized clients can't have the focus.
	--	local cc = c or client.focus
	--	if not cc then
	--		return
	--	end
	--	cc.focus = false
	--	cc:lower()
	--	cc.minimized = true
	--	awful.client.focus.history.previous()
	--end, "minimized" },

	--{ "o", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.ontop = not client.focus.ontop
	--end, "ontop" },

	--{ "s", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.sticky = not client.focus.sticky
	--end, "sticky" },

	--{ "t", function()
	--	if not client.focus then
	--		return
	--	end
	--	awful.titlebar.toggle(client.focus)
	--end, "titlebar" },

	--{ "F", function()
	--	if not client.focus then
	--		return
	--	end
	--	fullscreen_fn(client.focus)
	--end, "fullscreen" },
}


-- ➔
imodal_client_focus       = {

	--{ "f", function()
	--	modalbind.grab { keymap = imodal_client_focus, name = "Change (focus)", stay_in_mode = false, hide_default_options = true }
	--end, "Focus" },

	--{ "m", function()
	--	modalbind.grab { keymap = imodal_client_move, name = "Move", stay_in_mode = true, hide_default_options = true }
	--end, "Move" },

	--{ "Tab", special.focus_previous_client_global, "focus last" },
	--
	--{ "*", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus:swap(awful.client.getmaster())
	--end, "move client to master" },

	--{ "h", function()
	--	awful.client.focus.global_bydirection("left")
	--	if client.focus then
	--		client.focus:raise()
	--	end
	--end, "← focus left" },
	--
	--{ "i", icky_fns.client.hints, "hints" },
	--
	--{ "j", function()
	--	awful.client.focus.global_bydirection("down")
	--	if client.focus then
	--		client.focus:raise()
	--	end
	--end, "↓ focus down" },
	--{ "k", function()
	--	awful.client.focus.global_bydirection("up")
	--	if client.focus then
	--		client.focus:raise()
	--	end
	--end, "↑ focus up" },
	--{ "l", function()
	--	awful.client.focus.global_bydirection("right")
	--	if client.focus then
	--		client.focus:raise()
	--	end
	--end, "→ focus right" },

	--{ "n", function()
	--	awful.client.focus.byidx(1)
	--end, "next" },
	--
	--{ "p", function()
	--	awful.client.focus.byidx(-1)
	--end, "previous" },

	--{ "x", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus:kill()
	--end, "kill" },

	--{ "M", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus.maximized = not client.focus.maximized
	--end, "maximized" },

	--{ "N", function()
	--	local cc = client.focus
	--	if not cc then
	--		return
	--	end
	--	awful.client.focus.history.previous()
	--	cc.focus = false
	--	cc:lower()
	--	cc.minimized = true
	--end, "minimized" },

	--{ "R", function()
	--	local c = awful.client.restore()
	--	-- Focus restored client
	--	if c then
	--		client.focus = c
	--		c:raise()
	--	end
	--end, "restore (=unminimize) a client" },
}

imodal_layout             = {
	{ "a", function()
		modalbind.keygrabber_stop()
		modalbind.grab { keymap = imodal_layout_adjust, name = "Adjust Layout", stay_in_mode = true, hide_default_options = true }
	end, "+adjust" },

	--{ "c", function()
	--	awful.layout.set(lain.layout.centerwork)
	--end, "centerwork" },
	--{ "f", function()
	--	awful.layout.set(awful.layout.suit.floating)
	--end, "floating" },
	--{ "m", function()
	--	awful.layout.set(awful.layout.suit.magnifier)
	--end, "magnifier" },
	--{ "s", function()
	--	awful.layout.set(_layouts.swen)
	--end, "SWEN" },
	--{ "t", function()
	--	awful.layout.set(_layouts.tiler)
	--end, "tile" },
	--{ "v", function()
	--	awful.layout.set(ia_layout_vcolumns)
	--end, "v. columns" },

}

imodal_layout_adjust      = {
	--{ "h", function()
	--	awful.tag.incmwfact(-0.05)
	--end, "decrease master width factor" },
	--{ "j", function()
	--	awful.client.swap.byidx(1)
	--end, "swap client with next" },
	--
	--{ "k", function()
	--	awful.client.swap.byidx(-1)
	--end, "swap client with previous" },
	--{ "l", function()
	--	awful.tag.incmwfact(0.05)
	--end, "increase master width factor" },
	--{ "Tab", function()
	--	awful.layout.set(layout_bling_mstab)
	--end, "MS-Tab"},
}

imodal_power              = {
	--{ "l", function()
	--	awful.util.spawn_with_shell("sudo service lightdm restart")
	--end, "log out" },
	--{ "s", function()
	--	awful.util.spawn_with_shell("sudo systemctl suspend")
	--end, "suspend" },
	--{ "P", function()
	--	awful.util.spawn_with_shell("shutdown -P -h now")
	--end, "shutdown" },
	--{ "R", function()
	--	os.execute("reboot")
	--end, "reboot" },
}

imodal_screenshot         = {
	--{ "s", icky_fns.screenshot.selection, "selection" },
	--{ "w", icky_fns.screenshot.window, "window" },
}

imodal_volume             = {
	--{ "p", function()
	--	os.execute("amixer -q set Capture toggle")
	--	beautiful.mic.update()
	--end, "microphone toggle" },
	--{ "m", function()
	--	os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
	--	beautiful.volume.update()
	--end, "mute toggle" },
	--{ "Up", function()
	--	os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
	--	beautiful.volume.update()
	--end, "up" },
	--{ "Down", function()
	--	os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
	--	beautiful.volume.update()
	--end, "down" },
}

imodal_tag                = {
	{ "1", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[1]
		if tag then
			tag:view_only()
		end
	end, awful.util.tagnames[1] },
	{ "2", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[2]
		if tag then
			tag:view_only()
		end
	end, awful.util.tagnames[2] },
	{ "3", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[3]
		if tag then
			tag:view_only()
		end
	end, awful.util.tagnames[3] },
	{ "4", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[4]
		if tag then
			tag:view_only()
		end
	end, awful.util.tagnames[4] },
	{ "5", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[5]
		if tag then
			tag:view_only()
		end
	end, awful.util.tagnames[5] },
	imodal_separator,
	--{ "a", function()
	--	awful                                     .tag.add("NewTag", {
	--		screen = awful.screen.focused(),
	--		layout = awful.layout.suit.floating }):view_only()
	--end, "add tag" },
	--{ "d", function()
	--	local t = awful.screen.focused().selected_tag
	--	if not t then
	--		return
	--	end
	--	t:delete()
	--end, "delete tag" },
	--{ "n", awful.tag.viewnext, "next tag" },
	--{ "p", awful.tag.viewprev, "previous tag" },
	--{ "r", function()
	--	awful.prompt.run {
	--		prompt       = "New tag name: ",
	--		textbox      = awful.screen.focused().mypromptbox.widget,
	--		exe_callback = function(new_name)
	--			if not new_name or #new_name == 0 then
	--				return
	--			end
	--
	--			local t = awful.screen.focused().selected_tag
	--			if t then
	--				t.name = new_name
	--			end
	--		end
	--	}
	--end, "rename tag" },
	--{ "N", function()
	--	local c = client.focus
	--	if not c then
	--		return
	--	end
	--
	--	local t = awful.tag.add(c.class, { screen = c.screen })
	--	c:tags({ t })
	--	t:view_only()
	--end, "move client to new tag" },
}

imodal_toggle             = {
	--{ "c", function()
	--	os.execute(invert_colors)
	--end, "invert colors" },
}

imodal_useless            = {
	--{ "0", function()
	--	local scr            = awful.screen.focused()
	--	scr.selected_tag.gap = 0
	--end, "gaps = 0" },
	--{ "b", function()
	--	lain.util.useless_gaps_resize(10)
	--end, "bigger =+ 10" },
	--{ "s", function()
	--	lain.util.useless_gaps_resize(-10)
	--end, "smaller =- 10" },
	--{ "B", function()
	--	lain.util.useless_gaps_resize(50)
	--end, "bigger =+ 50" },
	--{ "S", function()
	--	lain.util.useless_gaps_resize(-50)
	--end, "smaller =- 50" },
}

imodal_widgets            = {
	--{ "d", function()
	--	awful.screen.focused().my_calendar_widget.toggle()
	--end, "calendar" },
	----{ "t", toggle_worldtimes_fn, "world times" },
	--{ "w", function()
	--	awful.screen.focused().my_weather.toggle()
	--end, "weather" },
}

imodal_bars               = {
	--{ "b", toggle_wibar_slim_fn, "wibar/slim" },
}

imodal_main               = {
	--{ "Return", icky_fns.apps.rofi, "rofi" },

	--{ "Tab", special.focus_previous_client_global, "focus last" },

	--{ "!", function()
	--	local c = client.focus
	--	if not c then
	--		return
	--	end
	--	fancy_float_toggle(c)
	--end, "fancy float" },

	--{ "-", function(c)
	--	-- The client currently has the input focus, so it cannot be
	--	-- minimized, since minimized clients can't have the focus.
	--	local cc = c or client.focus
	--	if not cc then
	--		return
	--	end
	--	cc.focus = false
	--	cc:lower()
	--	cc.minimized = true
	--	awful.client.focus.history.previous()
	--end, "minimize" },
	--{ "+", function()
	--	local c = awful.client.restore()
	--	-- Focus restored client
	--	if c then
	--		client.focus = c
	--		c:raise()
	--	end
	--end, "restore" },

	--{ "*", function()
	--	if not client.focus then
	--		return
	--	end
	--	client.focus:swap(awful.client.getmaster())
	--end, "move client to master" },

	{ "a", modalbind.grabf { keymap = imodal_awesomewm, name = "Awesome", stay_in_mode = false, hide_default_options = true }, "+awesome" },
	{ "b", modalbind.grabf { keymap = imodal_bars, name = "Bars", stay_in_mode = false, hide_default_options = true }, "+bars" },
	--{ "e", revelation, "revelation" },
	{ "f", modalbind.grabf { keymap = imodal_client_focus, name = "Client (focus)", stay_in_mode = false, hide_default_options = true }, "+focus (client)" },
	{ "g", modalbind.grabf { keymap = imodal_widgets, name = "Widgets", stay_in_mode = false, hide_default_options = true }, "+widgets" },
	--{ "i", icky_fns.client.hints, "hints" },
	{ "l", modalbind.grabf { keymap = imodal_layout, name = "Layout", stay_in_mode = false, hide_default_options = true }, "+layout" },
	{ "p", modalbind.grabf { keymap = imodal_client_move_resize, name = "Client", stay_in_mode = true, hide_default_options = true }, "+position (client)" },
	--{ "r", revelation, "revelation" },
	--{ "s", function()
	--	awful.screen.focus_relative(1)
	--end, "switch screen" },
	{ "t", modalbind.grabf { keymap = imodal_tag, name = "Tag", stay_in_mode = false, hide_default_options = true }, "+tag" },
	{ "u", modalbind.grabf { keymap = imodal_useless, name = "Useless gaps", stay_in_mode = true, hide_default_options = true }, "+useless gaps" },
	{ "v", modalbind.grabf { keymap = imodal_volume, name = "Useless gaps", stay_in_mode = true, hide_default_options = true }, "+volume" },
	{ "x", modalbind.grabf { keymap = imodal_toggle, name = "Toggle Settings", stay_in_mode = false, hide_default_options = true }, "+toggle" },
	{ "w", modalbind.grabf { keymap = imodal_client_toggle, name = "Client window", stay_in_mode = false, hide_default_options = true }, "+window (client)" },
	--{ "z", function()
	--	awful.screen.focused().quake:toggle()
	--end, "quake" },
	{ "P", modalbind.grabf { keymap = imodal_power, name = "Power/User", stay_in_mode = false, hide_default_options = true }, "+power/user" },
	--{ "R", function()
	--	special.popup_launcher.launch()
	--end, "run launcher" },
	{ "S", modalbind.grabf { keymap = imodal_screenshot, name = "Screenshot", stay_in_mode = false, hide_default_options = true }, "+screenshot" },
}

--

--local bling = require("bling")
--local rubato = require("rubato")

--bling.widget.window_switcher.enable {
--    type = "thumbnail", -- set to anything other than "thumbnail" to disable client previews
--
--    -- keybindings (the examples provided are also the default if kept unset)
--    hide_window_switcher_key = "Escape", -- The key on which to close the popup
--    minimize_key = "n",                  -- The key on which to minimize the selected client
--    unminimize_key = "N",                -- The key on which to unminimize all clients
--    kill_client_key = "q",               -- The key on which to close the selected client
--    cycle_key = "Tab",                   -- The key on which to cycle through all clients
--    previous_key = "Left",               -- The key on which to select the previous client
--    next_key = "Right",                  -- The key on which to select the next client
--    vim_previous_key = "h",              -- Alternative key on which to select the previous client
--    vim_next_key = "l",                  -- Alternative key on which to select the next client
--
--    cycleClientsByIdx = awful.client.focus.byidx,               -- The function to cycle the clients
--    filterClients = awful.widget.tasklist.filter.currenttags,   -- The function to filter the viewed clients
--}

-- }}}

---- These are example rubato tables. You can use one for just y, just x, or both.
---- The duration and easing is up to you. Please check out the rubato docs to learn more.
--local anim_y = rubato.timed {
--    pos = 1090,
--    rate = 60,
--    easing = rubato.quadratic,
--    intro = 0.1,
--    duration = 0.3,
--    awestore_compat = true -- This option must be set to true.
--}
--
--local anim_x = rubato.timed {
--    pos = -970,
--    rate = 60,
--    easing = rubato.quadratic,
--    intro = 0.1,
--    duration = 0.3,
--    awestore_compat = true -- This option must be set to true.
--}
--
--local term_scratch = bling.module.scratchpad {
--    command = "firefox --no-remote --class spad",           -- How to spawn the scratchpad
--    rule = { instance = "spad" },                     -- The rule that the scratchpad will be searched by
--    sticky = true,                                    -- Whether the scratchpad should be sticky
--    autoclose = false,                                 -- Whether it should hide itself when losing focus
--    floating = true,                                  -- Whether it should be floating (MUST BE TRUE FOR ANIMATIONS)
--    geometry = {x=360, y=90, height=900, width=1200}, -- The geometry in a floating state
--    reapply = true,                                   -- Whether all those properties should be reapplied on every new opening of the scratchpad (MUST BE TRUE FOR ANIMATIONS)
--    dont_focus_before_close  = false,                 -- When set to true, the scratchpad will be closed by the toggle function regardless of whether its focused or not. When set to false, the toggle function will first bring the scratchpad into focus and only close it on a second call
--    rubato = {x = anim_x, y = anim_y}                 -- Optional. This is how you can pass in the rubato tables for animations. If you don't want animations, you can ignore this option.
--}

-- {{{ Menwesomeu
local myawesomemenu       = {
	{
		"hotkeys",
		function()
			return false, hotkeys_popup.show_help
		end
	},
	--{ "layouts", function() return false, layoutlist_popup.widget end },
	-- { "manual", terminal .. " -e man awesome" },
	-- { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
	{ "restart", awesome.restart }
	--    {
	--        "quit",
	--        function()
	--            awesome.quit()
	--        end
	--    }
}

local myscreenshotmenu    = {
	{
		"Selection",
		icky_fns.screenshot.selection,
	},
	{
		"Window",
		icky_fns.screenshot.window,
	}
}

--screenshot_menu        = awful.menu({
--										items = {
--											{ "Screenshot: Selection", function()
--												screenshot_menu:hide()
--												--awful.util.spawn_with_shell(scrnshotter_select)
--												awful.spawn.easy_async_with_shell(scrnshotter_select, function()
--													naughty.notify({ text = "Screenshot of selection OK", timeout = 5, bg = "#058B04", fg = "#ffffff", position = "bottom_middle })
--												end)
--											end, nil },
--											{ "Screenshot: Window", function()
--												screenshot_menu:hide()
--												awful.util.spawn_with_shell(scrnshotter_window)
--												naughty.notify({ text = "Screenshot of window OK", timeout = 5, bg = "#058B04", fg = "#ffffff", position = "bottom_middle })
--											end, nil },
--										}
--									})

local mypowermenu         = {
	{ "Suspend/Sleep", function()
		awful.util.spawn_with_shell("sudo systemctl suspend")
	end },
	{ "Log out", function()
		awful.util.spawn_with_shell("sudo service lightdm restart")
	end },
	{ "Shutdown", function()
		os.execute("shutdown -P -h now")
	end },
	{ "Reboot", function()
		os.execute("reboot")
	end },
}

awful.util.mymainmenu     = freedesktop.menu.build({
													   icon_size = beautiful.menu_height or 18,
													   before    = {
														   -- other triads can be put here
														   { "Screenshot", myscreenshotmenu, nil },
														   { " " },
													   },
													   after     = {
														   { " " },
														   { "Awesome", myawesomemenu, beautiful.awesome_icon },
														   { "Power/User Mgmt", mypowermenu, nil },
														   --{ "Log out", function() awful.util.spawn_with_shell("sudo service lightdm restart") end},
														   --{ "Shutdown", function() os.execute("shutdown -P -h now") end},
														   --{ "Reboot", function() os.execute("reboot") end},
														   --{ "Open terminal", terminal }
														   -- other triads can be put here
													   }
												   })
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry",
					  function(s)
						  -- Wallpaper
						  if beautiful.wallpaper then
							  local wallpaper = beautiful.wallpaper
							  -- If wallpaper is a function, call it with the screen
							  if type(wallpaper) == "function" then
								  wallpaper = wallpaper(s)
							  end
							  gears.wallpaper.maximized(wallpaper, s, true)
						  end
					  end)

-- Create a wibox for each screen and add it
-- HERE COMMENTED
screen.connect_signal("request::desktop_decoration", function(s)
	beautiful.at_screen_connect(s)
end)
--awful.screen.connect_for_each_screen(function(s)
--	beautiful.at_screen_connect(s)
--end)

icky_keys()

-- {{{ Key bindings
--awful.keyboard.append_global_keybindings({
--											 --awful.key({ modkey }, ",", function()
--												-- modalbind.grab { keymap = imodal_main, name = "", stay_in_mode = false }
--											 --end),
--										 })


-- Set up client management buttons FOR THE MOUSE.
-- (1 is left, 3 is right)
clientbuttons     = a_util_table.join(
		awful.button({}, 1, function(c)
			client.focus = c
			c:raise()
		end),
		awful.button({ modkey }, 1, function(c)
			c.floating  = true
			c.maximized = false
			awful.mouse.client.move()
		end
		),
		awful.button({ modkey }, 3, function(c)
			c.floating  = true
			c.maximized = false
			awful.mouse.client.resize()
		end
		))

-- Set keys
--awful.keyboard.append_global_keybindings(myglobalkeys)
--for _, k in ipairs(myglobalkeys) do
--	awful.keyboard.append_global_keybindings(k)
--end


-- }}}

--local konsole_icon_path = gears.filesystem.get_configuration_dir() .. "/awesome-buttons/icons/terminal.svg"
--local konsole_icon      = gears.surface(konsole_icon_path)
--local konsole_img       = cairo.ImageSurface.create(cairo.Format.ARGB32, konsole_icon:get_width(), konsole_icon:get_height())
--local konsole_cr        = cairo.Context(konsole_img)
--konsole_cr:set_source_surface(s, 0, 0)
--konsole_cr:paint()

--awesome.set_preferred_icon_size(32, 32)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	--[[  ]]
	-- All clients will match this rule.
	{
		rule       = {},
		properties = {
			--border_width     = beautiful.border_width,
			--border_color     = beautiful.border_color_normal,
			focus            = awful.client.focus.filter,
			raise            = true,
			keys             = icky_keys.get_client_awful_keys(),
			buttons          = clientbuttons,
			screen           = awful.screen.preferred, --.focused(),
			-- placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			placement        = awful.placement.no_offscreen,
			size_hints_honor = false
		}
	},
	-- Titlebars
	{
		rule       = { maximized = true },
		properties = { titlebars_enabled = false },
	},
	{
		rule_any   = { type = { "dialog", "normal" } },
		-- properties = {titlebars_enabled = true}
		properties = { titlebars_enabled = true }
	},
	--     -- Set Firefox to always map on the first tag on screen 1.
	--     { rule = { class = "Firefox" },
	--       properties = { screen = 1, tag = awful.util.tagnames[1] } },

	{
		rule       = { class = "Gimp", role = "gimp-image-window" },
		properties = { maximized = true }
	},
	-- https://youtrack.jetbrains.com/issue/IDEA-112015#focus=Comments-27-2797933.0-0
	{
		-- IntelliJ has dialogs, which shall not get focus, e.g. open type or open resource.
		-- These are Java Dialogs, which are not X11 Dialog Types.
		rule_any   = {
			instance = { "sun-awt-X11-XWindowPeer", "sun-awt-X11-XDialogPeer", "keybase" }
		},
		properties = {
			focusable = false,
			placement = awful.placement.under_mouse + awful.placement.no_offscreen
		}
	},
	{
		-- IntelliJ has dialogs, which do not get focus, e.g. Settings Dialog or Paste Dialog.
		rule       = {
			type     = "dialog",
			instance = "sun-awt-X11-XDialogPeer"
		},
		properties = {
			focusable = true,
			focus     = true
		}
	},
	{
		rule       = {
			handy_id = ".*"
		},
		properties = {
			skip_taskbar = true,
			placement    = awful.placement.no_offscreen
		}
	},
	{
		rule       = {
			class = "Xephyr"
		},
		properties = {
			border_width = 2,
			border_color = "#A32BCE",
			screen       = 1,
			placement    = awful.placement.centered,
			floating     = true,
			ontop        = true,
			focus        = false,
		}
	},
	{
		rule       = {
			floating = true,
		},
		properties = {
			shape = function(cc, w, h)
				-- Round only the top corners.
				--gears.shape.rounded_rect(c, w, h,)
				local tl, tr, br, bl, rad = true, true, false, false, math.min(10, h / 10)
				return gears.shape.partially_rounded_rect(cc, w, h, tl, tr, br, bl, rad)
			end,
		}
	},
	--{
	--	rule       = {
	--		class = "konsole",
	--	},
	--	properties = {
	--		icon = konsole_icon,
	--	}
	--}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage",
					  function(c)
						  -- Set the windows at the slave,
						  -- i.e. put it at the end of others instead of setting it master.
						  -- if not awesome.startup then awful.client.setslave(c) end

						  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
							  -- Prevent clients from being unreachable after screen count changes.
							  awful.placement.no_offscreen(c)
						  end
					  end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.

local mytitlebars = function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons    = a_util_table.join(
			awful.button({},
						 1,
						 function()
							 client.focus = c
							 c:raise()
							 awful.mouse.client.move(c)
						 end),
			awful.button({},
						 3,
						 function()
							 client.focus = c
							 c:raise()
							 awful.mouse.client.resize(c)
						 end))

	-- forced_height = 12, forced_width = 12
	local ci         = awful.widget.clienticon(c);
	ci.forced_width  = 12
	ci.forced_height = 12
	awful.titlebar(c, { size = 16 }):setup {
		{
			-- Left
			layout  = wibox.layout.fixed.horizontal,
			wibox.widget.textbox(" "),
			wibox.container.place { widget = ci, valign = "center" },
			awful.titlebar.widget.titlewidget(c),
			buttons = buttons,
			spacing = 5,
		},
		{
			--                -- Middle
			--                {
			--                    -- Title
			--                    align = "center",
			--                    widget = awful.titlebar.widget.titlewidget(c)
			--                },
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		{
			-- Right
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.floatingbutton(c),
			wibox.widget.textbox(" "),
			-- awful.titlebar.widget.closebutton(c),
			spacing = 5, -- https://awesomewm.org/doc/api/classes/wibox.layout.fixed.html#wibox.layout.fixed.spacing
			layout  = wibox.layout.fixed.horizontal
		},
		layout = wibox.layout.align.horizontal
	}
end

client.connect_signal("request::titlebars", mytitlebars)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter",
					  function(c)
						  local focused        = client.focus
						  local isJavaInstance = function(instance)
							  -- xprop WM_CLASS
							  -- WM_CLASS(STRING) = "sun-awt-X11-XFramePeer", "jetbrains-studio"

							  -- THIS ONE IS THE ORIGINAL GOOD ONE:
							  return instance and instance ~= "" and string.match(instance, '^sun-awt-X11-X')

							  -- THIS ONE IS EXPERIMENTS:
							  --return instance and instance ~= "" and string.match(instance, '^.*')
							  --return true
						  end
						  if focused and focused.class == c.class
								  and isJavaInstance(focused.instance)
								  and isJavaInstance(c.instance) then
							  return -- early
						  end

						  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
							  client.focus = c
						  end
					  end)

local function move_mouse_onto_focused_client(c)
	if c == nil then
		return
	end
	if mouse.object_under_pointer() == nil then
		return
	end

	-- The object (window, eg) under the mouse IS the client in question.
	if mouse.object_under_pointer() == c then
		return
	end

	---- Prevent mouse snapping to client when...
	---- The mouse is already in the focused client's screen.
	--if mouse.screen == c.screen then return end

	-- The mouse is up in the wibar, when
	-- selecting a tag is selected from the taglist in the menubar wibox.
	if mouse.current_wibox ~= nil then
		return
	end

	-- The focused client is floating or on-top.
	if c.floating or c.ontop then
		return
	end

	-- Only reposition the mouse if the new client is on the other screen.
	if mouse.object_under_pointer().screen == c.screen then
		return
	end

	-- Move the mouse.
	if mouse.object_under_pointer() ~= c then
		local geometry = c:geometry()
		local x        = geometry.x + geometry.width / 2
		local y        = geometry.y + geometry.height / 2 - 30
		mouse.coords({ x = x, y = y }, true)
	end
end

-- No border for maximized clients
function border_adjust(c)
	if c.maximized then
		-- no borders if only 1 client visible
		c.border_width = 0
	elseif #awful.screen.focused().clients > 1 then
		c.border_width = beautiful.border_width
		c.border_color = beautiful.border_focus
	end
	if c.focused then
		c.border_width = 30
	end
end

-- make rofi possible to raise minimized clients
client.connect_signal("request::activate",
					  function(c, context, hints)
						  if c.minimized then
							  c.minimized = false
						  end
						  awful.ewmh.activate(c, context, hints)

						  local t = c.first_tag
						  if not t then
							  return
						  end
						  local cls = t:clients()
						  for _, tc in ipairs(cls) do
							  if tc ~= c then
								  tc.border_color = beautiful.border_normal

								  --if #cls > 1 then
								  --  awful.titlebar.hide(tc)
								  --else
								  --  awful.titlebar.show(tc)
								  --end
							  end
						  end
					  end
)

client.connect_signal("focus", function(c)
	--border_adjust(c)
	move_mouse_onto_focused_client(c)

	local t = c.first_tag
	for _, tc in ipairs(t:clients()) do
		if tc ~= c then
			--awful.titlebar.show(c)
			tc.border_color = beautiful.border_normal
		end
	end
end)
--client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus",
					  function(c)
						  --c.border_color = beautiful.border_normal
					  end)

-- }}}

-- https://unix.stackexchange.com/questions/401539/how-to-disallow-any-application-from-stealing-focus-in-awesome-wm
--awful.ewmh.add_activate_filter(function() return false end, "ewmh")
--awful.ewmh.add_activate_filter(function() return false end, "rules")

---- https://stackoverflow.com/questions/44571965/awesome-wm-applications-fullscreen-mode-without-taking-whole-screen
client.disconnect_signal("request::geometry", awful.ewmh.geometry)
client.connect_signal("request::geometry", function(c, context, ...)
	if context == "fullscreen" and c.sticky then
		-- ignore; I want the world cup in a picture-in-picture type deal
	else
		awful.ewmh.geometry(c, context, ...)
		--c.sticky = true
		--c.ontop = true
		--local geo
		--geo = c:geometry()
		--local geo_scr
		--geo_scr = c.screen.geometry
		--
		--geo.width = geo_scr.width / 4
		--geo.height = geo_scr.height / 3
		--
		--c:geometry(geo)
		--local f = awful.placement.right + awful.placement.bottom;
		--f(c)
	end
end)
--
--client.connect_signal("property::fullscreen", function(c)
--	c.ontop = true
--	c.sticky = true
--	c:raise()
--end)

--client.connect_signal("property::name", function(c)
--	for i, cl in ipairs(client.get()) do
--		if not c.renamed and cl == c then
--			c.renamed = true
--			c.name = tostring(i) .. " " .. c.name
--			return
--		end
--	end
--
--	--if not (c.class == "Chromium" or c.class == "firefox") then return end
--	--local patterns = {}
--	--patterns["- Chromium$"] = "" -- removes "- Chromium"
--	--patterns["- (Mozilla Firefox)$"] = "- [%1]" -- adds brackets - [Mozilla Firefox]
--	--
--	--for p, r in pairs(patterns) do
--	--	if string.find(c.name, p) then
--	--		c.name = string.gsub(c.name, p, r)
--	--		break
--	--	end
--	--end
--end)
