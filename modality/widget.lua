-- This file provides the UI for the Modality interface.
local pairs, ipairs, string, math = pairs, ipairs, string, math
local awful                       = require("awful")
local beautiful                   = require("beautiful")
local gears                       = require("gears")
local wibox                       = require("wibox")
local modality_util               = require("modality.util")

local config                      = {
	arrow_color            = '#47A590', -- faded teal
	modality_keypath_color = '#B162A0', -- faded pink
	submenu_color          = '#1479B1', -- blue
	max_rows               = 5,
	min_entry_height       = 16,
	min_entry_width        = 16,
}
config.hotkey_label_color_bg      = '' -- not used
config.hotkey_label_color_fg      = '#B162A0'

-- lib is our returned object.
local lib                         = {}

lib.init                          = function(modality)
	-- NOTE
	-- Can pass the modality lib in here for use in case need be.
	-- Probably a terrible idea/code style.
	lib.modality = modality

	lib.w        = wibox {
		ontop   = true,
		visible = true, -- does this help first-time startup speed?
		x       = 0,
		y       = 0,
		width   = 1,
		height  = 1,
		--opacity = defaults.opacity,
		bg      = beautiful.modality_box_bg or
				beautiful.bg_normal,
		fg      = beautiful.modality_box_fg or
				beautiful.fg_normal,
		--shape=gears.shape.round_rect,
		type    = "toolbar"
	}
	lib.w:setup {
		{
			{
				id     = "title_name",
				widget = wibox.widget.textbox,
			},
			{
				--{
				--	SITE OF FUTURE TEXTBOX
				--},
				--{
				--	SITE OF FUTURE TEXTBOX
				--},
				id              = "textbox_container",

				layout          = wibox.layout.grid, -- I want boxes side-by-side.
				homogeneous     = true,
				expand          = true,
				spacing         = 2,
				forced_num_rows = 5,
				--min_cols_size = 10,
				--min_rows_size = 10,
			},
			id     = "valigner",
			layout = wibox.layout.align.vertical,
		},
		id      = "margin",
		margins = beautiful.modality_box_border_width or
				beautiful.border_width,
		color   = beautiful.modality_box_border or
				beautiful.border_focus,
		layout  = wibox.container.margin,
	}

	awful.screen.connect_for_each_screen(function(s)
		s.modality_box = lib.w
	end)
end

lib.hide                          = function(s)
	local mbox   = s.modality_box
	mbox.visible = false
end

lib.get_widget                    = function(s)
	return s.modality_box.widget
end

lib.keycode_ui_aliases            = {
	["return"]      = "RET",
	["space"]       = "SPC",
	["tab"]         = "TAB",
	["escape"]      = "ESC",
	["super_l"]     = "SUPER",
	["delete"]      = "DEL",

	-- Thanks Copilot.
	["backspace"]   = "BS",
	["left"]        = "←",
	["right"]       = "→",
	["up"]          = "↑",
	["down"]        = "↓",
	["home"]        = "HOME",
	["end"]         = "END",
	["page_up"]     = "PGUP",
	["page_down"]   = "PGDN",
	["insert"]      = "INS",
	["print"]       = "PRTSC",
	["pause"]       = "PAUSE",
	["num_lock"]    = "NUM",
	["scroll_lock"] = "SCR",
	["caps_lock"]   = "CAPS",
	["f1"]          = "F1",
	["f2"]          = "F2",
	["f3"]          = "F3",
	["f4"]          = "F4",
	["f5"]          = "F5",
	["f6"]          = "F6",
	["f7"]          = "F7",
	["f8"]          = "F8",
	["f9"]          = "F9",
	["f10"]         = "F10",
	["f11"]         = "F11",
	["f12"]         = "F12",
	["f13"]         = "F13",
	["f14"]         = "F14",
	["f15"]         = "F15",
	["f16"]         = "F16",
	["f17"]         = "F17",
	["f18"]         = "F18",
	["f19"]         = "F19",
	["f20"]         = "F20",
	["f21"]         = "F21",
	["f22"]         = "F22",
	["f23"]         = "F23",
	["f24"]         = "F24",
	["f25"]         = "F25",
	["f26"]         = "F26",
	["f27"]         = "F27",
	["f28"]         = "F28",
	["f29"]         = "F29",
	["f30"]         = "F30",
	["f31"]         = "F31",
	["f32"]         = "F32",
}

