--[[

     Awesome WM configuration template
     github.com/whilei

--]]

-- awesome_mode: api-level=5:screen=on
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
local g_table                                               = gears.table or awful.util.table -- 4.{0,1} compatibility
--local _                                                     = require("awful.autofocus")
local wibox                                                 = require("wibox")
local beautiful                                             = require("beautiful")
local naughty                                               = require("naughty")
local lain                                                  = require("lain")
local hotkeys_popup                                         = require("awful.hotkeys_popup").widget
local cairo                                                 = require("lgi").cairo
local ruled                                                 = require("ruled")

local ia_layout_swen                                        = require("layout-swen")
local layout_titlebars_conditional                          = require("layout-titlebars-conditional")

local icky_keys                                             = require("icky.keys")
local modality                                              = require("modality")
local special_log_load_time                                 = require("special").log_load_time
local special_log_load_time_reset                           = require("special").log_load_time_reset

special_log_load_time("requirements")

--naughty.config.presets.critical.position = "top_middle"
--naughty.config.presets.normal.position   = "top_middle"
--naughty.config.presets.low.position      = "top_middle"

-- {{{ Error handling
special_log_load_time_reset()
if awesome.startup_errors then
	naughty.notification {
		preset  = naughty.config.presets.critical,
		title   = "Awesome errored during startup",
		message = awesome.startup_errors
	}
end

do
	local in_error = false
	awesome.connect_signal("debug::error",
						   function(err)
							   if in_error then
								   return
							   end
							   in_error = true

							   naughty.notification {
								   preset  = naughty.config.presets.critical,
								   title   = "Awesome error",
								   message = tostring(err)
							   }
							   in_error = false
						   end)
end
special_log_load_time("notify of startup errors")
-- }}}


if not awful.client.focus.history.is_enabled() then
	awful.client.focus.history.enable_tracking()
end

local compositor_cmd = "picom -b" -- -b makes it a daemon
awful.spawn.easy_async(compositor_cmd, function(stdout, stderr, reason, code)
	if code ~= 0 then
		naughty.notification {
			preset  = naughty.config.presets.normal,
			title   = "'" .. compositor_cmd .. "'" .. " errored: " ..
					"code=" .. tostring(code) .. " " ..
					"reason=" .. tostring(reason) ..
					"",
			message = "stderr=\n" .. stderr,
		}
	end
end)

special_log_load_time("started picom")


