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
			description = "Handy Firefox (top)",
			name        = "Handy Firefox (top)",
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
		h          = { group = "launcher", description = "Handy Firefox (left)", name = "Handy Firefox (left)", },
		modalities = { modality.applications .. "hh" },
		hotkeys    = { { mods = { _keys.MOD }, code = "a", }, },
		on_press   = fns.apps.handy.left,
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
		h        = { group = "client", description = "focus client left", name = "focus left" },
		hotkeys  = { { mods = { _keys.MOD }, code = "h", }, },
		on_press = fns.client.focus.direction.left,
	},
	{
		h        = { group = "client", description = "focus client right", name = "focus right" },
		hotkeys  = { { mods = { _keys.MOD }, code = "l", }, },
		on_press = fns.client.focus.direction.right,
	},
	{
		h        = { group = "client", description = "focus client up", name = "focus up" },
		hotkeys  = { { mods = { _keys.MOD }, code = "k", }, },
		on_press = fns.client.focus.direction.up,
	},
	{
		h        = { group = "client", description = "focus client down", name = "focus down" },
		hotkeys  = { { mods = { _keys.MOD }, code = "j", }, },
		on_press = fns.client.focus.direction.down,
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