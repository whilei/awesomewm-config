--[[

     Awesome WM configuration template
     github.com/whilei

--]]

-- awesome_mode: api-level=42:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- {{{ Required libraries
local awesome, screen, client, mouse, tag = awesome, screen, client, mouse, tag
local string, tostring, type, math        = string, tostring, type, math

-- This chunk adds this path (of the current configuration)
-- to the Lua packages search path, enabling the loading of local libs.
local gears                               = require("gears")
local prefix                              = gears.filesystem.get_configuration_dir() .. ""
package.path                              = package.path .. ";" .. prefix .. "?.lua;" .. prefix .. "?/init.lua"

local awful                               = require("awful")
local g_table                             = gears.table or awful.util.table -- 4.{0,1} compatibility
local wibox                               = require("wibox")
local beautiful                           = require("beautiful")
local naughty                             = require("naughty")
local lain                                = require("lain")
--local cairo                                                 = require("lgi").cairo
local ruled                               = require("ruled")

local ia_layout_swen                      = require("layout-swen")
local layout_titlebars_conditional        = require("layout-titlebars-conditional")

local icky                                = require("icky")
local modality                            = require("modality")
local special_log_load_time               = require("special").log_load_time
local special_log_load_time_reset         = require("special").log_load_time_reset
local hood                                = require("hood")
dofile(gears.filesystem.get_configuration_dir() .. "/monkeys/global_keyboard_signals.lua")

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


-- Only start picom if there were no errors because
-- my tv is going black when I start with errors now and
-- it didn't used to before I added picom, so its getting the blame
-- until I learn otherwise.
if not awesome.startup_errors and not awesome.composite_manager_running then
	local compositor_cmd = "picom -b" -- -b makes it a daemon
	awful.spawn.easy_async(compositor_cmd, function(_, stderr, reason, code)
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
end

if awesome.startup then
	awful.spawn.easy_async_with_shell(
			"wget --directory-prefix /tmp 'https://water.weather.gov/resources/hydrographs/gcdw1_hg.png'", function(stdout, stderr)
				print(stdout)
				print(stderr)
			end)
end

if not awful.client.focus.history.is_enabled() then
	awful.client.focus.history.enable_tracking()
end

-- {{{ Variable definitions

--local chosen_theme  = "powerarrow-dark"
local chosen_theme  = "ia"
local modkey        = "Mod4"
--local altkey        = "Mod1"
local terminal      = "xterm"
--local editor        = os.getenv("EDITOR") or "vim"
--local gui_editor    = "emacs"
--local browser       = "ffox"
--local scrlocker     = "xlock"

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
	--tiler = layout_titlebars_conditional { layout = awful.layout.suit.tile },
	--swen  = layout_titlebars_conditional { layout = ia_layout_swen },
	tiler = awful.layout.suit.tile,
	swen  = ia_layout_swen,
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
-- Left-click on a tag views it.
		awful.button({}, 1, function(t)
			t:view_only()
		end),

-- Super + left-click on a tag entry moves currently focused client to that tag.
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),

-- Right clicking on tag entry toggles tag view (can view multiple tags at once).
		awful.button({}, 3, awful.tag.viewtoggle),

-- Super + right-click on a tag entry toggles the currently focused client's association with that tag.
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),

-- Scroll while hovering over the tag list cycles through viewing tags.
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


---- --------------------------------------------------------------------
---- EXPERIMENTAL
---- This commented code chunk logs events that the 'monkey' experiment adds to awesome.
---- See the 'dofile' command near the requirements chunk of this file.
---- It is fully functional, but spits logs that I don't care about right now.
--awesome.connect_signal("monkey::global_keybindings::added", function(keys)
--	for _, k in ipairs(keys) do
--		print("<- monkey::global_keybindings::added: " .. tostring(k.modalities))
--	end
--end)
--
--awesome.connect_signal("monkey::global_keybinding::added", function(key)
--	print("<- monkey::global_keybinding::added: " .. tostring(key.modalities[1] or "-"))
--end)
--
--awesome.connect_signal("monkey::global_keybinding::removed", function(key)
--	print("<- monkey::global_keybinding::removed: " .. tostring(key))
--end)
--
---- PTAL This signal is undocumented.
--client.connect_signal("client_keybinding::added", function(key)
--	print("<- client_keybinding::added: " .. tostring(key))
--end)
---- --------------------------------------------------------------------

icky.keys.register_global_keybindings()
client.connect_signal("request::default_keybindings", icky.keys.register_client_keybindings)
client.connect_signal("request::default_mousebindings", function()
	-- Set up client management buttons FOR THE MOUSE.
	-- (1 is left, 3 is right)
	awful.mouse.append_client_mousebindings {
		awful.button({}, 1, function(c)
			client.focus = c
			c:raise()
		end),
		awful.button({ modkey }, 1, function(c)
			c.floating  = true
			c.maximized = false
			awful.mouse.client.move()
		end),
		awful.button({}, 2, icky.fns.client.properties.fullscreen),
		awful.button({ modkey }, 3, function(c)
			c.floating  = true
			c.maximized = false
			awful.mouse.client.resize()
		end)
	}
end)

special_log_load_time("keybindings and mousebindings registered")

modality.init()

special_log_load_time("modality.init")

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s) s:emit_signal("request::wallpaper") end)
screen.connect_signal("request::wallpaper", function(s)
	awful.wallpaper {
		screen = s,
		bg     = "#000000",
	}

	--awful.wallpaper {
	--	screen = s,
	--	widget = {
	--		{
	--			image  = type(beautiful.wallpaper) == "string"
	--					and beautiful.wallpaper
	--					or beautiful.wallpaper(s),
	--			resize = true,
	--			widget = wibox.widget.imagebox,
	--		},
	--		valign = "center",
	--		halign = "center",
	--		widget = wibox.container.place,
	--	},
	--}

	--awful.wallpaper {
	--	screen = s,
	--	bg     = {
	--		type  = "linear",
	--		from  = { 0, 0 },
	--		to    = { 0, s.geometry.height },
	--		stops = {
	--			{ 0, "#0000ff" },
	--			{ 1, "#ff0000" }
	--		}
	--	}
	--}
end)

special_log_load_time("wallpaper")

-- Create a wibox for each screen and add it
-- HERE COMMENTED
screen.connect_signal("request::desktop_decoration", function(s)
	beautiful.at_screen_connect(s)
end)

special_log_load_time("screen.connect_signal property::desktop_decoration")


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
local konsole_icon      = gears.surface(konsole_icon_path)._native

--local awesome_icon_path = gears.filesystem.get_configuration_dir() .. "themes/rainbow/icons/awesome.png"
--local awesome_icon      = gears.surface(awesome_icon_path)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rules {
		--[[  ]]
		-- All clients will match this rule.
		{
			rule       = {},
			properties = {
				focus            = awful.client.focus.filter,
				raise            = true,
				--keys             = icky.keys.get_client_awful_keys(),
				screen           = awful.screen.preferred, --.focused(),
				placement        = awful.placement.no_offscreen + awful.placement.no_overlap + awful.placement.centered,
				size_hints_honor = true
			}
		},
		-- @DOC_FLOATING_RULE@
		-- Floating clients.
		{
			id         = "floating",
			rule_any   = {
				instance = { "copyq", "pinentry" },
				class    = {
					"Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
					"Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
				},
				-- Note that the name property shown in xprop might be set slightly after creation of the client
				-- and the name shown there might not match defined rules here.
				name     = {
					"Event Tester", -- xev.
				},
				role     = {
					"AlarmWindow", -- Thunderbird's calendar.
					"ConfigManager", -- Thunderbird's about:config.
					"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				}
			},
			properties = { floating = true }
		},
		---- Titlebars
		--{
		--	rule       = { maximized = true },
		--	properties = { titlebars_enabled = false },
		--},
		-- Dialogs.
		{
			rule_any   = { type = { "dialog", "normal" } },
			properties = { titlebars_enabled = true }
		},
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
		-- Xephyr is the tool `awmtt` uses to emulate an awesomeWM instance for development.
		-- AFAIK, it is not used for anything else.
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
		-- Round the top corners of floating clients to show me that they are floating.
		{
			rule       = { floating = true, },
			properties = {
				shape = function(cc, w, h)
					local tl, tr, br, bl, rad = true, true, false, false, math.min(10, h / 10)
					return gears.shape.partially_rounded_rect(cc, w, h, tl, tr, br, bl, rad)
				end,
			}
		},
		-- Kate is a simple text editor and I like that about it.
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
				focus     = false, -- This thing never works quite right for me.
				floating  = true,
				placement = awful.placement.centered,
			}
		}
	}
end)
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

local mytitlebars = function(c, context, hints)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons       = g_table.join(
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
	local ci            = awful.widget.clienticon(c);
	ci.forced_width     = 12
	ci.forced_height    = 12

	local title_textbox = awful.titlebar.widget.titlewidget(c)
	local args          = {
		size     = 16,
		--position = "left",
		bg_focus = c.maximized and beautiful.color_green,
		fg_focus = c.maximized and "#000000",
	}
	if c.maximized then
		local text = title_textbox:get_text()
		title_textbox:set_text("" .. text .. " *Z")
	end

	awful.titlebar(c, args):setup {
		{
			-- Left
			wibox.widget.textbox(" "),
			nil,
			nil,
			buttons = buttons,
			spacing = 5,
			layout  = wibox.layout.fixed.horizontal,
		},
		{
			-- Middle
			wibox.container.place { widget = ci, valign = "center" },
			--ci,
			title_textbox,
			nil,
			buttons = buttons,
			spacing = 5,
			expand  = "none",
			layout  = wibox.layout.align.horizontal
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
		expand = "inside",
		layout = wibox.layout.align.horizontal
	}
end

client.connect_signal("request::titlebars", mytitlebars)

local isJavaInstance = function(instance)
	-- xprop WM_CLASS
	-- WM_CLASS(STRING) = "sun-awt-X11-XFramePeer", "jetbrains-studio"
	-- THIS ONE IS THE ORIGINAL GOOD ONE:
	return instance and instance ~= "" and string.match(instance, '^sun-awt-X11-X')
end

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter",
					  function(c)
						  local focused = client.focus
						  if focused
								  and focused.class == c.class
								  and isJavaInstance(focused.instance)
								  and isJavaInstance(c.instance)
						  then
							  return -- early
						  end

						  local layout_is_not_magnifier = awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
						  local filter_ok               = awful.client.focus.filter(c)
						  local is_not_minimized        = (not c.minimized) -- IDK but this fixes a bug where toggling minimization fails to minimize (just flicker).
						  if layout_is_not_magnifier and filter_ok and is_not_minimized
						  then
							  c:activate { context = "mouse_enter", raise = false }
						  end
					  end)

-- move_mouse_onto_focused_client_on_focus_shift
-- move the mouse to the (newly) focused client when the focus event is emitted.
-- This function is similar to, but significantly different from,
-- special.move_mouse_to_focused_client because the latter does
-- not try to handle "intuitive" focus-shift expectations.
local function move_mouse_onto_focused_client_on_focus_shift(c)
	if c == nil then
		return
	end
	local no_mouse_obj = not mouse.object_under_pointer()
	--if mouse.object_under_pointer() == nil then
	--	return
	--end

	-- The object (window, eg) under the mouse IS the client in question.
	if mouse.object_under_pointer() == c then
		return
	end

	-- Prevent mouse snapping to client when...
	-- The mouse is already in the focused client's screen.
	if mouse.screen == c.screen then return end

	-- The mouse is up in the wibar, when
	-- selecting a tag is selected from the taglist in the menubar wibox.
	if mouse.current_wibox ~= nil then
		return
	end

	---- The focused client is floating or on-top.
	--if c.floating or c.ontop then
	--	return
	--end

	-- Only reposition the mouse if the new client is on the other screen.
	if (not no_mouse_obj) and mouse.object_under_pointer().screen == c.screen then
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

-- make rofi possible to raise minimized clients
client.connect_signal("request::activate",
					  function(c, context, hints)
						  if c.minimized then
							  c.minimized = false
						  end
						  awful.permissions.activate(c, context, hints)
					  end)

-- FIXME
-- Using 'activate' callback here instead of 'autoactivate', which should be preferred.
-- The bug at issue here is that when I toggle = hide a Handy client,
-- the previous client's focus is not always regained; especially when the toggle happens... fast?
client.connect_signal("request::autoactivate", function(c, context, hints)
	awful.permissions.activate(c, context, hints)

	--- This chunk does not work well.
	--awful.permissions.autoactivate(c, context, hints)
	--if client.focus == nil then awful.permissions.activate(c, context, hints) end
end)

client.connect_signal("focus", function(c)
	if not c then return end
	move_mouse_onto_focused_client_on_focus_shift(c)
end)

client.connect_signal("unfocus", function(c)
	if not c then return end
	if c.class:lower() == "firefox" and c:get_xproperty("handy_id") ~= nil then
		--awful.client.focus.history.restore()
	end
	-- Anything else?
end)

client.connect_signal("request::unmanage", function(c)
	if not c then return end

	-- This fixes a bug where jetbrains-clion would show me a
	-- line-number-picker pop-up, but then after I type in which line number I want
	-- (and the dialog goes away), the original jetbrains-clion IDE window
	-- would NOT regain focus.
	-- I have not noticed the issue with any other client classes,
	-- but this solution tries to be general enough to catch them before I do.
	if c.transient_for ~= nil then
		--c.transient_for.emit_signal("request::activate", "unmanage", { raise = true })
		client.focus = c.transient_for
	end
end)

-- }}}