-- keycode_ui_aliases takes a keycode and returns
-- a UI-oriented alias if any.
-- Codes without defined aliases get returned as-is.
local keycode_ui_alias            = function(code)
	if lib.keycode_ui_aliases[code:lower()] then
		return lib.keycode_ui_aliases[code:lower()]
	end
	return code
end

-- get_keypath_markup returns the pango-styled markup for some modality entry (a keypath->function binding).
local function get_keypath_markup(bound)
	--print("[modality] get_keypath_markup", "bound")
	--modality_util.debug_print_paths("", bound)
	--print("")
	--print("")

	-- This (default) should never happen because the 'bound' object is indexed on code.
	local code          = bound.code or ""
	local label         = bound.label or "???"
	local hotkeys_label = bound.hotkeys_label or ""
	local n_bindings    = bound.n_bindings or 0
	local stays         = bound.stay
	local hks           = bound.hotkeys or {}

	if code == "separator" then
		--return "\n"
		return ""
	end
	if code == "onClose" then
		return ""
	end

	-- Abbreviate the key name so it looks like Spacemacs (see aliases table above).
	code = keycode_ui_alias(code)

	if hotkeys_label ~= "" then
		hotkeys_label = "<span " ..
				"foreground='" .. config.hotkey_label_color_fg .. "' " ..
				--"background='" .. config.hotkey_label_color_bg .. "' " ..
				"> " .. hotkeys_label .. " </span>"
	end

	-- Assign the default markup value.
	local action_markup   = "<span>" ..
			label ..
			(stays and " (~)" or "") ..
			(hotkeys_label ~= "" and (" " .. hotkeys_label) or "") ..
			"</span>"

	local is_submenu_name = n_bindings > 0
	--local is_submenu_name = bound.bindings and #bound.bindings > 0
	if is_submenu_name then
		action_markup = "<span foreground='" .. config.submenu_color .. "'>" .. "+" .. label .. "</span>"
	end
	local underline_matches = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local underline         = "none"
	if string.find(underline_matches, code, 1, true) then
		underline = "single"
	end

	return "<b><span> " ..
			'<span underline="' .. underline .. '" foreground="' .. config.modality_keypath_color .. '">' ..
			gears.string.xml_escape(code) ..
			'</span>' ..
			'</span>' ..
			"</b>" ..
			"<span foreground='" .. config.arrow_color .. "'>  ➞  </span>" ..
			action_markup
end

