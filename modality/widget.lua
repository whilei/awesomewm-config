-- This file provides the UI for the Modality interface.
local pairs, ipairs, string, math = pairs, ipairs, string, math
local awful                       = require("awful")
local beautiful                   = require("beautiful")
local gears                       = require("gears")
local wibox                       = require("wibox")
local util                        = require("modality.util")

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

-- keycode_ui_aliases takes a keycode and returns
-- a UI-oriented alias if any.
-- Codes without defined aliases get returned as-is.
local keycode_ui_alias            = function(code)
	if util.keycode_ui_aliases[code:lower()] then
		return util.keycode_ui_aliases[code:lower()]
	end
	return code
end

-- get_keypath_markup returns the pango-styled markup for some modality entry (a keypath->function binding).
local function build_keypath_widget(bound)
	--print("[modality] get_keypath_markup", "bound")
	--modality_util.debug_print_paths("", bound)
	--print("")
	--print("")

	-- This (default) should never happen because the 'bound' object is indexed on code.
	local codes         = bound.codes or {}
	local label         = bound.label or "???"
	local hotkeys_label = bound.hotkeys_label or ""
	local n_bindings    = bound.n_bindings or 0
	local stays         = bound.stay
	local hks           = bound.hotkeys or {}

	if codes[1] == "separator" then
		return
	end
	if codes[1] == "onClose" then
		return
	end

	-- Abbreviate the key name so it looks like Spacemacs (see aliases table above).
	for i, code in ipairs(codes) do
		codes[i] = keycode_ui_alias(code)
	end

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

	-- FIXME This is another symptom of the issue where I cannot get the
	-- bindings tabs from the parent.bindings[code] object.
	-- So I have to rely on flat, simple data types to represent the data I need;
	-- here: the number of bindings (if any).
	-- I would rather check the actual bindings object for existence and count.
	local is_submenu_name = n_bindings > 0
	--local is_submenu_name = bound.bindings and #bound.bindings > 0

	if is_submenu_name then
		action_markup = "<span foreground='" .. config.submenu_color .. "'>" .. "+" .. label .. "</span>"
	end

	-- code_spans becomes the markup for the keycodes.
	-- We use a table (a list) because there may be more than one code bound to some function.
	-- In this case, multiple codes are joined with a comma.
	local code_spans        = {
		--"<span foreground='" .. config.keycode_color .. "'>$code</span>",
	}

	-- underline_matches defines a list of keycodes that should be underlined.
	local underline_matches = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	for i, code in ipairs(codes) do
		local underline = "none"
		if underline_matches:find(code, 1, true) then
			underline = "single"
		end
		code_spans[i] = "" ..
				"<b>" ..
				"<span " ..
				"foreground='" .. config.modality_keypath_color .. "' " ..
				"underline='" .. underline .. "' " ..
				">" .. gears.string.xml_escape(code) ..
				"</span>" ..
				"</b>"
	end

	local m        = "" ..
			table.concat(code_spans, ",") ..
			"<span foreground='" .. config.arrow_color .. "'>  ➞  </span>" ..
			action_markup

	local text_box = wibox.widget.textbox()
	text_box:set_markup(m)
	return text_box
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
		local specialty_keys       = gears.table.keys(util.keycode_ui_aliases)

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

		-- Dedupe functions that have more than one binding associated with them at this level.
		-- eg. [Return, ?] for search.

		local fn_codes = {
			-- fn = { code1, code2, ... }
		}
		for code, bound in pairs(parent.bindings) do
			if bound.fn then
				local fn = bound.fn
				if not fn_codes[fn] then
					fn_codes[fn] = {}
				end
				table.insert(fn_codes[fn], code)
			end
		end

		local seen_fns = {
			-- fn = true,
		}

		for _, code in ipairs(sorted_binding_codes) do
			local bound = parent.bindings[code]
			bound.codes = { code }

			if bound.fn and seen_fns[bound.fn] then
				-- skip
				-- This function has multiple key codes associated with it
				-- and we have already handled it.
			else
				if bound.fn then
					seen_fns[bound.fn] = true
				end
				bound.codes    = fn_codes[bound.fn] or { code } -- or case handles bindings without functions

				-- FIXME bound.bindings does not exist. Why not? Smells like a table copy/clone issue?
				--bound.bindings = parent.bindings[code].bindings -- Hmm.... this works? No. (Make the 'bound' var actually have the bindings...?)
				--modality_util.debug_print_paths("[modality] bound", bound)

				local text_box = build_keypath_widget(bound)

				if code:lower() ~= "escape" and text_box ~= "" then

					local _w, _h    = text_box:get_preferred_size(s)
					_largest.width  = math.max(_largest.width, math.max(config.min_entry_width, _w))
					_largest.height = math.max(_largest.height, math.max(config.min_entry_height, _h))

					local _r        = _pc % config.max_rows + 1
					local _c        = math.floor(_pc / config.max_rows) + 1

					tbc:add_widget_at(text_box, _r, _c, 1, 1) -- child, row, col, ~row_span, ~col_span
					_pc = _pc + 1
				end
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
