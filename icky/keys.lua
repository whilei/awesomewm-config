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

local ipairs, table       = ipairs, table
local client              = client

local awful               = require("awful")
local utable              = awful.util.table or gears.table -- 4.{0,1} compatibility
local global_fns          = require("icky.fns").global
local client_fns          = require("icky.fns").client

--[[

awful.key
	- mods
	- key
	- fn
	- h.description
	- h.group

--]]

local _keys               = {
	MOD   = "Mod4",
	SHIFT = "Shift",
	ALT   = "Mod1",
	CTRL  = "Control",
}

-- lib is the returned table.
local lib                 = {
	global_awful_keys = {},
	client_awful_keys = {},
}

lib.get_client_awful_keys = function()
	return lib.client_awful_keys
end

lib.get_global_awful_keys = function()
	return lib.global_awful_keys
end

-- modality is an organization of leader-based key bindings.
-- TODO
local modality            = {
	applications = "a",
	awesome      = "A",
}

lib.global_bindings       = {
	-- {{{ AWESOME
	{
		h        = { group = "awesome", description = "show main menu", name = "main menu" },
		hotkeys  = { { _keys.MOD, "w" } },
		on_press = global_fns.awesome.show_main_menu,
	},
	{
		h        = { group = "awesome", description = "wibar style switcher", name = "toggle wibar" },
		hotkeys  = { { _keys.MOD, "d" } },
		on_press = global_fns.awesome.wibar,
	},
	{
		h        = { group = "awesome", description = "toggle world times widget", name = "world times" },
		hotkeys  = { { _keys.MOD, "g" } },
		on_press = global_fns.awesome.world_times,
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
				key_group = nil, -- eg. "numrow" (=1,2,3,4,5,6,7,8,9,0, callbacks get index arg)
			},
		},
		on_press   = global_fns.apps.handy.top,
		on_release = nil,
	},
	{
		h        = { group = "launcher", description = "handy firefox (left)", name = "handy firefox (left)", },
		hotkeys  = { { mods = { _keys.MOD }, code = "a", }, },
		on_press = global_fns.apps.handy.left,
	},
	{
		h        = { group = "launcher", description = "rofi client picker", name = "rofi", },
		hotkeys  = { { mods = { _keys.MOD }, code = "Return", }, },
		on_press = global_fns.apps.rofi,
	},
	{
		h        = { group = "launcher", description = "toggle quake popup terminal", name = "quake", },
		hotkeys  = { { mods = { _keys.MOD }, code = "z", }, },
		on_press = global_fns.apps.quake,
	},
	{
		h        = { group = "launcher", description = "awesome launcher", name = "launcher", },
		hotkeys  = { { mods = { _keys.MOD }, code = "r", }, },
		on_press = global_fns.apps.popup_launcher,
	},

	-- }}}

	-- {{{ CLIENT
	{
		h        = { group = "client", description = "hints", name = "Hints" },
		hotkeys  = { { mods = { _keys.MOD }, code = "i", }, },
		on_press = global_fns.client.hints,
	},
	{
		h        = { group = "client", description = "revelation", name = "revelation" },
		hotkeys  = { { mods = { _keys.MOD }, code = "e", }, },
		on_press = global_fns.client.revelation,
	},
	{
		h        = { group = "client", description = "restore (=unminimize)", name = "restore" },
		hotkeys  = { { mods = { _keys.MOD, _keys.CTRL }, code = "n", }, },
		on_press = global_fns.client.restore,
	},

	-- CLIENT:FOCUS:SPECIAL
	{
		h        = { group = "client", description = "back (global)", name = "back" },
		hotkeys  = { { mods = { _keys.MOD }, code = "Tab", }, },
		on_press = global_fns.client.focus.back,
	},

	-- CLIENT:FOCUS:BY_INDEX
	{
		h        = { group = "client", description = "next by index", name = "next indexed" },
		hotkeys  = { { mods = { _keys.ALT }, code = "j", }, },
		on_press = global_fns.client.focus.index.next,
	},
	{
		h        = { group = "client", description = "prev by index", name = "prev indexed" },
		hotkeys  = { { mods = { _keys.ALT }, code = "k", }, },
		on_press = global_fns.client.focus.index.prev,
	},

	-- CLIENT:FOCUS:BY_DIRECTION
	{
		h        = { group = "client", description = "focus left", name = "focus left" },
		hotkeys  = { { mods = { _keys.MOD }, code = "h", }, },
		on_press = global_fns.client.focus.direction.left,
	},
	{
		h        = { group = "client", description = "focus right", name = "focus right" },
		hotkeys  = { { mods = { _keys.MOD }, code = "l", }, },
		on_press = global_fns.client.focus.direction.right,
	},
	{
		h        = { group = "client", description = "focus up", name = "focus up" },
		hotkeys  = { { mods = { _keys.MOD }, code = "k", }, },
		on_press = global_fns.client.focus.direction.up,
	},
	{
		h        = { group = "client", description = "focus down", name = "focus down" },
		hotkeys  = { { mods = { _keys.MOD }, code = "j", }, },
		on_press = global_fns.client.focus.direction.down,
	},

	-- CLIENT: SWAP
	{
		h        = { group = "client", description = "swap next by index", name = "swap next" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "j", }, },
		on_press = global_fns.client.swap.index.next,
	},
	{
		h        = { group = "client", description = "swap prev by index", name = "swap prev" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "k", }, },
		on_press = global_fns.client.swap.index.prev,
	},

	-- }}}

	-- {{{ SCREENSHOT
	{
		h        = { group = "screenshots", description = "take a screenshot of the window", name = "screenshot window" },
		hotkeys  = { { mods = { _keys.MOD }, code = "s" }, },
		on_press = global_fns.screenshot.window,
	},
	{
		h        = { group = "screenshots", description = "take a screenshot of a selection", name = "screenshot selection" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "s" }, },
		on_press = global_fns.screenshot.selection,
	},
	-- }}}

	-- {{{ TAGS
	{
		h        = { group = "tag", description = "view previous (by index)", name = "previous" },
		hotkeys  = { { mods = { _keys.MOD }, code = "Left" } },
		on_press = global_fns.tag.prev,
	},
	{
		h        = { group = "tag", description = "view next (by index)", name = "next" },
		hotkeys  = { { mods = { _keys.MOD }, code = "Right" } },
		on_press = global_fns.tag.next,
	},
	{
		h        = { group = "tag", description = "move left", name = "left" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "Left" } },
		on_press = global_fns.tag.move.left,
	},
	{
		h        = { group = "tag", description = "move right", name = "right" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "Right" } },
		on_press = global_fns.tag.move.right,
	},

	-- TAGS:LAYOUT
	{
		h        = { group = "tag", description = "increase master width factor", name = "increment mwf" },
		hotkeys  = { { mods = { _keys.ALT, _keys.SHIFT }, code = "l" } },
		on_press = global_fns.tag.layout.master_width_factor.increase,
	},
	{
		h        = { group = "tag", description = "decrease master width factor", name = "decrement mwf" },
		hotkeys  = { { mods = { _keys.ALT, _keys.SHIFT }, code = "h" } },
		on_press = global_fns.tag.layout.master_width_factor.decrease,
	},

	--{
	--	h        = { group = "tag", description = "view tag # (by index)", name = "view" },
	--	hotkeys  = {
	--		{ mods      = { _keys.MOD },
	--		  key_group = {
	--			  { "#1", 1 + 9 },
	--		  },
	--		},
	--	},
	--	on_press = function(i)
	--		local screen = awful.screen.focused()
	--		local tag    = screen.tags[i]
	--		if tag then
	--			tag:view_only()
	--		end
	--	end,
	--},
	--
	--{
	--	-- omit (most) h data; we don't want to show all these in the help menu
	--	h        = { name = "view" },
	--	hotkeys  = {
	--		{ mods      = { _keys.MOD },
	--		  key_group = {
	--			  { "#2", 2 + 9 },
	--			  { "#3", 3 + 9 },
	--			  { "#4", 4 + 9 },
	--			  { "#5", 5 + 9 },
	--			  { "#6", 6 + 9 },
	--			  { "#7", 7 + 9 },
	--			  { "#8", 8 + 9 },
	--			  { "#9", 9 + 9 },
	--		  },
	--		},
	--	},
	--	on_press = function(i)
	--		local screen = awful.screen.focused()
	--		local tag    = screen.tags[i]
	--		if tag then
	--			tag:view_only()
	--		end
	--	end,
	--},

	-- }}}

	-- {{{ MEDIA
	{
		h        = { group = "media", description = "toggle mic", name = "toggle mic" },
		hotkeys  = { { mods = { _keys.ALT, _keys.CTRL }, code = "0" } },
		on_press = global_fns.media.mic_toggle,
	},
	{
		h        = { group = "media", description = "increase volume", name = "volume up" },
		hotkeys  = { { mods = { _keys.ALT }, code = "Up" } },
		on_press = global_fns.media.volume.up,
	},
	{
		h        = { group = "media", description = "decrease volume", name = "volume down" },
		hotkeys  = { { mods = { _keys.ALT }, code = "Down" } },
		on_press = global_fns.media.volume.down,
	},
	{
		h        = { group = "media", description = "mute volume", name = "volume mute" },
		hotkeys  = { { mods = { _keys.ALT }, code = "m" } },
		on_press = global_fns.media.volume.mute,
	},
	-- }}}

	-- {{{ SCREEN
	{
		h        = { group = "screen", description = "focus next screen", name = "focus next" },
		hotkeys  = { { mods = { _keys.MOD }, code = "u" } },
		on_press = global_fns.screen.next,
	},
	-- }}}
}

