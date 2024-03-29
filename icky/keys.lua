---------------------------------------------------------------------------
-- Keys
--
-- Mapping keybindings and keypaths to functions.
-- All functions referenced here should be defined in fns.lua.
-- These are the definitions of my hotkeys and modal key paths.
--
-- The substance of this file is the data of the lib.global_bindings and lib.client_bindings tables.
-- Ideally (or metaphysically?), these would be stored in plain text (etc.) files,
-- but storing them here in Lua is a close approximation of that.
--
-- @author whilei
-- @author Isaac <isaac.ardis@gmail.com>
-- @copyright 2022 Isaac
-- @coreclassmod icky.keys
---------------------------------------------------------------------------

local ipairs, table, tostring = ipairs, table, tostring
local client                  = client

local awful                   = require("awful")
local hood                    = require("hood")
local global_fns              = require("icky.fns").global
local client_fns              = require("icky.fns").client
local modality                = require("modality")
local modality_util           = require("modality.util")
local naughty                 = require("naughty")

--[[

awful.key
	- mods
	- key
	- fn
	- h.description
	- h.group

--]]

local _keys                   = {
	MOD   = "Mod4",
	SHIFT = "Shift",
	ALT   = "Mod1",
	CTRL  = "Control",
}

-- lib is the returned table.
local lib                     = {
	global_awful_keys = {},
	client_awful_keys = {},
}

lib.get_client_awful_keys     = function()
	return lib.client_awful_keys
end

lib.get_global_awful_keys     = function()
	return lib.global_awful_keys
end

-- m defines a common set of keybindings trunk paths.
-- You should prefer to not use 'stays' (~) on menus, rather isolate it to individual keys.
-- This gives you two things:
--  1. When you expect to have left the mode and (accidentally) tap an unassigned key, it'll exit as expected.
--  2. When you tap an assigned key and expect the mode to stay, it'll stay.
-- Only use 'stays' on menus that you REALLY want to stay on until you press an escaping key.
local m                       = {
	AWESOME           = "a:awesome,", -- trailing , allows for easy concatenation
	AWESOME_WIDGETS   = "a:awesome,w:widgets,", -- stays
	AWESOME_APPS      = "a:awesome,a:apps,",
	APPLICATIONS      = ".:applications,",

	-- confusingly, this is not always (or event usually) what are considered 'client' commands
	-- That is only because these functions do not necessarily have to have the client argument,
	-- and as such, they should not assume that there are any clients or that there is a focused client.
	CLIENT            = "c:client,",

	-- These, however, ARE client commands, and they will get the client parameter.
	CLIENT_MOVE       = "c:client,m:move,",
	CLIENT_RESIZE     = "c:client,r~:resize,", -- stays
	CLIENT_PLACEMENT  = "c:client,p~:placement,", -- stays

	SPECIAL           = "e:special,",
	HANDY             = "h:handy,",
	FOCUS             = "f:focus,",
	TAG_LAYOUT        = "l:layout,",
	TAG_LAYOUT_ADJUST = "l:layout,a:adjust,", -- stays
	MEDIA             = "m:media,",
	MEDIA_VOLUME      = "m:media,v~:volume,", -- stays
	SWAP              = "p~:swap,",
	POWER_USER        = "P:power-user,",
	SCREEN            = "s:screen,",
	SCREEN_SHOT       = "s:screen,t:screenshot,",
	TAG               = "t:tag,",
	TAG_USELESS       = "t:tag,u~:useless,", -- stays
	VIEW              = "v:view,"
}

