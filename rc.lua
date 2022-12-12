--[[

     Awesome WM configuration template
     github.com/lcpz

--]]
-- {{{ Required libraries
local awesome, client, mouse, screen, tag                                   = awesome, client, mouse, screen, tag
local ipairs, pairs, string, os, table, tostring, tonumber, tointeger, type = ipairs, pairs, string, os, table, tostring, tonumber, tointeger, type

local gears                                                                 = require("gears")
local awful                                                                 = require("awful")
require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local revelation    = require("revelation")

local hints         = require("hints")

local ia_layout_bigscreen = require("bigscreen-layout")
local ia_layout_vcolumns = require("columns-layout")

local ia_popup_shell = require("ia-popup-run.popup-shell")

local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
					   preset = naughty.config.presets.critical,
					   title  = "Oops, there were errors during startup!",
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
												  title  = "Oops, an error happened!",
												  text   = tostring(err)
											  })
							   in_error = false
						   end)
end
-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

run_once({ "urxvtd", "unclutter -root" }) -- entries must be comma-separated

-- {{{ Variable definitions

local chosen_theme       = "ia"
local modkey             = "Mod4"
local altkey             = "Mod1"
local terminal           = "xterm"
local editor             = os.getenv("EDITOR") or "vim"
local gui_editor         = "code"
local browser            = "ffox"
local guieditor          = "code"
local scrlocker          = "xlock"
local scrnshotter_select = "sleep 0.5 && scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' --quality 100 --silent --select --freeze --exec 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"
local scrnshotter_window = "sleep 0.5 && scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' --quality 100 --silent --focused --exec 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"
local invert_colors      = "xrandr-invert-colors"

local clientkeybindings  = {}
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

awful.util.terminal         = terminal
--awful.util.tagnames = { "1", "2", "3", "4", "5" }
--awful.util.tagnames = { "●", "●", "●", "●", "●" }
awful.util.tagnames         = { "❶", "❷", "❸", "❹", "❺" }
--awful.util.tagnames = { "▇", "▇", "▇", "▇", "▇" }
awful.layout.layouts        = {
	-- awful.layout.suit.tile.bottom,
	awful.layout.suit.tile,
	lain.layout.centerwork,
	--awful.layout.suit.fair,
	awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	awful.layout.suit.floating,
	--ia_layout_bigscreen,
}

awful.util.taglist_buttons  = my_table.join(awful.button({}, 1, function(t)
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

awful.util.tasklist_buttons = my_table.join(awful.button({}, 1, function(c)
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

local theme_path            = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
--local theme_path = string.format("%s/.config/awesome/awesome-macos/themes/macos-dark/theme.lua", os.getenv("HOME"))

beautiful.init(theme_path)
revelation.init()
hints.init()

local screenshot_selection_fn = function()
	awful.util.mymainmenu:hide()
	awful.spawn.easy_async_with_shell(scrnshotter_select, function()
		naughty.notify({ text = "Screenshot of selection OK", timeout = 2, bg = "#058B04", fg = "#ffffff", position = "bottom_middle" })
	end)
end

local screenshot_window_fn = function()
	awful.util.mymainmenu:hide()
	awful.util.spawn_with_shell(scrnshotter_window)
	naughty.notify({ text = "Screenshot of window OK", timeout = 2, bg = "#058B04", fg = "#ffffff", position = "bottom_middle" })
end

-- Modal operation
--
local fullscreen_fn = function(c)
	c.fullscreen = not c.fullscreen
	c:raise()
end

local modalbind     = require("modalbind")
modalbind.init()
modalbind.set_location("centered")
modalbind.hide_default_options()

local imodal_main
local imodal_awesomewm
local imodal_client
local imodal_client_placement
local imodal_layouts
local imodal_power
local imodal_screenshot
local imodal_tag
local imodal_toggle

local backable         = { "<", function()
	modalbind.grab { keymap = imodal_main, name = "", stay_in_mode = false }
end, "back" }

local imodal_separator = { "separator", "" }

imodal_awesomewm = {
	{ "h", hotkeys_popup.show_help, "Hotkeys"},
	{ "m", function()
		awful.util.mymainmenu:show()
	end, "Menu"},
	{ "r", awesome.restart, "Restart" },
	imodal_separator,
	backable,
}

imodal_client          = {

	{ "c", function()
		modalbind.grab { keymap = imodal_client_placement, name = "Client Placement", stay_in_mode = true, hide_default_options = true }
	end, "➔ Position Client"},

	imodal_separator,

	{"h", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, "Focus client ← left"},
	{"l", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, "Focus client → right"},
	{"j", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, "Focus client ↓ down"},
	{"k", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, "Focus client ↑ up"},

	imodal_separator,

	{ "f", function()
		if not client.focus then return end
		client.focus.floating = not client.focus.floating
		client.focus:raise()
	end, "Float" },

	{ "F", function()
		if not client.focus then return end
		fullscreen_fn(client.focus)
	end, "Fullscreen" },

	{ "m", function()
		if not client.focus then return end
		client.focus.maximized = not client.focus.maximized
		client.focus:raise()
	end, "Maximize" },

	{ "o", function()
		if not client.focus then return end
		client.focus.ontop = not client.focus.ontop
	end, "On top"},

	{ "s", function()
		if not client.focus then return end
		client.focus.sticky = not client.focus.sticky
	end, "Sticky" },

	imodal_separator,

	{ "t", function()
		if not client.focus then return end
		client.focus:move_to_screen()
	end, "Throw to next screen"},

	{ "T", function()
		if not client.focus then return end
		awful.titlebar.toggle(client.focus)
	end, "Titlebar (toggle)"},

	imodal_separator,

	--{ "m", function()
	--	if not client.focus then return end
	--	lain.util.magnify_client(client.focus)
	--end, "Magnify"},

	--{ "p", function()
	--	local c = client.focus;
	--	if client.focus.fullscreen then
	--		local geo
	--		geo = c:geometry()
	--		local geo_scr
	--		geo_scr = c.screen.geometry
	--
	--		geo.width = geo_scr.width / 4
	--		geo.height = geo_scr.height / 3
	--
	--		c:geometry(geo)
	--		local f = awful.placement.right + awful.placement.bottom;
	--		f(c)
	--		c.ontop = true
	--		c.sticky = true
	--		c.fullscreen = true
	--		--c:raise()
	--	end
	--	--if client.focus.fullscreen then
	--	--	fullscreen_fn(client.focus)
	--	--else
	--	--	client.focus.disconnect_signal("request::geometry", awful.ewmh.geometry)
	--	--	fullscreen_fn(client.focus)
	--	--	client.focus.ontop = true
	--	--	client.focus.sticky = true
	--	--	client.connect_signal("request::geometry", awful.ewmh.geometry)
	--	--end
	--end, "Picture-in-picture (use on Fullscreen client)"},

	{ "n", function()
		if not client.focus then return end
		client.focus.minimized = true
	end, "Minimize client" },

	{ "r", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			client.focus = c
			c:raise()
		end
	end, "Restore (=unminimize) a random client"},

	{ "x", function()
		if not client.focus then return end
		client.focus:kill()
	end, "Kill"},

	imodal_separator,
	backable,
}

imodal_client_placement = {

	{ "B", function() if not client.focus then return end; client.focus.floating = true; client.focus.height = client.focus.screen.workarea.height / 10 * 5; client.focus.width = client.focus.screen.workarea.width / 10 * 5; awful.placement.bottom(client.focus)  end, "Bottom [resized]"},
	{ "C", function() if not client.focus then return end; client.focus.floating = true; awful.placement.scale(client.focus, {to_percent=0.61}); awful.placement.centered(client.focus)  end, "Center [resized]"},
	{ "L", function() if not client.focus then return end; client.focus.floating = true; client.focus.height = client.focus.screen.workarea.height / 10 * 8; client.focus.width = client.focus.screen.workarea.width / 100 * 25; awful.placement.left(client.focus)  end, "Left [resized]"},
	{ "R", function() if not client.focus then return end; client.focus.floating = true; client.focus.height = client.focus.screen.workarea.height / 10 * 8; client.focus.width = client.focus.screen.workarea.width / 100 * 25; awful.placement.right(client.focus)  end, "Right [resized]"},
	{ "T", function() if not client.focus then return end; client.focus.floating = true; client.focus.height = client.focus.screen.workarea.height / 10 * 5; client.focus.width = client.focus.screen.workarea.width / 10 * 5; awful.placement.top(client.focus)  end, "Top [resized]"},

	imodal_separator,

	{ "b", function() if not client.focus then return end; client.focus.floating = true; awful.placement.bottom(client.focus)  end, "Bottom"},
	{ "c", function() if not client.focus then return end; client.focus.floating = true; awful.placement.centered(client.focus)  end, "Center"},
	{ "l", function() if not client.focus then return end; client.focus.floating = true; awful.placement.left(client.focus)  end, "Left"},
	{ "r", function() if not client.focus then return end; client.focus.floating = true; awful.placement.right(client.focus)  end, "Right"},
	{ "t", function() if not client.focus then return end; client.focus.floating = true; awful.placement.top(client.focus)  end, "Top"},

	imodal_separator,

	{ "v", function() if not client.focus then return end; client.focus.floating = true; client.focus.height = client.focus.height + client.focus.screen.workarea.height / 10  end, "Grow ↓"},
	{ "V", function() if not client.focus then return end; client.focus.floating = true; client.focus.height = client.focus.height - client.focus.screen.workarea.height / 10  end, "Shrink ↑"},
	{ "+", function() if not client.focus then return end; client.focus.floating = true; client.focus.width = client.focus.width + client.focus.screen.workarea.height / 10  end, "Grow →"},
	{ "-", function() if not client.focus then return end; client.focus.floating = true; client.focus.width = client.focus.width - client.focus.screen.workarea.height / 10  end, "Shrink ←"},

	{ "H", function() if not client.focus then return end; client.focus.floating = true; awful.placement.maximize_vertically(client.focus) end, "Height of work area"},
	{ "W", function() if not client.focus then return end; client.focus.floating = true; awful.placement.maximize_horizontally(client.focus) end, "Width of work area"},
}

imodal_layouts         = {
	{ "b", function()
		awful.layout.set(ia_layout_bigscreen)
	end, "Big screen 4x4"},
	{ "c", function()
		awful.layout.set(lain.layout.centerwork)
	end, "Centerwork" },
	{ "f", function()
		awful.layout.set(awful.layout.suit.floating)
	end, "Floating" },
	{ "m", function()
		awful.layout.set(awful.layout.suit.magnifier)
	end, "Magnifier" },
	{ "t", function()
		awful.layout.set(awful.layout.suit.tile)
	end, "Tile" },
	{ "v", function()
		awful.layout.set(ia_layout_vcolumns)
	end, "Vertical columns"},
	imodal_separator,
	backable,
}

imodal_power           = {
	{ "l", function()
		awful.util.spawn_with_shell("sudo service lightdm restart")
	end, "Log out" },
	{ "s", function()
		awful.util.spawn_with_shell("sudo systemctl suspend")
	end, "Suspend" },
	imodal_separator,
	{ "P", function()
		awful.util.spawn_with_shell("shutdown -P -h now")
	end, "Shutdown" },
	{ "R", function()
		os.execute("reboot")
	end, "Reboot" },
	imodal_separator,
	backable,
}

imodal_screenshot = {
	{ "s", screenshot_selection_fn, "Selection"},
	{ "w", screenshot_window_fn, "Window"},
	imodal_separator,
	backable,
}

imodal_tag             = {
	{ "1", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[1]
		if tag then
			tag:view_only()
		end
	end, "[1] - View Tag"},
	{ "2", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[2]
		if tag then
			tag:view_only()
		end
	end, "[2] - View Tag"},
	{ "3", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[3]
		if tag then
			tag:view_only()
		end
	end, "[3] - View Tag"},
	{ "4", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[4]
		if tag then
			tag:view_only()
		end
	end, "[4] - View Tag"},
	{ "5", function()
		local screen = awful.screen.focused()
		local tag    = screen.tags[5]
		if tag then
			tag:view_only()
		end
	end, "[5] - View Tag"},
	imodal_separator,
	{ "a", function ()
		awful.tag.add("NewTag", {
			screen = awful.screen.focused(),
			layout = awful.layout.suit.floating }):view_only()
	end, "Add tag"},
	{ "d", function()
		local t = awful.screen.focused().selected_tag
		if not t then return end
		t:delete()
	end, "Delete tag"},
	{ "n", awful.tag.viewnext, "Next tag" },
	{ "N", function()
		local c = client.focus
		if not c then return end

		local t = awful.tag.add(c.class,{screen= c.screen })
		c:tags({t})
		t:view_only()
	end, "(move focused client to) New tag"},
	{ "p", awful.tag.viewprev, "Previous tag" },
	{ "r", function()
		awful.prompt.run {
			prompt       = "New tag name: ",
			textbox      = awful.screen.focused().mypromptbox.widget,
			exe_callback = function(new_name)
				if not new_name or #new_name == 0 then return end

				local t = awful.screen.focused().selected_tag
				if t then
					t.name = new_name
				end
			end
		}
	end, "Rename tag"},
	imodal_separator,
	backable,
}

imodal_toggle = {
	{ "c", function()
		os.execute(invert_colors)
	end, "Invert Colors"},

	{ "i", function()
		os.execute("amixer -q set Capture toggle")
		beautiful.mic.update()
	end, "Microphone"},

	{"m", function()
		os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
		beautiful.volume.update()
	end, "Mute"},

	{ "u", function()
		local scr = awful.screen.focused()
		if scr.selected_tag.gap > 0 then
			-- turn gaps off by setting to 0
			scr.selected_tag.gap = 0
		else
			scr.selected_tag.gap = scr.geometry.height / 20
		end
		awful.layout.arrange(scr)
		naughty.notify({ text = "Useless gaps set: " .. tostring(scr.selected_tag.gap), timeout = 2, bg = "#058B04", fg = "#ffffff", position = "bottom_middle" })
	end, "Useless gaps toggle"},

	imodal_separator,
	backable,
}

imodal_main            = {
	{ "a", function()
		modalbind.grab { keymap = imodal_awesomewm, name = "AwesomeWM", stay_in_mode = false, hide_default_options = true }
	end, "➔ AwesomeWM"},

	{ "c", function()
		modalbind.grab { keymap = imodal_client, name = "Client", stay_in_mode = false, hide_default_options = true }
	end, "➔ Client" },

	{ "l", function()
		modalbind.grab { keymap = imodal_layouts, name = "Layouts", stay_in_mode = false, hide_default_options = true }
	end, "➔ Layout" },

	{ "p", function()
		modalbind.grab { keymap = imodal_power, name = "Power/Awesome", stay_in_mode = false, hide_default_options = true }
	end, "➔ Power" },


	{ "s", function()
		modalbind.grab { keymap = imodal_screenshot, name = "Screenshot", stay_in_mode = false, hide_default_options = true }
	end, "➔ Screenshot"},

	{ "t", function()
		modalbind.grab { keymap = imodal_tag, name = "Tag", stay_in_mode = false, hide_default_options = true }
	end, "➔ Tag" },

	{ "x", function()
		modalbind.grab { keymap = imodal_toggle, name = "Toggle Settings", stay_in_mode = false, hide_default_options = true }
	end, "Toggle Settings"},

	imodal_separator,

	{ "d", function()
		my_calendar_widget.toggle()
	end, "Date = Toggle Calendar widget"},

	{ "i", function()
		hints.focus();
		client.focus:raise()
	end, "Jump-to h[i]nts" },

	{ "r", revelation, "Revelation" },

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

local handy            = require("handy")
local handy2           = require("handy2")

-- {{{ Menwesomeu
local myawesomemenu    = {
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

local myscreenshotmenu = {
	{
		"Selection",
		screenshot_selection_fn,
	},
	{
		"Window",
		screenshot_window_fn,
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

local mypowermenu      = {
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

awful.util.mymainmenu  = freedesktop.menu.build({
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
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
end)

-- }}}
-- {{{ Key bindings
globalkeys = my_table.join(

		awful.key({ modkey }, ",", function()
			modalbind.grab { keymap = imodal_main, name = "", stay_in_mode = false }
		end),

-- arguments:
-- - program
-- - placement (see awful.placement)
-- - width
-- - height
		awful.key({ modkey }, "v", function()
			handy("ffox --class handy-top", awful.placement.top, 0.5, 0.5)
		end, { description = "Handy: Firefox (top)", group = "launcher" }),

		awful.key({ modkey }, "a", function()
			handy("ffox --class handy-left", awful.placement.left, 0.25, 1)
		end, { description = "Handy: Firefox (left)", group = "launcher" }),

-- revelation: expose-like application shower picker
		awful.key({ modkey, "Shift" }, "e", revelation, { description = "Revelation (Expose)", group = "hotkeys" }),

-- hints: client picker, window picker, letter
		awful.key({ modkey }, "i", function()
			hints.focus();
			if not client.focus then return end
			client.focus:raise()
		end, { description = "Focus client with Hints", group = "hotkeys" }),


-- Take a screenshot
-- https://github.com/lcpz/dots/blob/master/bin/screenshot
--    awful.key({ modkey }, "p",
--        function()
--            os.execute(scrnshotter_select)
--        end,
--        { description = "take a screenshot with --select", group = "hotkeys" }),

--awful.key({ modkey }, "c",
--        function()
--            screenshot_menu:show({keygrabber= true})
--        end,
--        { description = "show screenshot menu", group = "hotkeys" }),

		awful.key({ modkey }, "x",
				  function()
					  os.execute(invert_colors)
				  end,
				  { description = "invert colors on all screens with xrandr", group = "hotkeys" }),

-- Hotkeys
--awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
		awful.key({ modkey }, "s", function()
			awful.spawn.easy_async_with_shell(scrnshotter_select, function()
				naughty.notify({ text = "Screenshot of selection OK", timeout = 2, bg = "#058B04", fg = "#ffffff", position = "bottom_middle" })
			end)
		end, { description = "take a screenshot of a selection", group = "hotkeys" }),

-- Tag browsing
		awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
		awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
		awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),


-- Revelation client focus

-- Default client focus
		awful.key({ altkey },
				  "j",
				  function()
					  awful.client.focus.byidx(1)
				  end,
				  { description = "focus next by index", group = "client" }),
		awful.key({ altkey },
				  "k",
				  function()
					  awful.client.focus.byidx(-1)
				  end,
				  { description = "focus previous by index", group = "client" }),
-- By direction client focus
		awful.key({ modkey },
				  "j",
				  function()
					  awful.client.focus.global_bydirection("down")
					  if client.focus then
						  client.focus:raise()
					  end
				  end,
				  { description = "focus down", group = "client" }),
		awful.key({ modkey },
				  "k",
				  function()
					  awful.client.focus.global_bydirection("up")
					  if client.focus then
						  client.focus:raise()
					  end
				  end,
				  { description = "focus up", group = "client" }),
		awful.key({ modkey },
				  "h",
				  function()
					  awful.client.focus.global_bydirection("left")
					  if client.focus then
						  client.focus:raise()
					  end
				  end,
				  { description = "focus left", group = "client" }),
		awful.key({ modkey },
				  "l",
				  function()
					  awful.client.focus.global_bydirection("right")
					  if client.focus then
						  client.focus:raise()
					  end
				  end,
				  { description = "focus right", group = "client" }),
		awful.key({ modkey },
				  "w",
				  function()
					  awful.util.mymainmenu:show()
				  end,
				  { description = "show main menu", group = "awesome" }),
-- Layout manipulation
		awful.key({ modkey, "Shift" },
				  "j",
				  function()
					  awful.client.swap.byidx(1)
				  end,
				  { description = "swap with next client by index", group = "client" }),
		awful.key({ modkey, "Shift" },
				  "k",
				  function()
					  awful.client.swap.byidx(-1)
				  end,
				  { description = "swap with previous client by index", group = "client" }),
		awful.key({ modkey, "Control" },
				  "j",
				  function()
					  awful.screen.focus_relative(1)
				  end,
				  { description = "focus the next screen", group = "screen" }),
		awful.key({ modkey, "Control" },
				  "k",
				  function()
					  awful.screen.focus_relative(-1)
				  end,
				  { description = "focus the previous screen", group = "screen" }),
--awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

		awful.key({ modkey }, "Tab",
				  function()
					  awful.client.focus.history.previous()
					  if client.focus then
						  client.focus:raise()
					  end
				  end,
				  { description = "go back", group = "client" }),

--awful.key({modkey}, "Tab", function()
--    awesome.emit_signal("bling::window_switcher::turn_on")
--end, {description = "Window Switcher", group = "bling"}),

-- Show/Hide Wibox
		awful.key({ modkey },
				  "d",
				  function()
					  --for s in screen do
					  local s           = awful.screen.focused()
					  s.mywibox.visible = not s.mywibox.visible
					  if s.mybottomwibox then
						  s.mybottomwibox.visible = not s.mybottomwibox.visible
					  end
					  if s.mywibox_slim then
						  s.mywibox_slim.visible = not s.mywibox_slim.visible
					  end

					  --if s.mywibox_clock then
					  --    s.mywibox_clock.visible = not s.mywibox_clock.visible
					  --end
				  end,
				  { description = "toggle wibox", group = "awesome" }),

-- Show/Hide Global Time Clock wibar
		awful.key({ modkey },
				  "g", -- g for Global times (and is on right)
				  function()
					  local s                      = awful.screen.focused()
					  --for s in screen do
					  s.mywibox_worldtimes.visible = not s.mywibox_worldtimes.visible
					  --end
				  end,
				  { description = "toggle world times wibox", group = "awesome" }),

---- Show/Hide Time/Clock box
--awful.key({ modkey },
--        "t", -- g for Global times (and is on right)
--        function()
--            local s =  awful.screen.focused()
--            --for s in screen do
--            s.mywibox_clock.visible = not s.mywibox_clock.visible
--            --end
--        end,
--        { description = "toggle time/clock wibox", group = "awesome" }),

---- Show/Hide Slimified Wibar
--awful.key({ modkey },
--            "t", -- t for top
--            function()
--                for s in screen do
--                    s.mywibox_slim.visible = not s.mywibox_slim.visible
--                end
--            end,
--            { description = "toggle slim wibox wibarZ", group = "awesome" }),

-- On the fly useless gaps change
		awful.key({ modkey, altkey },
				  "`",
				  function()
					  lain.util.useless_gaps_resize(10)
				  end,
				  { description = "increment useless gaps", group = "tag" }),
		awful.key({ modkey, altkey },
				  "-",
				  function()
					  lain.util.useless_gaps_resize(-10)
				  end,
				  { description = "decrement useless gaps", group = "tag" }),
-- Dynamic tagging
--awful.key({ modkey, "Shift" },
--    "n",
--    function()
--        lain.util.add_tag()
--    end,
--    { description = "add new tag", group = "tag" }),
--awful.key({ modkey, "Shift" },
--    "r",
--    function()
--        lain.util.rename_tag()
--    end,
--    { description = "rename tag", group = "tag" }),
		awful.key({ modkey, "Shift" },
				  "Left",
				  function()
					  lain.util.move_tag(-1)
				  end,
				  { description = "move tag to the left", group = "tag" }),
		awful.key({ modkey, "Shift" },
				  "Right",
				  function()
					  lain.util.move_tag(1)
				  end,
				  { description = "move tag to the right", group = "tag" }),
--awful.key({ modkey, "Shift" },
--    "d",
--    function()
--        lain.util.delete_tag()
--    end,
--    { description = "delete tag", group = "tag" }),
-- Standard program
		awful.key({ modkey },
				  "Return",
		-- rofi binding
				  function()
					  -- Location values:
					  -- 1   2   3
					  -- 8   0   4
					  -- 7   6   5

					  -- -sidebar-mode shows 'tabs' of available modi

					  commandPrompter = "rofi --modi window -show window -sidebar-mode -location 6 -theme Indego -width 20 -no-plugins -no-config -no-lazy-grab -async-pre-read 1 -sort"
					  awful.spawn.easy_async(commandPrompter, function()
						  if client.focus then
							  awful.screen.focus(client.focus.screen)
						  end
					  end)
				  end, { description = "run Rofi", group = "awesome" }),

--awful.key({ modkey, "Shift", }, "n",
---- cool buttons (custom program) binding
--        function(c)
--
--            --commandPrompter = "cool-buttons"
--            --awful.spawn.easy_async(commandPrompter, function()
--            --    awful.screen.focus(client.focus.screen)
--            --    --awful.client.floating = true;
--            --    c.floating = true;
--            --end)
--            awful.spawn("cool-buttons", {
--                requests_no_titlebar = true,
--                floating  = true,
--                tag       = mouse.screen.selected_tag,
--                placement = awful.placement.top_left,
--            })
--        end, { description = "run cool-buttons", group = "awesome" }),

		awful.key({ altkey, "Shift" },
				  "l",
				  function()
					  awful.tag.incmwfact(0.05)
				  end,
				  { description = "increase master width factor", group = "layout" }),
		awful.key({ altkey, "Shift" },
				  "h",
				  function()
					  awful.tag.incmwfact(-0.05)
				  end,
				  { description = "decrease master width factor", group = "layout" }),
		awful.key({ altkey, "Control", "Shift" },
				  "g",
				  function()
					  awful.tag.setmwfact(0.618)
				  end,
				  { description = "golden ratio client width", group = "client" }),
		awful.key({ modkey, "Shift" },
				  "h",
				  function()
					  awful.tag.incnmaster(1, nil, true)
				  end,
				  { description = "increase the number of master clients", group = "layout" }),
		awful.key({ modkey, "Shift" },
				  "l",
				  function()
					  awful.tag.incnmaster(-1, nil, true)
				  end,
				  { description = "decrease the number of master clients", group = "layout" }),
		awful.key({ modkey, "Control" },
				  "h",
				  function()
					  awful.tag.incncol(1, nil, true)
				  end,
				  { description = "increase the number of columns", group = "layout" }),
		awful.key({ modkey, "Control" },
				  "l",
				  function()
					  awful.tag.incncol(-1, nil, true)
				  end,
				  { description = "decrease the number of columns", group = "layout" }),
		awful.key({ modkey },
				  "space",
				  function()
					  awful.layout.inc(1)
				  end,
				  { description = "select next", group = "layout" }),
		awful.key({ modkey, "Shift" },
				  "space",
				  function()
					  awful.layout.inc(-1)
				  end,
				  { description = "select previous", group = "layout" }),

		awful.key({ modkey, "Control" },
				  "n",
				  function()
					  local c = awful.client.restore()
					  -- Focus restored client
					  if c then
						  client.focus = c
						  c:raise()
					  end
				  end,
				  { description = "restore minimized", group = "client" }),

-- Dropdown application
		awful.key({ modkey },
				  "z",
				  function()
					  awful.screen.focused().quake:toggle()
				  end,
				  { description = "dropdown application", group = "launcher" }),

--awful.key({ modkey },
--    "y",
--    function()
--        awful.screen.focused().quakeBrowser:toggle()
--    end,
--    { description = "dropdown application", group = "launcher" }),

-- ALSA volume control
		awful.key({ altkey, "Control" },
				  "0",
				  function()
					  -- os.execute("if amixer get Capture | grep -q -E 'Capture.*off'; then amixer set Capture cap ; else amixer set Capture nocap; fi")
					  os.execute("amixer -q set Capture toggle")
					  beautiful.mic.update()
				  end,
				  { description = "microphone toggle", group = "hotkeys" }),

		awful.key({ altkey },
				  "Up",
				  function()
					  os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
					  beautiful.volume.update()
				  end,
				  { description = "volume up", group = "hotkeys" }),
		awful.key({ altkey },
				  "Down",
				  function()
					  os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
					  beautiful.volume.update()
				  end,
				  { description = "volume down", group = "hotkeys" }),
		awful.key({ altkey },
				  "m",
				  function()
					  os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
					  beautiful.volume.update()
				  end,
				  { description = "toggle mute", group = "hotkeys" }),

		awful.key({ altkey, "Control" },
				  "m",
				  function()
					  -- os.execute(string.format("amixer -q set %s 100%%", beautiful.volume.channel))
					  os.execute("unmute.sh")
					  beautiful.volume.update()
				  end,
				  { description = "volume 100%", group = "hotkeys" }),

-- Prompt
		awful.key({ modkey },
				  "r",
				  function()
					  --awful.screen.focused().mypromptbox:run()
					  ia_popup_shell.launch()
				  end,
				  { description = "run prompt", group = "launcher" }))

clientkeys = my_table.join(

		awful.key({ altkey, "Shift" }, "m", function(c)
			lain.util.magnify_client(c)
			c:raise()
		end, { description = "magnify client", group = "client" }),

		awful.key({ modkey }, "f", fullscreen_fn, { description = "toggle fullscreen", group = "client" }),

		awful.key({ modkey, "Shift" },
				  "c",
				  function(c)
					  c:kill()
				  end,
				  { description = "close", group = "client" }),

-- Place the client window floating in the middle, centered, on top.
-- This is a nice focus geometry.
--awful.key({ modkey, "Control" },
--    "space",
--    function(c)
--        awful.client.floating.toggle()
--        awful.client.maximized = false
--
--        if c.floating then
--            -- place the screen in the middle
--            local geo
--            geo = c:geometry()
--            local sgeo
--            sgeo = c.screen.geometry
--
--            local margin_divisor = 8
--            if sgeo.width > 3000 then
--                margin_divisor = margin_divisor * 2
--            end
--
--            geo.x = sgeo.x + sgeo.width / margin_divisor
--            geo.y = sgeo.y + sgeo.height / margin_divisor
--
--            geo.width = sgeo.width - ((sgeo.width / margin_divisor)*2)
--            geo.height = sgeo.height - ((sgeo.height / margin_divisor)*2)
--            c:geometry(geo)
--        end
--        client.focus = c
--        c:raise()
--    end,
--    { description = "toggle floating centered client", group = "client" }),

-- Place the client window floating in the middle, on top.
-- This is a nice focus geometry.
-- *BUT* this version will stretch the floating geometry vertically,
-- easier for reading.
		awful.key({ altkey, "Control", "Shift", }, -- MEH=ctl+alt+shift
				  "space",
				  function(c)
					  awful.client.floating.toggle()
					  awful.client.maximized = false

					  if c.floating then
						  -- place the screen in the middle
						  local geo
						  geo        = c:geometry()
						  local sgeo
						  sgeo       = c.screen.geometry

						  geo.x      = sgeo.x + sgeo.width / 4
						  geo.y      = sgeo.y

						  geo.width  = sgeo.width * 2 / 4
						  geo.height = sgeo.height
						  c:geometry(geo)
					  end
					  client.focus = c
					  c:raise()
				  end,
				  { description = "toggle floating centered client (tall)", group = "client" }),

-- Isaac
-- I want a hotkey to toggle useless gaps, a function that I've developed a fancy
-- new button for, but now I want to make a key so I don't have to use the button.
		awful.key({ altkey, "Control", "Shift", }, -- MEH=ctl+alt+shift
				  "k",
				  function(c)
					  if c.screen.selected_tag.gap == 0 then
						  c.screen.selected_tag.gap = c.screen.geometry.height / 20
					  else
						  c.screen.selected_tag.gap = 0
					  end
				  end,
				  { description = "toggle useless gaps", group = "client" }),

-- Isaac
-- Now I want a keystroke that toggles whether a client is floating.
		awful.key({ altkey, "Control", "Shift", }, -- MEH=ctl+alt+shift
				  "f",
				  function(c)
					  awful.client.floating.toggle()

					  if not c.floating then
						  return
					  end

					  c.maximized = false

					  -- On big screens (ie. the TV I use as a desktop monitor)
					  -- adjust the window size and position to make for comfortable website reading.
					  if c.screen.geometry.width > 2000 then
						  local geo
						  geo        = c:geometry()
						  local sgeo
						  sgeo       = c.screen.geometry

						  geo.x      = sgeo.x + sgeo.width / 3
						  geo.y      = sgeo.y + sgeo.height / 3
						  geo.width  = sgeo.width / 3
						  geo.height = sgeo.height * 2 / 3

						  c:geometry(geo)
					  end
				  end,
				  { description = "toggle floating", group = "client" }),


		awful.key({ modkey }, "u", function()
			-- Instead of jumping between current and latest CLIENT,
			-- it seems to me now, several months and as many uses of this keybinding later,
			-- that it may be more useful to jump between SCREENS in this way.
			-- Also, this feature is already implemented with MOD+Tab.
			--
			-- https://unix.stackexchange.com/questions/623337/how-to-jump-to-previous-window-in-history-in-awesome-wm
			-- https://unix.stackexchange.com/a/449265

			awful.screen.focus_relative(1)
		end, {
					  description = "focus next screen", group = "client"
				  }),

		awful.key({ modkey, "Control" },
				  "Return",
				  function(c)
					  c:swap(awful.client.getmaster())
				  end,
				  { description = "move to master", group = "client" }),

--awful.key({ modkey },
--    "i",
--    function(c)
--        c:move_to_screen(c.screen.index - 1)
--    end,
--    { description = "move to screen", group = "client" }),
		awful.key({ modkey },
				  "o",
				  function(c)
					  c:move_to_screen()
				  end,
				  { description = "move to screen", group = "client" }),
		awful.key({ modkey },
				  "n",
				  function(c)
					  -- The client currently has the input focus, so it cannot be
					  -- minimized, since minimized clients can't have the focus.
					  c.minimized = true
				  end,
				  { description = "minimize", group = "client" }),
		awful.key({ modkey },
				  "m",
				  function(c)
					  c.maximized = not c.maximized
					  c:raise()
				  end,
				  { description = "maximize", group = "client" }))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view         = { description = "view tag #", group = "tag" }
		descr_toggle       = { description = "toggle tag #", group = "tag" }
		descr_move         = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end
	globalkeys = my_table.join(globalkeys,
	-- View tag only.
							   awful.key({ modkey },
										 "#" .. i + 9,
										 function()
											 local screen = awful.screen.focused()
											 local tag    = screen.tags[i]
											 if tag then
												 tag:view_only()
											 end
										 end,
										 descr_view),
	-- Toggle tag display.
							   awful.key({ modkey, "Control" },
										 "#" .. i + 9,
										 function()
											 local screen = awful.screen.focused()
											 local tag    = screen.tags[i]
											 if tag then
												 awful.tag.viewtoggle(tag)
											 end
										 end,
										 descr_toggle),
	-- Move client to tag.
							   awful.key({ modkey, "Shift" },
										 "#" .. i + 9,
										 function()
											 if client.focus then
												 local tag = client.focus.screen.tags[i]
												 if tag then
													 client.focus:move_to_tag(tag)
												 end
											 end
										 end,
										 descr_move),
	-- Toggle tag on focused client.
							   awful.key({ modkey, "Control", "Shift" },
										 "#" .. i + 9,
										 function()
											 if client.focus then
												 local tag = client.focus.screen.tags[i]
												 if tag then
													 client.focus:toggle_tag(tag)
												 end
											 end
										 end,
										 descr_toggle_focus))
end

-- Set up client management buttons FOR THE MOUSE.
-- (1 is left, 3 is right)
clientbuttons = my_table.join(awful.button({},
										   1,
										   function(c)
											   client.focus = c
											   c:raise()
										   end),
							  awful.button({ modkey }, 1, awful.mouse.client.move),
							  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	--[[  ]]
	-- All clients will match this rule.
	{
		rule       = {},
		properties = {
			border_width     = beautiful.border_width,
			border_color     = beautiful.border_normal,
			focus            = awful.client.focus.filter,
			raise            = true,
			keys             = clientkeys,
			buttons          = clientbuttons,
			screen           = awful.screen.preferred, --.focused(),
			-- placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			placement        = awful.placement.no_offscreen,
			size_hints_honor = false
		}
	},
	-- Titlebars
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
	}

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

-- https://www.reddit.com/r/awesomewm/comments/sok8dm/how_to_hide_titlebar/
--client.connect_signal("request::default_keybindings", function()
--    awful.keyboard.append_client_keybindings({
--        -- show/hide titlebar
--        awful.key({ modkey }, "t", awful.titlebar.toggle,
--                {description = "Show/Hide Titlebars", group="client"}),
--    })
--end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.

local mytitlebars = function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons = my_table.join(
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

	awful.titlebar(c, { size = 16 }):setup {
		{
			-- Left
			awful.titlebar.widget.iconwidget(c),
			awful.titlebar.widget.titlewidget(c),
			buttons = buttons,
			spacing = 5,
			layout  = wibox.layout.fixed.horizontal
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
			awful.titlebar.widget.closebutton(c),
			spacing = 5, -- https://awesomewm.org/doc/api/classes/wibox.layout.fixed.html#wibox.layout.fixed.spacing
			layout = wibox.layout.fixed.horizontal()
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
					  end)

client.connect_signal("focus", function(c)
	border_adjust(c)
	move_mouse_onto_focused_client(c)
end)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus",
					  function(c)
						  c.border_color = beautiful.border_normal
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
