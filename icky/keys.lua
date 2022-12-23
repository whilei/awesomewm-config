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

local modkey        = "Mod4"
local shiftkey      = "Shift"

local lib           = {}

local modality      = {
	applications = "a",
	awesome      = "A",
}

lib.global_bindings = {
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
				mods      = { modkey }, code = "v",
				key_group = nil, -- eg. "numrow"=1,2,3,4,5,6,7,8,9,0
			},
		},
		on_press   = fns.apps.handy.top,
		on_release = nil,
	},
	{
		h          = { group = "launcher", description = "Handy Firefox (left)", name = "Handy Firefox (left)", },
		modalities = { modality.applications .. "hh" },
		hotkeys    = { { mods = { modkey }, code = "a", }, },
		on_press   = fns.apps.handy.left,
	},
	{
		h        = { group = "client", description = "hints", name = "Hints" },
		hotkeys  = { { mods = { modkey }, code = "i" }, },
		on_press = fns.client.hints,
	},
	-- }}}

	-- {{{ SCREENSHOT
	{
		h        = { group = "screenshots", description = "take a screenshot of the window", name = "screenshot window" },
		hotkeys  = { { mods = { modkey }, code = "s" }, },
		on_press = fns.screenshot.window,
	},
	{
		h        = { group = "screenshots", description = "take a screenshot of a selection", name = "screenshot selection" },
		hotkeys  = { { mods = { modkey, shiftkey }, code = "s" }, },
		on_press = fns.screenshot.selection,
	},
	-- }}}

	-- {{{ TAGS
	{
		h        = { group = "tag", description = "view previous", name = "view previous tag" },
		hotkeys  = { { mods = { modkey }, code = "Left" } },
		on_press = fns.tag.prev,
	},
	{
		h        = { group = "tag", description = "view next", name = "view next tag" },
		hotkeys  = { { mods = { modkey }, code = "Right" } },
		on_press = fns.tag.next,
	},
	-- }}}
}

function lib.init()
	for _, b in ipairs(lib.global_bindings) do

		-- Iterate and install all hotkeys through awful.
		for _, hk in ipairs(b.hotkeys) do

			assert(not (hk.key_group and hk.code), "cannot use both key_group and keycode")

			local k = awful.key(hk.mods, (hk.code or hk.key_group), b.on_press, b.on_release, b.h)
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