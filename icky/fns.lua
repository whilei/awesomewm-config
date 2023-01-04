---------------------------------------------------------------------------
-- Fns
--
-- Icky functions (for key bindings) and what to do with them.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod icky.fns
---------------------------------------------------------------------------

-- c api libs
local awesome, client, root, mouse = awesome, client, root, mouse
local os, string, tostring         = os, string, tostring

-- awesome libs
local awful                        = require("awful")
local hotkeys_popup                = require("awful.hotkeys_popup").widget
local beautiful                    = require("beautiful")
local freedesktop                  = require("freedesktop")
local gears                        = require("gears")
local naughty                      = require("naughty")
local lain                         = require("lain")

-- contrib
local handy                        = require("handy")
local hints                        = require("hints")
local klack                        = require("klack")
local pretty                       = require("special.pretty")
local revelation                   = require("revelation")
local special                      = require("special")
local ia_layout_swen               = require("layout-swen")
local layout_titlebars_conditional = require("layout-titlebars-conditional")

-- inits for contrib libs
hints.init()
revelation.init()

---------------------------------------------------------------------------
-- HELPERS

local raise_focused_client          = function()
	if client.focus then
		client.focus:raise()
	end
end

local _layouts                      = {
	--tiler = layout_titlebars_conditional { layout = awful.layout.suit.tile },
	--swen  = layout_titlebars_conditional { layout = ia_layout_swen },
	tiler = awful.layout.suit.tile,
	swen  = ia_layout_swen,
}

---------------------------------------------------------------------------