lib.client_bindings       = {
	{
		h        = { group = "client", description = "fullscreen client", name = "fullscreen" },
		hotkeys  = { { mods = { _keys.MOD }, code = "f" } },
		on_press = client_fns.fullscreen,
	},
	{
		h        = { group = "client", description = "toggle maximized", name = "maximized" },
		hotkeys  = { { mods = { _keys.MOD }, code = "m" } },
		on_press = client_fns.maximize,
	},
	{
		h        = { group = "client", description = "minimize", name = "minimize" },
		hotkeys  = { { mods = { _keys.MOD }, code = "n" } },
		on_press = client_fns.minimize,
	},
	{
		h        = { group = "client", description = "kill client", name = "kill" },
		hotkeys  = { { mods = { _keys.MOD, _keys.SHIFT }, code = "c" } },
		on_press = client_fns.kill,
	},
	{
		h        = { group = "client", description = "move to next screen", name = "next screen" },
		hotkeys  = { { mods = { _keys.MOD }, code = "o" } },
		on_press = client_fns.screen.move_next,
	},

	-- specialty items
	{
		h        = { group = "client", description = "reader view (tall)", name = "reader (tall)" },
		hotkeys  = { { mods = { _keys.MOD, _keys.CTRL, _keys.SHIFT, }, code = "space" } },
		on_press = client_fns.present.reader_view_tall,
	},
	--{
	--	h        = { group = "client", description = "toggle fancy float position", name = "fancy float" },
	--	hotkeys  = { { mods = { _keys.MOD, }, code = "!" } },
	--	on_press = client_fns.present.fancy_float,
	--},
}

