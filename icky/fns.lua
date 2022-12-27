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
local awesome, client              = awesome, client
local os, string, tostring         = os, string, tostring

-- awesome libs
local awful                        = require("awful")
local hotkeys_popup                = require("awful.hotkeys_popup").widget
local beautiful                    = require("beautiful")
local naughty                      = require("naughty")
local lain                         = require("lain")

-- contrib
local handy                        = require("handy")
local hints                        = require("hints")
local revelation                   = require("revelation")
local special                      = require("special")
local ia_layout_swen               = require("layout-swen")
local layout_titlebars_conditional = require("layout-titlebars-conditional")

-- inits for contrib libs
hints.init()
revelation.init()

---------------------------------------------------------------------------
-- HELPERS

local raise_focused_client = function()
	if client.focus then
		client.focus:raise()
	end
end

local _layouts             = {
	tiler = layout_titlebars_conditional { layout = awful.layout.suit.tile },
	swen  = layout_titlebars_conditional { layout = ia_layout_swen },
}

---------------------------------------------------------------------------

local global_fns           = {
	awesome    = {
		restart        = awesome.restart,
		hotkeys_help   = hotkeys_popup.show_help,
		wibar          = special.toggle_wibar_slim,
		show_main_menu = function()
			awful.util.mymainmenu:show()
		end,
		widgets        = {
			world_times = special.toggle_wibar_worldtimes,
			calendar    = function()
				awful.screen.focused().my_calendar_widget.toggle()
			end,
			weather     = function()
				special.weather.show()
			end,
		},
	},
	apps       = {
		run_or_raise   = function(app_by_name)
			return function()
				local matcher = function(c)
					return awful.rules.match(c, { class = app_by_name })
				end
				awful.client.run_or_raise(app_by_name, matcher)
			end
		end,
		handy          = {
			top  = function()
				handy("ffox --class handy-top", awful.placement.top, 0.5, 0.5)
			end,
			left = function()
				handy("ffox --class handy-left", awful.placement.left, 0.25, 0.9)
			end,
		},
		rofi           = function(modi)
			-- Location values:
			-- 1   2   3
			-- 8   0   4
			-- 7   6   5
			local tv_prompt       = "rofi -modi " .. modi .. " -show " .. modi .. " -sidebar-mode -location 6 -theme Indego -width 20 -no-plugins -no-config -no-lazy-grab -async-pre-read 1 -show-icons"
			local laptop_prompt   = "rofi -modi " .. modi .. " -show " .. modi .. " -sidebar-mode -location 6 -theme Indego -width 40 -no-plugins -no-config -no-lazy-grab -async-pre-read 1 -show-icons"
			local commandPrompter = awful.screen.focused().is_tv and tv_prompt or laptop_prompt

			if modi == "run" then
				return function()
					awful.spawn.easy_async(commandPrompter, function(stdout, stderr, reason, exit_code)
						if exit_code == 0 then
							local matcher = function(c)
								return awful.rules.match(c, { class = stdout })
							end
							awful.client.run_or_raise(stdout, matcher)
						end
					end)
				end
			elseif modi == "window" then
				return function()
					awful.spawn.easy_async(commandPrompter, function()
						if client.focus then
							awful.screen.focus(client.focus.screen)
						end
					end)
				end
			end
		end,
		quake          = function()
			special.quake:toggle()
		end,
		popup_launcher = special.popup_launcher.launch,
		revelation     = revelation,
	},
	client     = {
		special_inspect = special.inspect_client,
		focus           = {
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
		swap            = {
			index = {
				next = function()
					awful.client.swap.byidx(1)
				end,
				prev = function()
					awful.client.swap.byidx(-1)
				end
			},
		},
		restore         = function()
			local c = awful.client.restore()
			if c then
				client.focus = c
				c:raise()
			end
		end,
		hints           = function()
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
			naughty.notify { position = "bottom_middle", text = "Mic toggled" }
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
		logout    = function()
			awful.util.spawn_with_shell("sudo service lightdm restart")
		end,
		suspend   = function()
			awful.util.spawn_with_shell("sudo systemctl suspend")
		end,
		reboot    = function()
			os.execute("reboot")
		end,
		power_off = function()
			os.execute("shutdown -P -h now")
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
		end
	},
	screenshot = {
		selection = function()
			special.saved_screenshot {
				interactive     = true,
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot",
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		window    = function()
			special.saved_screenshot {
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot",
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		screen    = function()
			special.saved_screenshot {
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot",
				date_format     = "%Y-%m-%d-%H%M%S",
				auto_save_delay = 0.1,
				screen          = awful.screen.focused(),
				--exec            = screenshot_notifier { label = "selection" },
			}
		end,
		client    = function()
			special.saved_screenshot {
				directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
				prefix          = "screenshot_" .. client.focus.class:gsub("%s+", "_"),
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
					prefix          = "screenshot",
					date_format     = "%Y-%m-%d-%H%M%S",
					auto_save_delay = 5,
					--exec            = screenshot_notifier { label = "selection" },
				}
			end,
			screen = function()
				special.saved_screenshot {
					directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
					prefix          = "screenshot",
					date_format     = "%Y-%m-%d-%H%M%S",
					auto_save_delay = 5,
					screen          = awful.screen.focused(),
					--exec            = screenshot_notifier { label = "selection" },
				}
			end,
			client = function()
				special.saved_screenshot {
					directory       = os.getenv("HOME") .. "/Pictures/screenshots/",
					prefix          = "screenshot_" .. client.focus.class:gsub("%s+", "_"),
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
		},
	},
}

-- fns_c are client functions.
-- They are/should be registered with awful.keyboard.append_client_keybindings
-- and will be passed the current focused client as the first arg.
local client_fns           = {
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
			local cc = c or client.focus
			if not cc then
				return
			end
			cc.focus = false
			cc:lower()
			cc.minimized = true
			awful.client.focus.history.previous()
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
			local cc = c or client.focus
			if not cc then
				return
			end
			cc:move_to_screen(cc.screen.index - 1)
		end,
		move_prev = function(c)
			local cc = c or client.focus
			if not cc then
				return
			end
			cc:move_to_screen(cc.screen.index + 1)
		end,
	},
	special    = {
		reader_view_tall = special.reader_view_tall,
		fancy_float      = special.fancy_float,
	}
}
-- }}}

return {
	global = global_fns,
	client = client_fns,
}