local global_fns                    = {
	awesome    = {
		restart      = awesome.restart,
		-- show_main_menu = (see below),
		hotkeys_help = hotkeys_popup.show_help,
		wibar        = special.toggle_wibar_slim,
		widgets      = {
			world_times = special.toggle_wibar_worldtimes,
			calendar    = function()
				awful.screen.focused().my_calendar_widget.toggle()
			end,
			weather     = function()
				special.weather.show()
			end,
		},
		dash         = function()
			local s = awful.screen.focused()
			if not s.dash or (not s.dash.bar.visible) then
				s.dash = require("dash").init(s)
			end
			s.dash.bar.visible = not s.dash.bar.visible
		end,
	},
	apps       = {
		single_instance = function(app_by_name)
			return function()
				local matcher = function(c)
					return awful.rules.match(c, { class = app_by_name })
				end
				awful.spawn.single_instance(app_by_name, nil, matcher)
			end
		end,
		handy           = {
			top  = function()
				handy("ffox --class handy-top", awful.placement.top, 0.5, 0.5)
			end,
			left = function()
				handy("ffox --class handy-left", awful.placement.left, 0.25, 0.9)
			end,
		},
		rofi            = function(modi)
			-- Location values:
			-- 1   2   3
			-- 8   0   4
			-- 7   6   5
			--local tv_prompt       = "rofi -modi " .. modi .. " -show " .. modi .. " -sidebar-mode -location 6 -theme Indego -width 20 -no-plugins -no-config -no-lazy-grab -async-pre-read 1 -show-icons"
			--local laptop_prompt   = "rofi -modi " .. modi .. " -show " .. modi .. " -sidebar-mode -location 6 -theme Indego -width 40 -no-plugins -no-config -no-lazy-grab -async-pre-read 1 -show-icons"
			--local commandPrompter = awful.screen.focused().is_tv and tv_prompt or laptop_prompt

			local rofi_theme = pretty.rofi_theme_path_drun
			if modi ~= "drun" then
				rofi_theme = pretty.rofi_theme_path_window
			end

			local rofi_prompt = "All apps: "
			if modi == "window" then
				rofi_prompt = "Find clients: "
			end
			rofi_prompt = "-p '" .. rofi_prompt .. "' "

			local cmd   = "" ..
					"rofi " ..
					rofi_prompt ..
					" -show " .. modi ..
					" -theme " ..
					rofi_theme

			if modi == "drun" then
				return function()
					awful.spawn.easy_async(cmd, function(stdout, stderr, reason, exit_code)
						if exit_code == 0 and stdout ~= "" then
							local matcher = function(c)
								return awful.rules.match(c, { class = stdout })
							end
							awful.spawn.single_instance(stdout, matcher)
						end
					end)
				end
			elseif modi == "window" then
				return function()
					awful.spawn.easy_async(cmd, function()
						if client.focus then
							awful.screen.focus(client.focus.screen)
						end
					end)
				end
			end
		end,
		quake           = function()
			special.quake:toggle()
		end,
		popup_launcher  = special.popup_launcher.launch,
		revelation      = revelation,
	},
	client     = {
		focus   = {
			back_global = special.focus_previous_client_global,
			back_local  = function()
				awful.client.focus.history.previous()
				if client.focus then
					client.focus:raise()
				end
			end,
			index       = {
				next = function()
					awful.client.focus.byidx(1)
				end,
				prev = function()
					awful.client.focus.byidx(-1)
				end
			},
			direction   = {
				up    = function()
					awful.client.focus.global_bydirection("up")
					raise_focused_client()
				end,
				down  = function()
					awful.client.focus.global_bydirection("down")
					raise_focused_client()
				end,
				left  = function()
					awful.client.focus.global_bydirection("left")
					raise_focused_client()
				end,
				right = function()
					awful.client.focus.global_bydirection("right")
					raise_focused_client()
				end,
			}
		},
		swap    = {
			index = {
				next = function()
					awful.client.swap.byidx(1)
				end,
				prev = function()
					awful.client.swap.byidx(-1)
				end
			},
		},
		restore = function()
			local c = awful.client.restore()
			if c then
				client.focus = c
				c:raise()
			end
		end,
		hints   = function()
			hints.focus();
			raise_focused_client()
		end,
	},
	media      = {
		--[[
		Volume can be queried with
		--]]
		--	pactl list sinks | grep '^[[:space:]]Volume:' | \
		--		head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
		-- These functions were generated by Copilot and they
		-- dont seem crazy.
		-- I just installed pavucontrol or whatever, and have tried
		-- a few of these pactl commands in the terminal and they seem
		-- to work ok.
		-- But I dont think they're wired in properly to my theme UI widgets
		-- yet, so I'm going to stick with the amixer commands I originally
		-- have been using.
		-- TODO Maybe swap for pactl commands.
		--volume = {
		--	up   = function()
		--		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
		--	end,
		--	down = function()
		--		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
		--	end,
		--	mute = function()
		--		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
		--	end,
		--},
		--},
		mic_toggle = function()
			os.execute("amixer -q set Capture toggle")
			beautiful.mic.update()
			--naughty.notification { position = "bottom_middle", message = "Mic toggled" }
		end,
		volume     = {
			up   = function()
				os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
				beautiful.volume.update()
			end,
			down = function()
				os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
				beautiful.volume.update()
			end,
			mute = function()
				os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
				beautiful.volume.update()
			end,
		},
	},
	power_user = {
		lock      = function()
			os.execute(gears.filesystem.get_configuration_dir() .. "screenlock.sh")
		end,
		logout    = function()
			os.execute("service lightdm restart")
		end,
		suspend   = function()
			os.execute("systemctl suspend")
		end,
		reboot    = function()
			os.execute("systemctl reboot")
		end,
		power_off = function()
			os.execute("systemctl poweroff")
		end
	},
	screen     = {
		-- Instead of jumping between current and latest CLIENT,
		-- it seems to me now, several months and as many uses of this keybinding later,
		-- that it may be more useful to jump between SCREENS in this way.
		-- Also, this feature is already implemented with MOD+Tab.
		next          = function()
			awful.screen.focus_relative(1)
		end,
		prev          = function()
			awful.screen.focus_relative(-1)
		end,
		invert_colors = function()
			os.execute("xrandr-invert-colors")
		end,
	},
	screenshot = {
		selection = function()
			special.saved_screenshot {
				interactive     = true,
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot_selection",
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		window    = function()
			special.saved_screenshot {
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot_window",
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		screen    = function()
			special.saved_screenshot {
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot_screen",
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				screen          = awful.screen.focused(),
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		client    = function()
			special.saved_screenshot {
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot_client_" .. client.focus.class:gsub("%s+", "_"),
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				client          = client.focus,
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		delayed   = {
			window = function()
				special.saved_screenshot {
					directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
					prefix          = "screenshot_window",
					date_format     = "%Y-%m-%d-%H%M%S",
					auto_save_delay = 5,
					--exec            = screenshot_notifier { label = "selection" },
				}
			end,
			screen = function()
				special.saved_screenshot {
					directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
					prefix          = "screenshot_screen",
					date_format     = "%Y-%m-%d-%H%M%S",
					auto_save_delay = 5,
					screen          = awful.screen.focused(),
					--exec            = screenshot_notifier { label = "selection" },
				}
			end,
			client = function()
				special.saved_screenshot {
					directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
					prefix          = "screenshot_client_" .. client.focus.class:gsub("%s+", "_"),
					date_format     = "%Y-%m-%d-%H%M%S",
					auto_save_delay = 5,
					client          = client.focus,
					--exec            = screenshot_notifier { label = "selection" },
				}
			end,
		},
	},
	tag        = {
		add     = function()
			local t = awful.tag.add("My New Tag", {
				screen = awful.screen.focused(),
				layout = awful.layout.suit.floating })
			t:view_only()
		end,
		delete  = function()
			local t = awful.screen.focused().selected_tag
			if not t then
				return
			end
			t:delete()
		end,
		rename  = function()
			awful.prompt.run {
				prompt       = "New tag name: ",
				textbox      = awful.screen.focused().mypromptbox.widget,
				exe_callback = function(new_name)
					if not new_name or #new_name == 0 then
						return
					end

					local t = awful.screen.focused().selected_tag
					if t then
						t.name = new_name
					end
				end
			}
		end,
		next    = awful.tag.viewnext,
		prev    = awful.tag.viewprev,
		restore = awful.tag.history.restore,
		move    = {
			left  = function()
				lain.util.move_tag(-1)
			end,
			right = function()
				lain.util.move_tag(1)
			end
		},
		layout  = {
			next                 = function()
				awful.layout.inc(1)
			end,
			previous             = function()
				awful.layout.inc(-1)
			end,
			master_width_factor  = {
				increase = function()
					awful.tag.incmwfact(0.05)
					return true
				end,
				decrease = function()
					awful.tag.incmwfact(-0.05)
					return true
				end,
				invert   = function()
					local t = awful.screen.focused().selected_tag
					if not t then return end
					t:set_master_width_factor(1 - t.master_width_factor)
				end
			},
			master_client_number = {
				increase = function()
					awful.tag.incnmaster(1, nil, true)
					return true
				end,
				decrease = function()
					awful.tag.incnmaster(-1, nil, true)
					return true
				end,
			},
			columns              = {
				increase = function()
					awful.tag.incncol(1, nil, true)
					return true
				end,
				decrease = function()
					awful.tag.incncol(-1, nil, true)
					return true
				end,
			},
			named                = {
				centerwork = function()
					awful.layout.set(lain.layout.centerwork)
				end,
				floating   = function()
					awful.layout.set(awful.layout.suit.floating)
				end,
				swen       = function()
					awful.layout.set(_layouts.swen)
				end,
				tiler      = function()
					awful.layout.set(_layouts.tiler)
				end,
			},
		},
		useless = {
			zero            = function()
				local scr            = awful.screen.focused()
				scr.selected_tag.gap = 0
			end,
			increase_little = function()
				lain.util.useless_gaps_resize(10)
			end,
			increase_much   = function()
				lain.util.useless_gaps_resize(50)
			end,
			decrease_little = function()
				lain.util.useless_gaps_resize(-10)
			end,
			decrease_much   = function()
				lain.util.useless_gaps_resize(-50)
			end,
			some            = function()
				local scr           = awful.screen.focused()
				--scr.selected_tag.gap = 0
				local target_gap_on = 100
				if scr.selected_tag.gap > 0 then
					scr.selected_tag.gap = 0
				else
					lain.util.useless_gaps_resize(target_gap_on - scr.selected_tag.gap)
				end
			end
		},
	},
	special    = {
		raise                        = special.raise,
		klack                        = klack.start,
		-- padding_toggle is intended to give me a way
		-- to make working on the TV more comfortable for my neck.
		-- More real estate is always better, but being able
		-- to constrain its used limits is proving to be nice.
		padding_toggle               = function()
			local scr = awful.screen.focused()
			if scr.original_padding == nil then
				scr.original_padding = scr.padding
				scr.padding          = {
					top    = scr.geometry.height / 5,
					bottom = 5,
					left   = scr.geometry.width / 4 / 2,
					right  = scr.geometry.width / 4 / 2,
				}
			else
				scr.padding          = scr.original_padding
				scr.original_padding = nil
			end
		end,
		move_mouse_to_focused_client = special.move_mouse_to_focused_client,
	}
}

global_fns.client.focus.back_greedy = function()
	-- Change the client focus immediately "back",
	-- and abort if there is no focused client.
	global_fns.client.focus.back_local()
	local new_c = client.focus
	if not new_c then return end

	-- If this client's tag only has one client, abort.
	-- (This is expected to be a corner case).
	local t = new_c.first_tag
	if not t then return end
	if #t:clients() == 1 then return end

	local c_has_minority_width = new_c.width < (
			t.screen.workarea.width
					- (t.screen.padding.left or 0) - (t.screen.padding.right or 0)
	) / 2

	if c_has_minority_width then
		t:set_master_width_factor(1 - t.master_width_factor)
	end
end

-- fns_c are client functions.lt
-- They are/should be registered with awful.keyboard.append_client_keybindings
-- and will be passed the current focused client as the first arg.
local client_fns                    = {
	move       = {
		new_tag = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			local t = awful.tag.add(cc.class, { screen = cc.screen })
			cc:tags({ t })
			t:view_only()
		end
	},
	resize     = {
		wider    = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.fullscreen = false
			cc.maximized  = false
			cc.floating   = true
			cc.width      = cc.width + cc.screen.workarea.width / 10
			awful.placement.no_offscreen(cc, { honor_workarea = true, margins = 0 })
		end,
		skinnier = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.fullscreen = false
			cc.maximized  = false
			cc.floating   = true
			cc.width      = cc.width - cc.screen.workarea.width / 10
			awful.placement.no_offscreen(cc, { honor_workarea = true, margins = 0 })
		end,
		taller   = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.fullscreen = false
			cc.maximized  = false
			cc.floating   = true
			cc.height     = cc.height + cc.screen.workarea.height / 10
			awful.placement.no_offscreen(cc, { honor_workarea = true, margins = 0 })
		end,
		shorter  = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.fullscreen = false
			cc.maximized  = false
			cc.floating   = true
			cc.height     = cc.height - cc.screen.workarea.height / 10
			awful.placement.no_offscreen(cc, { honor_workarea = true, margins = 0 })
		end,
	},
	properties = {
		fullscreen        = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.fullscreen = not cc.fullscreen
			cc:raise()

			if cc.screen and cc.screen.mywibox then
				special.toggle_wibar_slim()
			end
		end,
		maximize          = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.maximized = not cc.maximized
			cc:raise()
		end,
		minimize          = function(c)
			(c or client.focus).minimized = true
		end,
		floating          = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.floating = not cc.floating
			cc:raise()
		end,
		ontop             = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.ontop = not cc.ontop
			cc:raise()
		end,
		sticky            = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.sticky = not cc.sticky
			cc:raise()
		end,
		titlebars_enabled = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			awful.titlebar.toggle(cc)
		end,
	},
	to_master  = function(c)
		local cc = c or client.focus
		if not cc then
			return
		end
		cc:swap(awful.client.getmaster())
	end,
	kill       = function(c)
		local cc = c or client.focus
		if not cc then
			return
		end
		cc:kill()
	end,
	screen     = {
		move_next = function(c)
			c = c or client.focus
			c:move_to_screen()
			client.focus = c
		end,
		move_prev = function(c)
			c = c or client.focus
			c:move_to_screen()
			client.focus = c
		end,
	},
	special    = {
		reader_view_tall = special.reader_view_tall,
		reader_view      = special.reader_view,
	}
}

-- init_freedesktop_menu assigns the freedesktop menu to an awful utility object if it has not yet been assigned.
-- It is safe to call multiple times.
-- It gets called asyncronously (by awful.spawn.easy_async, see below) so that it does not block the rest of the config
-- at startup and the user (assuming they are sluggish and lazy humans like me) can start using the menu sooner
-- once they actually want it later on, without waiting 6.5 seconds for it to build.
local function init_freedesktop_menu()
	if awful.util.mymainmenu == nil then
		-- FIXME The notification does not work. Don't know why.
		print("[build freedesktop] Building freedesktop menu...")
		print("[build freedesktop] Showing notification about how long its going to take...")
		n       = naughty.notification {
			title    = "Building main menu...",
			message  = "This might take a while...",
			bg       = "#F9C20C",
			fg       = "#000000",
			position = "top_middle",
			ontop    = true,
			timeout  = 12,
		}

		local w = mouse.current_wibox or mouse.current_client
		if w then
			old_cursor, old_wibox = w.cursor, w
			w.cursor              = "watch"
		else
			root.cursor("watch")
		end

		local start_time      = os.clock()
		finished              = function()
			if old_wibox then
				old_wibox.cursor = old_cursor
				old_wibox        = nil
			else
				root.cursor("arrow")
			end

			local msg = string.format("Loaded freedesktop main menu in %.2f seconds", os.clock() - start_time)
			print(msg)
			-- => 6.27 seconds
			-- => 6.68 seconds
			-- => 6.37 seconds
			if n then
				n:destroy()
			end
		end
		awful.util.mymainmenu = freedesktop.menu.build {
			done      = finished,
			icon_size = beautiful.menu_height or 18,
			before    = {
				{ "Screenshot", {
					{ "Selection", global_fns.screenshot.selection, },
					{ "Screen", global_fns.screenshot.screen, },
					{ "Window (All)", global_fns.screenshot.window, },
					{ "Focused client", global_fns.screenshot.client, },
				}, nil },
				{ " " },
			},
			after     = {
				{ " " },
				{ "Awesome", {
					{ "hotkeys",
					  function()
						  return false, hotkeys_popup.show_help
					  end
					},
					{ "restart", awesome.restart },
					{ "quit", awesome.quit },
				}, beautiful.awesome_icon },

				{ "Power/User Mgmt", {
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
				}, nil },
			}
		}
	end
end

-- show_main_menu lazily loads a freedesktop main menu (including all/most/some(?) system applications)
-- Reports on the internet say it can be slow to use, so we only build it on demand
-- instead of in rc.lua (where it would be built on startup).
-- https://www.reddit.com/r/awesomewm/comments/ludsl7/comment/iukgex6/?context=3
global_fns.awesome.show_main_menu = function()
	init_freedesktop_menu()
	awful.util.mymainmenu:show()
end


-- }}}

return {
	global = global_fns,
	client = client_fns,
}