local function install_global_tag_fns_by_index()

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
		awful.keyboard.append_global_keybindings({
													 -- View tag only.
													 awful.key({ _keys.MOD },
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
													 awful.key({ _keys.MOD, _keys.CTRL },
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
													 awful.key({ _keys.MOD, _keys.SHIFT },
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
													 awful.key({ _keys.MOD, _keys.CTRL, _keys.SHIFT },
															   "#" .. i + 9,
															   function()
																   if client.focus then
																	   local tag = client.focus.screen.tags[i]
																	   if tag then
																		   client.focus:toggle_tag(tag)
																	   end
																   end
															   end,
															   descr_toggle_focus),
												 })
	end
end

function lib.init()
	-- build_key builds a key object.
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
	local function build_key(b, hk)
		return awful.key(
				(hk.mods or { hk[1] }),
				((hk.code or hk.key_group) or hk[2]),
				b.on_press,
				b.on_release,
				b.h)

		-- Commented here is WIP from trying to handle keygroups correctly.
		--local k = awful.key(
		--		(hk.mods or { hk[1] }),
		--		((hk.code or hk.key_group) or hk[2]),
		--		b.on_press,
		--		b.on_release,
		--		b.h)

		--local args = {
		--	modifiers   = (hk.mods or { hk[1] }),
		--	on_press    = b.on_press,
		--	on_release  = b.on_release,
		--	name        = b.h.name,
		--	description = b.h.description,
		--	group       = b.h.group
		--}

		--if hk.key_group ~= nil then
		--	args.keygroup = hk.key_group
		--else
		--	args.key = (hk.code or hk[2])
		--end


		--local k = awful.key { args }
	end
	for _, b in ipairs(lib.global_bindings) do

		-- Iterate and install all hotkeys through awful.
		for _, hk in ipairs(b.hotkeys) do

			assert(not (hk.key_group and hk.code), "cannot use both key_group and keycode")

			local k = build_key(b, hk)
			table.insert(lib.global_awful_keys, k)
			awful.keyboard.append_global_keybinding(k)
		end
	end

	for _, b in ipairs(lib.client_bindings) do
		for _, hk in ipairs(b.hotkeys) do
			assert(not (hk.key_group and hk.code), "cannot use both key_group and keycode")

			--local k = awful.key((hk.mods or { hk[1] }), ((hk.code or hk.key_group) or hk[2]), b.on_press, b.on_release, b.h)
			--awful.keyboard.append_client_keybinding(k)

			local k = build_key(b, hk)
			table.insert(lib.client_awful_keys, k)
			awful.keyboard.append_client_keybinding(k)
		end
	end

	install_global_tag_fns_by_index()
end

return setmetatable(lib, {
	__call = function(_, args)
		return lib.init()
	end
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