-- {{{ Variable definitions

local chosen_theme  = "ia"
local modkey        = "Mod4"
local altkey        = "Mod1"
local terminal      = "xterm"
local editor        = os.getenv("EDITOR") or "vim"
local gui_editor    = "code"
local browser       = "ffox"
local guieditor     = "code"
local scrlocker     = "xlock"

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

special_log_load_time_reset()
tag.connect_signal("request::default_layouts",
				   function()
					   awful.layout.append_default_layouts {
						   _layouts.tiler,
						   _layouts.swen,
						   lain.layout.centerwork,
						   awful.layout.suit.floating,
					   }
				   end)

special_log_load_time("tag.connect_signal request::default_layouts")

awful.util.taglist_buttons = g_table.join(
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

special_log_load_time("taglist_buttons")

awful.util.tasklist_buttons = g_table.join(
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

special_log_load_time("tasklist_buttons")

local theme_path = gears.filesystem.get_configuration_dir() .. "themes/" .. chosen_theme .. "/theme.lua"
beautiful.init(theme_path)

special_log_load_time("beautiful.init")

modality.init()

special_log_load_time("modality.init")

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
--


-- who really needs a menu anyways (https://www.reddit.com/r/awesomewm/comments/ludsl7/comment/iukgex6/?context=3)

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
							  awful.wallpaper {
								  screen = s,
								  widget = {
									  {
										  image  = wallpaper,
										  resize = true,
										  widget = wibox.widget.imagebox,
									  },
									  valign = "center",
									  halign = "center",
									  widget = wibox.container.place,
								  },
							  }
						  end
					  end)

special_log_load_time("screen.connect_signal property::geometry")

-- Create a wibox for each screen and add it
-- HERE COMMENTED
screen.connect_signal("request::desktop_decoration", function(s)
	beautiful.at_screen_connect(s)
end)

special_log_load_time("screen.connect_signal property::desktop_decoration")

icky_keys()

special_log_load_time("icky_keys()")


-- Set up client management buttons FOR THE MOUSE.
-- (1 is left, 3 is right)
clientbuttons           = g_table.join(
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

---- This is an idea about setting up global mouse button bindings.
---- Maybe something with the back/forward buttons? Scroll?
---- https://awesomewm.org/doc/api/libraries/mouse.html
--root.buttons(a_util_table.join(
--		awful.button({ modkey }, 3, function()
--			awful.util.mymainmenu:toggle()
--		end),
--		awful.button({ modkey }, 4, awful.tag.viewnext),
--		awful.button({ modkey }, 5, awful.tag.viewprev)
--		))

-- }}}

-- The original Konsole icon was a bell.
-- I thought this was stupid, so I'm changing it to a terminal icon.
-- According to the internet (see link below) konsole_icon MUST be stored in a variable; no golfing allowed.
-- I'm also storing it in a global because it seems like a "broader" change,
-- but I'm not sure it's the best way to do it.
-- https://stackoverflow.com/a/30379815
local konsole_icon_path = gears.filesystem.get_configuration_dir() .. "awesome-buttons/icons/terminal.svg"
konsole_icon            = gears.surface(konsole_icon_path)._native

--local awesome_icon_path = gears.filesystem.get_configuration_dir() .. "themes/rainbow/icons/awesome.png"
--local awesome_icon      = gears.surface(awesome_icon_path)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
ruled.client.append_rules {
	--[[  ]]
	-- All clients will match this rule.
	{
		rule       = {},
		properties = {
			focus            = awful.client.focus.filter,
			raise            = true,
			keys             = icky_keys.get_client_awful_keys(),
			buttons          = clientbuttons,
			screen           = awful.screen.preferred, --.focused(),
			placement        = awful.placement.no_offscreen + awful.placement.no_overlap,
			size_hints_honor = true
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
		rule       = { handy_id = ".*", },
		properties = {
			skip_taskbar = true,
			placement    = awful.placement.no_offscreen
		}
	},
	{
		rule       = { class = "konsole", },
		properties = { icon = konsole_icon, },
	},
	-- This rule tries to keep quake out of the tag list and tasklist.
	{
		rule       = { instance = "q-xterm-konsole", },
		properties = {
			skip_taskbar = true,
			skip_taglist = true,
		},
	},
	{
		rule       = { class = "Xephyr", },
		properties = {
			border_width         = 2,
			border_color         = "#A32BCE",
			screen               = screen[1],
			tag                  = screen[1].tags[5],
			placement            = awful.placement.centered,
			floating             = true,
			maximized_vertical   = true,
			maximized_horizontal = true,
			ontop                = true,

			-- Do NOT focus right away.
			focus                = false,

			-- Titlebars are important because they indicate to the user whether
			-- you've 'grabbed the mouse and keyboard', ie. have focus on a client.
			titlebars_enabled    = true,
			--icon                 = awesome_icon._native, -- https://stackoverflow.com/a/30379815
		}
	},
	{
		rule       = { floating = true, },
		properties = {
			shape = function(cc, w, h)
				-- Round only the top corners.
				--gears.shape.rounded_rect(c, w, h,)
				local tl, tr, br, bl, rad = true, true, false, false, math.min(10, h / 10)
				return gears.shape.partially_rounded_rect(cc, w, h, tl, tr, br, bl, rad)
			end,
		}
	},
	{
		rule       = { class = "kate", },
		properties = {
			floating  = true,
			placement = awful.placement.centered,
		},
	},
	{
		rule       = { class = "jetbrains-toolbox", },
		properties = {
			minimized = true,
			floating  = false,
			focus     = false, -- This thing never works quite right for me.
		}
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("request::manage",
					  function(c)
						  -- Set the windows at the slave,
						  -- i.e. put it at the end of others instead of setting it master.
						  -- if not awesome.startup then awful.client.setslave(c) end

						  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
							  -- Prevent clients from being unreachable after screen count changes.
							  awful.placement.no_offscreen(c)
						  end

						  if awesome.startup then
							  -- Hide Handy clients after an awesome restart.
							  local x_handy = c:get_xproperty("handy_id")
							  if x_handy and x_handy ~= "" then
								  c.hidden       = true
								  c.visible      = false
								  c.skip_taskbar = true
							  end

							  ---- Make sure Quake doesn't get put in the taglist entry.
							  --if c.instance == "q-xterm-konsole" then
							  --  c.hidden       = true
							  --  c.visible      = false
							  --  c.skip_taskbar = true
							  --end

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
	local buttons    = g_table.join(
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
	if not c then
		return
	end

	--border_adjust(c)

	move_mouse_onto_focused_client(c)

	local t = c.first_tag
	if not t then
		-- This can happen for clients like Handy or other on-demand only clients.
		return
	end
	for _, tc in ipairs(t:clients()) do
		if tc ~= c then
			--awful.titlebar.show(c)
			tc.border_color = beautiful.border_normal
		end
	end
end)

--client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus", function(c)
	--c.border_color = beautiful.border_normal
end)

-- }}}

-- https://unix.stackexchange.com/questions/401539/how-to-disallow-any-application-from-stealing-focus-in-awesome-wm
--awful.ewmh.add_activate_filter(function() return false end, "ewmh")
--awful.ewmh.add_activate_filter(function() return false end, "rules")

---- https://stackoverflow.com/questions/44571965/awesome-wm-applications-fullscreen-mode-without-taking-whole-screen
client.disconnect_signal("request::geometry", awful.permissions.geometry)
client.connect_signal("request::geometry", function(c, context, ...)
	if context == "fullscreen" and c.sticky then
		-- ignore; I want the world cup in a picture-in-picture type deal
	else
		awful.permissions.geometry(c, context, ...)
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
