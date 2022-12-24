---------------------------------------------------------------------------
-- Keys
--
-- Icky key bindings and what to do with them.
--
-- All functions used by keybindings declared here should be defined in fns.lua.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod icky.keys
---------------------------------------------------------------------------

local ipairs        = ipairs

local awful         = require("awful")
local fns           = require("icky.fns")

--[[

awful.key
	- mods
	- key
	- fn
	- h.description
	- h.group

--]]

local _keys         = {
	MOD   = "Mod4",
	SHIFT = "Shift",
	ALT   = "Mod1",
	CTRL  = "Control",
}

-- lib is the returned table.
local lib           = {}

-- modality is an organization of leader-based key bindings.
-- TODO
local modality      = {
	applications = "a",
	awesome      = "A",
}

lib.global_bindings = {
	-- {{{ AWESOME
	{
		h        = { group = "awesome", description = "show main menu", name = "main menu" },
		hotkeys  = { { _keys.MOD, "w" } },
		on_press = fns.awesome.show_mainmenu,
	},
	-- }}}
	-- {{{ APPS
	{
		h          = {
			group       = "launcher",
			description = "handy firefox (top)",
			name        = "handy firefox (top)",
		},
		modalities = { modality.applications .. "hk" },
		hotkeys    = {
			{
				mods      = { _keys.MOD }, code = "v",
				key_group = nil, -- eg. "numrow"=1,2,3,4,5,6,7,8,9,0
			},
		},
		on_press   = fns.apps.handy.top,
		on_release = nil,
	},
	{
		h        = { group = "launcher", description = "handy firefox (left)", name = "handy firefox (left)", },
		hotkeys  = { { mods = { _keys.MOD }, code = "a", }, },
		on_press = fns.apps.handy.left,
	},
	{
		h        = { group = "launcher", description = "rofi client picker", name = "rofi", },
		hotkeys  = { { mods = { _keys.MOD }, code = "Return", }, },
		on_press = fns.apps.rofi,
	},
	{
		h        = { group = "launcher", description = "toggle quake popup terminal", name = "quake", },
		hotkeys  = { { mods = { _keys.MOD }, code = "z", }, },
		on_press = fns.apps.quake,
	},
	{
		h        = { group = "launcher", description = "awesome launcher", name = "launcher", },
		hotkeys  = { { mods = { _keys.MOD }, code = "r", }, },
		on_press = fns.apps.popup_launcher,
	},

	-- }}}

	-- {{{ CLIENT
	{
		h        = { group = "client", description = "hints", name = "Hints" },
		hotkeys  = { { mods = { _keys.MOD }, code = "i", }, },
		on_press = fns.client.hints,
	},
	{
		h        = { group = "client", description = "revelation", name = "revelation" },
		hotkeys  = { { mods = { _keys.MOD }, code = "e", }, },
		on_press = fns.client.revelation,
	},
	{
		h        = { group = "client", description = "restore (=unminimize)", name = "restore" },
		hotkeys  = { { mods = { _keys.MOD, _keys.CTRL }, code = "n", }, },
		on_press = fns.client.restore,
	},

	-- CLIENT:FOCUS:SPECIAL
	{
		h        = { group = "client", description = "back (global)", name = "back" },
		hotkeys  = { { mods = { _keys.MOD }, code = "Tab", }, },
		on_press = fns.client.focus.back,
	},

	-- CLIENT:FOCUS:BY_INDEX
	{
		h        = { group = "client", description = "next by index", name = "next indexed" },
		hotkeys  = { { mods = { _keys.ALT }, code = "j", }, },
		on_press = fns.client.focus.index.next,
	},
	{
		h        = { group = "client", description = "prev by index", name = "prev indexed" },
		hotkeys  = { { mods = { _keys.ALT }, code = "k", }, },
		on_press = fns.client.focus.index.prev,
	},

	-- CLIENT:FOCUS:BY_DIRECTION
	{
		h        = { group = "client", description = "focus left", name = "focus left" },
		hotkeys  = { { mods = { _keys.MOD }, code = "h", }, },
		on_press = fns.client.focus.direction.left,
	},
	{
		h        = { group = "client", description = "focus right", name = "focus right" },
		hotkeys  = { { mods = { _keys.MOD }, code = "l", }, },
		on_press = fns.client.focus.direction.right,
	},
	{
		h        = { group = "client", description = "focus up", name = "focus up" },
		hotkeys  = { { mods = { _keys.MOD }, code = "k", }, },
		on_press = fns.client.focus.direction.up,
	},
	{
		h        = { group = "client", description = "focus down", name = "focus down" },
		hotkeys  = { { mods = { _keys.MOD }, code = "j", }, },
		on_press = fns.client.focus.direction.down,
	},

	-- CLIENT: SWAP
	{
		h        = { group = "client", description = "swap next by index", name = "swap next" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "j", }, },
		on_press = fns.client.swap.index.next,
	},
	{
		h        = { group = "client", description = "swap prev by index", name = "swap prev" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "k", }, },
		on_press = fns.client.swap.index.prev,
	},

	-- }}}

	-- {{{ SCREENSHOT
	{
		h        = { group = "screenshots", description = "take a screenshot of the window", name = "screenshot window" },
		hotkeys  = { { mods = { _keys.MOD }, code = "s" }, },
		on_press = fns.screenshot.window,
	},
	{
		h        = { group = "screenshots", description = "take a screenshot of a selection", name = "screenshot selection" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "s" }, },
		on_press = fns.screenshot.selection,
	},
	-- }}}

	-- {{{ TAGS
	{
		h        = { group = "tag", description = "view previous", name = "view previous tag" },
		hotkeys  = { { mods = { _keys.MOD }, code = "Left" } },
		on_press = fns.tag.prev,
	},
	{
		h        = { group = "tag", description = "view next", name = "view next tag" },
		hotkeys  = { { mods = { _keys.MOD }, code = "Right" } },
		on_press = fns.tag.next,
	},
	{
		h        = { group = "tag", description = "move left", name = "move tag left" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "Left" } },
		on_press = fns.tag.move.left,
	},
	{
		h        = { group = "tag", description = "move right", name = "move tag right" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "Right" } },
		on_press = fns.tag.move.right,
	},

	-- TAGS:LAYOUT
	{
		h        = { group = "tag", description = "increase master width factor", name = "increment mwf" },
		hotkeys  = { { mods = { _keys.ALT, _keys.SHIFT }, code = "l" } },
		on_press = fns.tag.layout.master_width_factor.increase,
	},
	{
		h        = { group = "tag", description = "decrease master width factor", name = "decrement mwf" },
		hotkeys  = { { mods = { _keys.ALT, _keys.SHIFT }, code = "h" } },
		on_press = fns.tag.layout.master_width_factor.decrease,
	},

	-- }}}

	-- {{{ MEDIA
	{
		h        = { group = "media", description = "toggle mic", name = "toggle mic" },
		hotkeys  = { { mods = { _keys.ALT, _keys.CTRL }, code = "0" } },
		on_press = fns.media.mic_toggle,
	},
	{
		h        = { group = "media", description = "increase volume", name = "volume up" },
		hotkeys  = { { mods = { _keys.ALT }, code = "Up" } },
		on_press = fns.media.volume.up,
	},
	{
		h        = { group = "media", description = "decrease volume", name = "volume down" },
		hotkeys  = { { mods = { _keys.ALT }, code = "Down" } },
		on_press = fns.media.volume.down,
	},
	{
		h        = { group = "media", description = "mute volume", name = "volume mute" },
		hotkeys  = { { mods = { _keys.ALT }, code = "m" } },
		on_press = fns.media.volume.mute,
	},
	-- }}}
}

function lib.init()
	for _, b in ipairs(lib.global_bindings) do

		-- Iterate and install all hotkeys through awful.
		for _, hk in ipairs(b.hotkeys) do

			assert(not (hk.key_group and hk.code), "cannot use both key_group and keycode")

			local k = awful.key((hk.mods or { hk[1] }), ((hk.code or hk.key_group) or hk[2]), b.on_press, b.on_release, b.h)
			awful.keyboard.append_global_keybindings({ k })
		end

	end
end

--return keys

return setmetatable(lib, {
	__call = function(_, args)
		return lib.init()
	end
})