lib.global_bindings           = {
	-- {{{ MODALITY
	{
		h        = { group = "awesome", description = "enter modality mode", name = "modality" },
		hotkeys  = { { _keys.MOD, " " }, { _keys.MOD, "Escape" } },
		on_press = function()
			modality.enter(modality.path_tree)
		end,
	},
	-- }}}


	-- {{{ AWESOME
	{
		h          = { group = "awesome", description = "restart awesome", name = "restart" },
		modalities = { m.AWESOME .. "r" },
		on_press   = global_fns.awesome.restart,
	},
	{
		h        = { group = "awesome", description = "show hotkeys help cheat sheet", name = "hotkeys help" },
		on_press = global_fns.awesome.hotkeys_help,
	},
	{
		h          = { group = "awesome", description = "show main menu", name = "main menu" },
		modalities = { m.AWESOME .. "m:show main menu" },
		hotkeys    = { { _keys.MOD, "w" } },
		on_press   = global_fns.awesome.show_main_menu,
	},
	{
		h          = { group = "awesome", description = "eval lua", name = "eval lua" },
		modalities = { m.AWESOME .. "e" },
		on_press   = global_fns.awesome.eval_lua,
	},

	-- AWESOME:BARS
	{
		h          = { group = "awesome", description = "wibar style switcher", name = "toggle wibar" },
		modalities = { "b", m.AWESOME .. "b" },
		hotkeys    = { { _keys.MOD, "d" } },
		on_press   = global_fns.awesome.wibar,

	},
	{
		h          = { group = "awesome", description = "toggle dash", name = "dash" },
		modalities = { m.AWESOME .. "d" },
		on_press   = global_fns.awesome.dash,
	},
	-- AWESOME:WIDGETS
	{
		h          = { group = "awesome/widgets", description = "toggle meridian widget", name = "meridian" },
		modalities = { m.AWESOME_WIDGETS .. "m~", m.AWESOME_WIDGETS .. "g~" },
		hotkeys    = { { _keys.MOD, "g" } },
		on_press   = global_fns.awesome.widgets.world_times,
	},
	-- AWESOME:APPS
	{
		h          = {
			group       = "awesome/handy",
			description = "firefox (top)",
			name        = "firefox (top)",
		},
		modalities = { m.HANDY .. "k:top" },
		hotkeys    = {
			{
				mods      = { _keys.MOD }, code = "v",
				key_group = nil, -- eg. "numrow" (=1,2,3,4,5,6,7,8,9,0, callbacks get index arg)
			},
		},
		on_press   = global_fns.apps.handy.top,
		on_release = nil,
	},
	{
		h          = { group = "awesome/handy", description = "firefox (left)", name = "firefox (left)", },
		modalities = { m.HANDY .. "h" },
		hotkeys    = { { mods = { _keys.MOD }, code = "a", }, },
		on_press   = global_fns.apps.handy.left,
	},
	{
		h          = { group = "awesome/snazzy", description = "hints", name = "hints" },
		hotkeys    = { { mods = { _keys.MOD }, code = "i", }, },
		modalities = { "i", m.AWESOME_APPS .. "i" },
		on_press   = global_fns.client.hints,
	},
	{
		h          = { group = "awesome/snazzy", description = "rofi window", name = "rofi (window)", },
		modalities = { "o", m.AWESOME_APPS .. "w", m.FOCUS .. "f" },
		hotkeys    = {
			{ mods = { _keys.MOD, _keys.SHIFT }, code = "W", },
		},
		on_press   = global_fns.apps.rofi("window"),
	},
	{
		h          = { group = "awesome/snazzy", description = "rofi runner", name = "rofi (run)", },
		modalities = { "r", m.AWESOME_APPS .. "r" },
		hotkeys    = {
			{ mods = { _keys.MOD }, code = "Return", },
		},
		on_press   = global_fns.apps.rofi("drun"),
	},
	{
		h          = { group = "awesome/snazzy", description = "revelation", name = "revelation" },
		modalities = { "`", m.AWESOME_APPS .. "e" },
		hotkeys    = { { mods = { _keys.MOD }, code = "e", }, },
		on_press   = global_fns.apps.revelation,
	},
	{
		h          = { group = "awesome/snazzy", description = "toggle quake popup terminal", name = "quake", },
		modalities = { "q", m.AWESOME_APPS .. "q" },
		hotkeys    = { { mods = { _keys.MOD }, code = "z", }, },
		on_press   = global_fns.apps.quake,
	},
	{
		h          = { group = "awesome/snazzy", description = "awesome launcher", name = "launcher", },
		modalities = { "x" },
		hotkeys    = { { mods = { _keys.MOD }, code = "r", }, },
		on_press   = global_fns.apps.popup_launcher,
	},
	-- }}} AWESOME


	-- {{{ APPLICATIONS
	{
		h          = { group = "applications", description = "raise or run emacs", name = "emacs", },
		modalities = { m.APPLICATIONS .. "e" },
		on_press   = global_fns.apps.single_instance("emacs"),
	},
	{
		h          = { group = "applications", description = "raise or run firefox", name = "firefox (ffox)", },
		modalities = { m.APPLICATIONS .. "f" },
		on_press   = global_fns.apps.single_instance("ffox"),
	},
	{
		h          = { group = "applications", description = "raise or run google chrome", name = "google chrome", },
		modalities = { m.APPLICATIONS .. "g" },
		on_press   = global_fns.apps.single_instance("google-chrome"),
	},
	{
		h          = { group = "applications", description = "raise or run konsole", name = "konsole", },
		modalities = { m.APPLICATIONS .. "k" },
		on_press   = global_fns.apps.single_instance("konsole"),
	},
	{
		h          = { group = "applications", description = "raise or run kate", name = "kate", },
		modalities = { m.APPLICATIONS .. "a" },
		on_press   = global_fns.apps.single_instance("kate"),
	},
	{
		h          = { group = "applications", description = "raise or run system settings", name = "system settings", },
		modalities = { m.APPLICATIONS .. "s" },
		on_press   = global_fns.apps.single_instance("systemsettings5"),
	},
	{
		h          = { group = "applications", description = "raise or run jetbrains toolbox", name = "jetbrains toolbox", },
		modalities = { m.APPLICATIONS .. "j" },
		on_press   = global_fns.apps.single_instance("jetbrains-toolbox"),
	},
	{
		h          = { group = "applications", description = "raise or run nvidia settings", name = "nvidia-settings", },
		modalities = { m.APPLICATIONS .. "S" },
		on_press   = global_fns.apps.single_instance("nvidia-settings"),
	},
	{
		h          = { group = "applications", description = "raise or run obsidian", name = "obsidian", },
		modalities = { m.APPLICATIONS .. "o" },
		on_press   = global_fns.apps.single_instance("obsidian"),
	},
	-- }}} APPLICATIONS


	-- {{{ FOCUS
	{
		h          = { group = "client/focus", description = "restore (=unminimize)", name = "restore" },
		modalities = { "+" },
		hotkeys    = { { mods = { _keys.MOD, _keys.CTRL }, code = "n", }, },
		on_press   = global_fns.client.restore,
	},
	-- FOCUS:SPECIAL
	{
		h          = { group = "client/focus", description = "move mouse to center of focused client", name = "mouse -> focused" },
		modalities = { m.FOCUS .. "m" },
		on_press   = global_fns.special.move_mouse_to_focused_client,
	},
	{
		h          = { group = "client/focus", description = "back (anywhere)", name = "back (global)" },
		hotkeys    = { { mods = { _keys.MOD }, code = "Tab", }, },
		modalities = { "Tab" },
		on_press   = global_fns.client.focus.back_global,
	},
	{
		h          = { group = "client/focus", description = "back (local)", name = "back (local)" },
		modalities = { "n", m.FOCUS .. "n" },
		on_press   = global_fns.client.focus.back_local,
	},
	{
		h          = { group = "client/focus", description = "inverts tag mwf to give focus more width", name = "back (local) - greedy" },
		modalities = { "N", m.FOCUS .. "N" },
		on_press   = global_fns.client.focus.back_greedy,
	},
	{
		h          = { group = "client/focus", description = "back (to prev tag)", name = "back (tag)" },
		modalities = { m.TAG .. "b" },
		on_press   = global_fns.tag.restore,
	},
	-- FOCUS:BY_INDEX
	{
		h          = { group = "client/focus", description = "next by index", name = "next indexed" },
		modalities = { m.FOCUS .. "n" },
		hotkeys    = { { mods = { _keys.ALT }, code = "j", }, },
		on_press   = global_fns.client.focus.index.next,
	},
	{
		h          = { group = "client/focus", description = "prev by index", name = "prev indexed" },
		modalities = { m.FOCUS .. "p" },
		hotkeys    = { { mods = { _keys.ALT }, code = "k", }, },
		on_press   = global_fns.client.focus.index.prev,
	},
	-- FOCUS:BY_DIRECTION
	{
		h          = { group = "client/focus", description = "focus by direction: left", name = "focus left" },
		modalities = { m.FOCUS .. "h" },
		hotkeys    = { { mods = { _keys.MOD }, code = "h", }, },
		on_press   = global_fns.client.focus.direction.left,
	},
	{
		h          = { group = "client/focus", description = "focus by direction: right", name = "focus right" },
		modalities = { m.FOCUS .. "l" },
		hotkeys    = { { mods = { _keys.MOD }, code = "l", }, },
		on_press   = global_fns.client.focus.direction.right,
	},
	{
		h          = { group = "client/focus", description = "focus by direction: up", name = "focus up" },
		modalities = { m.FOCUS .. "k" },
		hotkeys    = { { mods = { _keys.MOD }, code = "k", }, },
		on_press   = global_fns.client.focus.direction.up,
	},
	{
		h          = { group = "client/focus", description = "focus by direction: down", name = "focus down" },
		modalities = { m.FOCUS .. "j" },
		hotkeys    = { { mods = { _keys.MOD }, code = "j", }, },
		on_press   = global_fns.client.focus.direction.down,
	},
	-- CLIENT:SWAP
	{
		h          = { group = "client/swap", description = "swap next by index", name = "swap next" },
		modalities = { m.SWAP .. "n" },
		hotkeys    = { { mods = { _keys.MOD, _keys.SHIFT }, code = "j", }, },
		on_press   = global_fns.client.swap.index.next,
	},
	{
		h          = { group = "client/swap", description = "swap prev by index", name = "swap prev" },
		modalities = { m.SWAP .. "p" },
		hotkeys    = { { mods = { _keys.MOD, _keys.SHIFT }, code = "k", }, },
		on_press   = global_fns.client.swap.index.prev,
	},
	-- }}} CLIENT


	-- {{{ MEDIA
	{
		h          = { group = "media", description = "toggle mic", name = "toggle mic" },
		hotkeys    = { { mods = { _keys.ALT, _keys.CTRL }, code = "0" } },
		modalities = { m.MEDIA .. "m" },
		on_press   = global_fns.media.mic_toggle,
	},
	{
		h          = { group = "media", description = "increase volume", name = "volume up" },
		hotkeys    = { { mods = { _keys.ALT }, code = "Up" } },
		modalities = { m.MEDIA_VOLUME .. "k" },
		on_press   = global_fns.media.volume.up,
	},
	{
		h          = { group = "media", description = "decrease volume", name = "volume down" },
		hotkeys    = { { mods = { _keys.ALT }, code = "Down" } },
		modalities = { m.MEDIA_VOLUME .. "j" },
		on_press   = global_fns.media.volume.down,
	},
	{
		h          = { group = "media", description = "mute volume", name = "volume mute" },
		hotkeys    = { { mods = { _keys.ALT }, code = "m" } },
		modalities = { m.MEDIA_VOLUME .. "v" },
		on_press   = global_fns.media.volume.mute,
	},
	-- }}}


	-- {{{ TAGS
	{
		h          = { group = "tag", description = "view previous (by index)", name = "previous" },
		modalities = { m.TAG .. "p" }, -- stays (it is common to want to move around more than one tag)
		hotkeys    = { { mods = { _keys.MOD }, code = "Left" } },
		on_press   = global_fns.tag.prev,
	},
	{
		h          = { group = "tag", description = "view next (by index)", name = "next" },
		modalities = { m.TAG .. "n" }, --stays, ditto
		hotkeys    = { { mods = { _keys.MOD }, code = "Right" } },
		on_press   = global_fns.tag.next,
	},
	{
		h          = { group = "tag", description = "move tag left", name = "move left" },
		modalities = { m.TAG .. "H~" }, -- stays
		hotkeys    = { { mods = { _keys.MOD, _keys.SHIFT }, code = "Left" } },
		on_press   = global_fns.tag.move.left,
	},
	{
		h          = { group = "tag", description = "move tag right", name = "move right" },
		modalities = { m.TAG .. "L~" }, -- stays
		hotkeys    = { { mods = { _keys.MOD, _keys.SHIFT }, code = "Right" } },
		on_press   = global_fns.tag.move.right,
	},
	{
		h          = { group = "tag", description = "add a tag", name = "add" },
		modalities = { m.TAG .. "A" }, -- stays
		on_press   = global_fns.tag.add,
	},
	{
		h          = { group = "tag", description = "delete a tag", name = "delete" },
		modalities = { m.TAG .. "D" }, -- stays
		on_press   = global_fns.tag.delete,
	},
	{
		h          = { group = "tag", description = "rename a tag", name = "rename" },
		modalities = { m.TAG .. "r" }, -- stays
		on_press   = global_fns.tag.rename,
	},
	-- TAGS:LAYOUT:ADJUST
	{
		h          = { group = "tag/layout/adjust", description = "increase master width factor", name = "increment mwf" },
		hotkeys    = { { mods = { _keys.ALT, _keys.SHIFT }, code = "l" } },
		modalities = { m.TAG_LAYOUT_ADJUST .. "l~" },
		on_press   = global_fns.tag.layout.master_width_factor.increase,
	},
	{
		h          = { group = "tag/layout/adjust", description = "decrease master width factor", name = "decrement mwf" },
		hotkeys    = { { mods = { _keys.ALT, _keys.SHIFT }, code = "h" } },
		modalities = { m.TAG_LAYOUT_ADJUST .. "h~" },
		on_press   = global_fns.tag.layout.master_width_factor.decrease,
	},
	{
		h          = { group = "tag/layout/adjust", description = "invert master width factor", name = "invert mwf" },
		modalities = { m.TAG_LAYOUT_ADJUST .. "i" },
		on_press   = global_fns.tag.layout.master_width_factor.invert,
	},
	-- TAGS:LAYOUT:BY NAME
	{
		h          = { group = "tag/layout", description = "use centerwork layout", name = "centerwork" },
		modalities = { m.TAG_LAYOUT .. "c" },
		on_press   = global_fns.tag.layout.named.centerwork,
	},
	{
		h          = { group = "tag/layout", description = "use tiling layout", name = "tiling" },
		modalities = { m.TAG_LAYOUT .. "t" },
		on_press   = global_fns.tag.layout.named.tiler,
	},
	{
		h          = { group = "tag/layout", description = "use swen layout", name = "swen" },
		modalities = { m.TAG_LAYOUT .. "s" },
		on_press   = global_fns.tag.layout.named.swen,
	},
	{
		h          = { group = "tag/layout", description = "use floating layout", name = "floating" },
		modalities = { m.TAG_LAYOUT .. "f" },
		on_press   = global_fns.tag.layout.named.floating,
	},
	-- TAGS:USELESS
	{
		h          = { group = "tag/useless", description = "set useless gaps to zero", name = "no useless gaps" },
		modalities = { m.TAG_USELESS .. "n" },
		on_press   = global_fns.tag.useless.zero,
	},
	{
		h          = { group = "tag/useless", description = "resize useless gaps +50", name = "increase useless gaps a lot" },
		modalities = { m.TAG_USELESS .. "K" },
		on_press   = global_fns.tag.useless.increase_much,
	},
	{
		h          = { group = "tag/useless", description = "resize useless gaps +10", name = "increase useless gaps a little" },
		modalities = { m.TAG_USELESS .. "k" },
		on_press   = global_fns.tag.useless.increase_little,
	},
	{
		h          = { group = "tag/useless", description = "resize useless gaps -50", name = "decrease useless gaps a lot" },
		modalities = { m.TAG_USELESS .. "J" },
		on_press   = global_fns.tag.useless.decrease_much,
	},
	{
		h          = { group = "tag/useless", description = "resize useless gaps -10", name = "decrease useless gaps a little" },
		modalities = { m.TAG_USELESS .. "j" },
		on_press   = global_fns.tag.useless.decrease_little,
	},
	{
		h          = { group = "tag/useless", description = "resize useless gaps to some", name = "toggle some gap" },
		modalities = { m.TAG_USELESS .. "s" },
		on_press   = global_fns.tag.useless.some,
	},
	-- }}} TAGS


	-- {{{ SCREEN
	{
		h          = { group = "screen", description = "focus next screen", name = "focus next screen" },
		modalities = { "$", m.SCREEN .. "n", m.SCREEN .. "s" },
		hotkeys    = { { mods = { _keys.MOD }, code = "u" } },
		on_press   = global_fns.screen.next,
	},
	{
		h          = { group = "screen", description = "focus prev screen", name = "focus prev screen" },
		modalities = { m.SCREEN .. "p" },
		on_press   = global_fns.screen.prev,
	},
	{
		h          = { group = "screen", description = "invert colors with xrandr", name = "invert colors" },
		hotkeys    = { { mods = { _keys.MOD }, code = "X" } },
		modalities = { m.SCREEN .. "x" },
		on_press   = global_fns.screen.invert_colors,
	},
	-- SCREEN:SCREENSHOT
	{
		h          = { group = "screen/shot", description = "take a screenshot of a screen", name = "screenshot screen" },
		hotkeys    = { { mods = { _keys.MOD }, code = "s" }, },
		modalities = { m.SCREEN_SHOT .. "s" },
		on_press   = global_fns.screenshot.screen,
	},
	{
		h          = { group = "screen/shot", description = "take a screenshot of a selection (interactive)", name = "screenshot selection (interactive)" },
		hotkeys    = { { mods = { _keys.MOD, _keys.SHIFT }, code = "s" }, },
		modalities = { m.SCREEN_SHOT .. "i" },
		on_press   = global_fns.screenshot.selection,
	},
	{
		h          = { group = "screen/shot", description = "take a screenshot of the window (all screens)", name = "screenshot window" },
		modalities = { m.SCREEN_SHOT .. "w" },
		on_press   = global_fns.screenshot.window,
	},
	{
		h          = { group = "screen/shot", description = "take a screenshot of a client", name = "screenshot client" },
		modalities = { m.SCREEN_SHOT .. "c" },
		on_press   = global_fns.screenshot.client,
	},
	-- SCREEN:SCREENSHOT:DELAYED
	{
		h          = { group = "screen/shot", description = "take a delayed screenshot of a screen", name = "screenshot screen" },
		modalities = { m.SCREEN_SHOT .. "d:delayed screenshot,s" },
		on_press   = global_fns.screenshot.screen,
	},
	{
		h          = { group = "screen/shot", description = "take a delayed screenshot of the window (all screens)", name = "screenshot window" },
		modalities = { m.SCREEN_SHOT .. "d:delayed screenshot,w" },
		on_press   = global_fns.screenshot.window,
	},
	{
		h          = { group = "screen/shot", description = "take a delayed screenshot of a client", name = "screenshot client" },
		modalities = { m.SCREEN_SHOT .. "d:delayed screenshot,c" },
		on_press   = global_fns.screenshot.client,
	},
	-- }}} SCREEN


	-- {{{ POWER_USER
	{
		h          = { group = "power_user", description = "screen lock", name = "lock screen" },
		modalities = { "L", m.POWER_USER .. "L" },
		on_press   = global_fns.power_user.lock,
	},
	{
		h          = { group = "power_user", description = "restart lightdm to logout", name = "logout" },
		modalities = { m.POWER_USER .. "O" },
		on_press   = global_fns.power_user.logout,
	},
	{
		h          = { group = "power_user", description = "suspend session (sleep)", name = "suspend/sleep" },
		modalities = { m.POWER_USER .. "S" },
		on_press   = global_fns.power_user.suspend,
	},
	{
		h          = { group = "power_user", description = "shutdown (=power off)", name = "shutdown" },
		modalities = { m.POWER_USER .. "X" },
		on_press   = global_fns.power_user.power_off,
	},
	{
		h          = { group = "power_user", description = "reboot", name = "reboot" },
		modalities = { m.POWER_USER .. "R" },
		on_press   = global_fns.power_user.reboot,
	},
	-- }}}

	-- {{{ VIEW
	{
		h          = { group = "special", description = "toggle screen's horseshoe-shaped padding", name = "padding-framed view" },
		modalities = { m.VIEW .. "p" },
		on_press   = global_fns.special.padding_toggle,
	},
	-- }}}

	--- {{{ SPECIAL
	{
		h          = { group = "special", description = "raise Discord window", name = "raise Discord" },
		modalities = { "D" },
		on_press   = global_fns.special.raise({ name = "Discord" }),
	},
	{
		h          = { group = "special", description = "turn Klack on", name = "klack" },
		modalities = { m.AWESOME_APPS .. "k" },
		on_press   = global_fns.special.klack,
	},
	{
		h          = { group = "special", description = "toggle hood debugger/inspector", name = "hood (debug)" },
		modalities = { "H" },
		on_press   = hood.toggle,
	},
}

lib.client_bindings           = {
	{
		h          = { group = "client/properties", description = "toggle maximized", name = "maximized" },
		modalities = { "z", m.CLIENT .. "z" },
		hotkeys    = { { mods = { _keys.MOD }, code = "m" } },
		on_press   = client_fns.properties.maximize,
	},
	{
		h          = { group = "client/properties", description = "toggle floating", name = "floating" },
		modalities = { m.CLIENT .. "f" },
		on_press   = client_fns.properties.floating,
	},
	{
		h          = { group = "client/properties", description = "toggle ontop", name = "ontop" },
		modalities = { m.CLIENT .. "o" },
		on_press   = client_fns.properties.ontop,
	},
	{
		h          = { group = "client/properties", description = "toggle sticky", name = "sticky" },
		modalities = { m.CLIENT .. "s" },
		on_press   = client_fns.properties.sticky,
	},
	{
		h          = { group = "client/properties", description = "toggle titlebars", name = "titlebars" },
		modalities = { m.CLIENT .. "s" },
		on_press   = client_fns.properties.titlebars_enabled,
	},
	{
		h          = { group = "client/properties", description = "fullscreen client", name = "fullscreen" },
		modalities = { m.CLIENT .. "F" },
		hotkeys    = { { mods = { _keys.MOD }, code = "f" } },
		on_press   = client_fns.properties.fullscreen,
	},
	{
		h          = { group = "client/properties", description = "minimize", name = "minimize" },
		modalities = { "-", m.CLIENT .. "n" },
		hotkeys    = { { mods = { _keys.MOD }, code = "n" } },
		on_press   = client_fns.properties.minimize,
	},
	-- CLIENT:MOVE
	{
		h          = { group = "client/move", description = "move to master", name = "to master" },
		modalities = { "*", m.CLIENT_MOVE .. "m" },
		on_press   = client_fns.to_master,
	},
	{
		h          = { group = "client/move", description = "move to next screen", name = "next screen" },
		modalities = { m.CLIENT_MOVE .. "s" },
		hotkeys    = { { mods = { _keys.MOD }, code = "o" } },
		on_press   = client_fns.screen.move_next,
	},
	{
		h          = { group = "client/move", description = "move to new tag", name = "new tag" },
		modalities = { m.CLIENT_MOVE .. "N" },
		on_press   = client_fns.move.new_tag,
	},
	-- CLIENT:RESIZE
	{
		h          = { group = "client/resize", description = "resize wider", name = "wider" },
		modalities = { m.CLIENT_RESIZE .. "l" },
		on_press   = client_fns.resize.wider,
	},
	{
		h          = { group = "client/resize", description = "resize skinnier", name = "skinnier" },
		modalities = { m.CLIENT_RESIZE .. "h" },
		on_press   = client_fns.resize.skinnier,
	},
	{
		h          = { group = "client/resize", description = "resize taller", name = "taller" },
		modalities = { m.CLIENT_RESIZE .. "k" },
		on_press   = client_fns.resize.taller,
	},
	{
		h          = { group = "client/resize", description = "resize shorter", name = "shorter" },
		modalities = { m.CLIENT_RESIZE .. "j" },
		on_press   = client_fns.resize.shorter,
	},
	-- CLIENT:XXX
	{
		h          = { group = "client", description = "kill client", name = "kill" },
		modalities = { "Delete", m.CLIENT .. "q" },
		hotkeys    = { { mods = { _keys.MOD, _keys.SHIFT }, code = "c" } },
		on_press   = client_fns.kill,
	},

	-- VIEW
	{
		h          = { group = "special.client", description = "reader view (tall)", name = "client reader view (tall)" },
		hotkeys    = { { mods = { _keys.MOD, _keys.CTRL, _keys.SHIFT, }, code = "space" } },
		modalities = { m.VIEW .. "R" },
		on_press   = client_fns.special.reader_view_tall,
	},
	{
		h          = { group = "special.client", description = "toggle reader view", name = "client reader view" },
		modalities = { m.VIEW .. "r" },
		on_press   = client_fns.special.reader_view,
	},

	-- SPECIAL
}

-- TODO Have modality be able to handle keygroups (see awful.keygroups, awful.keygroup, awful.key).
-- BTW
-- FIXME
local function install_global_tag_fns_by_index()

	-- Bind all key numbers to tags.
	-- Be careful: we use keycodes to make it works on any keyboard layout.
	-- This should map on the top row of your keyboard, usually 1 to 9.
	for i = 1, 5 do
		-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
		local descr_view, descr_toggle, descr_move, descr_toggle_focus
		if i == 1 or i == 5 then
			descr_view         = { description = "view tag #", group = "tag" }
			descr_toggle       = { description = "toggle tag #", group = "tag" }
			descr_move         = { description = "move focused client to tag #", group = "tag" }
			descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
		end

		local fn_view_tag = function()
			local screen = awful.screen.focused()
			local tag    = screen.tags[i]
			if tag then
				tag:view_only()

				-- Focus the last-focused client in the tag.
				local did_focus = false
				for _, cl in ipairs(awful.client.focus.history.list) do
					if cl.primary_tag == tag then
						cl:raise()
						client.focus = cl
						did_focus    = true
						break
					end
				end
				-- Maybe there was no history, like after a restart,
				-- or we don't have any previously-focused clients in this tag,
				-- se we'll just focus the first one we come across that looks eligible for focusing.
				if not did_focus then
					for _, cl in ipairs(tag:clients()) do
						if (not cl.hidden) and (cl.visible ~= false) and (not cl.minimized) then
							cl:raise()
							client.focus = cl
							break
						end
					end
				end
			end
		end
		modality.register(m.TAG .. i ..
								  ":view tag " .. i,
						  fn_view_tag)

		local fn_move_client_to_tag = function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					local c = client.focus
					client.focus:move_to_tag(tag)
					return c
				end
			end
		end
		modality.register(m.CLIENT_MOVE .. "t:to tag," .. i ..
								  ":move to tag " .. i, fn_move_client_to_tag)


		-- fn_move_client_to_tag_and_go moves the client to the tag
		-- and then switches to that tag.
		local fn_move_client_to_tag_and_go = function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					local c = client.focus
					client.focus:move_to_tag(tag)
					c:jump_to(false)
				end
			end
		end
		modality.register(m.CLIENT_MOVE .. "T:to tag (and switch)," .. i ..
								  ":move to tag " .. i .. " and switch to it", fn_move_client_to_tag_and_go)

		awful.keyboard.append_global_keybindings {
			-- View tag only.
			awful.key({ _keys.MOD },
					  "#" .. i + 9,
					  fn_view_tag,
					  descr_view),

			---- Toggle tag display.
			--awful.key({ _keys.MOD, _keys.CTRL },
			--	   "#" .. i + 9,
			--	   function()
			--		   local screen = awful.screen.focused()
			--		   local tag    = screen.tags[i]
			--		   if tag then
			--			   awful.tag.viewtoggle(tag)
			--		   end
			--	   end,
			--	   descr_toggle),

			-- Move client to tag.
			awful.key({ _keys.MOD, _keys.SHIFT },
					  "#" .. i + 9,
					  fn_move_client_to_tag,
					  descr_move),

			-- Toggle tag on focused client.
			--awful.key({ _keys.MOD, _keys.CTRL, _keys.SHIFT },
			--	   "#" .. i + 9,
			--	   function()
			--		   if client.focus then
			--			   local tag = client.focus.screen.tags[i]
			--			   if tag then
			--				   client.focus:toggle_tag(tag)
			--			   end
			--		   end
			--	   end,
			--	   descr_toggle_focus),
		}
	end
end

-- build_awful_key builds an awful.key object.
-- it takes an entry from the lib (1) and a hotkey definition (2)
-- it returns an awful.key
-- FIXME: Handle key groups.. they are currently not handled well at all.
-- Notes
-- key groups are tables
-- 	 where keys for num row numbers are #1, #2, #3, etc
--   where values for num row numbers are +9, maybe because that's the underlying keycode representation?
--   eg. {{ '#1', 10 }, { '#2', 11 }, { '#3', 12 }}
-- I'm not sure if you have to install a custom one at awful.key.keygroups (eg. awful.key.keygroup.NUMROW),
-- or if you can just use it literally.
local function build_awful_key(b, hk)
	assert(not (hk.key_group and hk.code), "cannot use both key_group and keycode")

	b.h.modalities = b.modalities or {}

	local k        = awful.key(
			(hk.mods or { hk[1] }),
			((hk.code or hk.key_group) or hk[2]),
			b.on_press,
			b.on_release,
			b.h)

	return k
end

local function register_awful_binding(scope, b, hk)
	local k = build_awful_key(b, hk)

	if scope == "global" then
		table.insert(lib.global_awful_keys, k)
		awful.keyboard.append_global_keybinding(k)
	elseif scope == "client" then
		table.insert(lib.client_awful_keys, k)
		awful.keyboard.append_client_keybinding(k)
	end
end

function lib.register_client_keybindings()
	for _, b in ipairs(lib.client_bindings) do
		for _, hk in ipairs(b.hotkeys or {}) do
			register_awful_binding("client", b, hk)
		end

		for _, keypath in ipairs(b.modalities or {}) do
			local kp = keypath
			if modality.keypath_target_label(kp) == "" then
				kp = kp .. ":" .. b.h.name
			end
			modality.register(kp, b.on_press, b.on_release, b.hotkeys, b.h)
		end
	end
end

function lib.register_global_keybindings()
	-- Iterate and install all hotkeys through awful.
	for _, b in ipairs(lib.global_bindings) do
		for _, hk in ipairs(b.hotkeys or {}) do
			register_awful_binding("global", b, hk)
		end

		for _, keypath in ipairs(b.modalities or {}) do
			-- Turn "a:awesome,f:foo,b" into "a:awesome,f:foo,b:<name(=bar)>"
			-- if no :<label> is provided.
			-- This is only intended to support leaving an explicit label off,
			-- and to use the data.name of the (awful.key) binding as a default.
			local kp = keypath
			if modality.keypath_target_label(kp) == "" then
				kp = kp .. ":" .. b.h.name
			end
			modality.register(kp, b.on_press, b.on_release, b.hotkeys, b.h)
		end
	end

	install_global_tag_fns_by_index()

	-- Special things.
	-- I have now, several times, accidentally logged out via some keyboard binding...
	-- somewhat mysteriously; not sure exactly which binding.
	-- Going to remove Mod+Z because I have a suspicion;
	-- this would conflict w/ my Quake terminal popup binding, which I use all the time.
	awful.keyboard.remove_global_keybinding(awful.key({ _keys.MOD }, "z"))
end

return setmetatable(lib, {
	__call = function(_, args) end
})

--[[
This is commented code is a reminder that there are signals
that can be used to do things like connecting keybinds too.

I'm under the impression that one can use either/or pattern, but
probably not both because that would be confusing.

-- https://www.reddit.com/r/awesomewm/comments/sok8dm/how_to_hide_titlebar/
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        -- show/hide titlebar
        awful.key({ modkey }, "t", awful.titlebar.toggle,
                {description = "Show/Hide Titlebars", group="client"}),
    })
--end)
--]]