-- lib.show shows the modality box.
-- @s: screen
-- @parent: is the parent schema, expected to include
--   - label
--   - bindings
--   - fn
--   - stay
-- The parent's data type is defined in modality paths.
--]]
lib.show = function(s, parent)
	if s == nil then
		s = awful.screen.focused()
	end
	assert(parent, "parent is nil")
	assert(type(parent) == "table", "parent must be a table")

	local mbox     = s.modality_box
	mbox.screen    = s

	-- modality_util.debug_print_paths("[modality] show", parent)

	local name     = parent.label or "???"

	local mar      = mbox:get_children_by_id("margin")[1]
	local tbc      = mbox:get_children_by_id("textbox_container")[1]
	--tbc:reset()
	tbc.children   = {} -- reset because submenus want redraw

	local titlebox = mbox:get_children_by_id("title_name")[1]

	-- First, lets do the title.
	if name == "" then
		--name = "Modality"
	end

	if name ~= "" and name ~= lib.modality.path_tree.label then
		titlebox:set_markup("<big><b>" .. name .. "</b></big>\n")
		titlebox.visible = true
		if parent.stay then
			titlebox:set_markup("<big><b>" .. name .. " (~)" .. "</b></big>\n")
		end
	else
		titlebox:set_markup("")
		titlebox.visible = false
	end

	-- Show options
	local _pc      = 0
	local _largest = { width = 24, height = 8 }

	-- Add bindings textboxes for this binding table.
	-- Docs: https://awesomewm.org/apidoc/widget_layouts/wibox.layout.grid.html
	if parent.bindings then

		-- exists
		--modality_util.debug_print_paths("[modality] parent.bindings", parent.bindings)


		-- Sort alphabetically, sort of.
		-- I want punctuation first, then modifier and other special keys, then letters.
		local sorted_binding_codes = gears.table.keys(parent.bindings)
		local punctuation_chars    = "!@#$%^&*()_+{}|:<>?`~[];',./-=\""
		local specialty_keys       = gears.table.keys(lib.keycode_ui_aliases)

		table.sort(sorted_binding_codes, function(a, b)
			local a_reserved_first = string.find(punctuation_chars, a, 1, true)
			local b_reserved_first = string.find(punctuation_chars, b, 1, true)
			if a_reserved_first and not b_reserved_first then
				return true
			end
			if not a_reserved_first and b_reserved_first then
				return false
			end

			local a_reserved_second = gears.table.hasitem(specialty_keys, a:lower())
			local b_reserved_second = gears.table.hasitem(specialty_keys, b:lower())
			if a_reserved_second and not b_reserved_second then
				return true
			end
			if not a_reserved_second and b_reserved_second then
				return false
			end
			return a:lower() < b:lower()
		end)

		for _, code in ipairs(sorted_binding_codes) do
			local bound = parent.bindings[code]
			bound.code  = code

			--bound.bindings = parent.bindings[code].bindings -- Hmm.... this works? No. (Make the 'bound' var actually have the bindings...?)
			--modality_util.debug_print_paths("[modality] bound", bound)

			local m     = get_keypath_markup(bound)

			if code:lower() ~= "escape" and m ~= "" then
				local txtbx = wibox.widget.textbox()
				txtbx:set_markup_silently(m)

				local _w, _h    = txtbx:get_preferred_size()
				_largest.width  = math.max(_largest.width, math.max(config.min_entry_width, _w))
				_largest.height = math.max(_largest.height, math.max(config.min_entry_height, _h))

				local _r        = _pc % config.max_rows + 1
				local _c        = math.floor(_pc / config.max_rows) + 1

				tbc:add_widget_at(txtbx, _r, _c, 1, 1) -- child, row, col, ~row_span, ~col_span
				_pc = _pc + 1
			end
		end
	end

	tbc.min_cols_size        = _largest.width
	tbc.min_rows_size        = _largest.height

	local _drows, _dcols     = tbc:get_dimension()
	_drows                   = math.max(_drows, 1)
	_dcols                   = math.max(_dcols, 1)

	mbox.width               = (_dcols * _largest.width) + (2 * tbc.spacing * _dcols) + (mar.right + mar.left)
	mbox.width               = math.max(mbox.width, 400)
	local _height_calculated = (_drows * _largest.height) + (2 * tbc.spacing * _drows) + (mar.top + mar.bottom)
	if name ~= "" then
		local _, _tb_h     = titlebox:get_preferred_size()
		_height_calculated = _height_calculated + _tb_h
	end
	mbox.height = math.max(22, _height_calculated)

	awful.placement.align(
			mbox,
			{
				position       = "bottom",
				honor_padding  = true,
				honor_workarea = true,
				offset         = { x = 0, y = 0 },
			}
	)

	--mbox:emit_signal("widget::layout_changed")
	mbox:emit_signal("widget::redraw_needed")
	mbox.visible = true
end

return lib