-- https://unix.stackexchange.com/questions/401539/how-to-disallow-any-application-from-stealing-focus-in-awesome-wm
-- https://stackoverflow.com/questions/44571965/awesome-wm-applications-fullscreen-mode-without-taking-whole-screen
client.disconnect_signal("request::geometry", awful.permissions.geometry)
client.connect_signal("request::geometry", function(c, context, hints)
	if context == "fullscreen" and c.sticky then
		-- ignore; I want the world cup in a picture-in-picture type deal
		print("WARNING Ignoring fullscreen request for sticky client")
	else
		awful.permissions.geometry(c, context, hints)
	end
end)

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
	-- All notifications will match this rule.
	ruled.notification.append_rule {
		rule       = { },
		properties = {
			screen           = awful.screen.preferred,
			implicit_timeout = 10,
		}
	}
end)

naughty.connect_signal("request::display", function(n)
	naughty.layout.box { notification = n }
end)

local lightly = true
if lightly
then
	-- AwesomeWM is about to enter the event loop.
	-- This means all initialization has been done.
	awesome.connect_signal("startup", function()
		print("awesome::startup - Now entering event loop...")
		print("Starting Hood...")
		hood.init(screen[1])
		--hood.show()
	end)

	awesome.connect_signal("exit", function(is_restart)
		print("AwesomeWM is exiting. Is restart? " .. tostring(is_restart))
	end)

	--awesome.connect_signal("refresh", function()
	--	--print("[cool] refresh")
	--end)
end

client.connect_signal("property::maximized", function(c)
	c:emit_signal("request::titlebars", "property::maximized", { raise = false })
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
