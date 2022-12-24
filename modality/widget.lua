-- This file provides the UI for the Modality interface.
local pairs, ipairs, string, math = pairs, ipairs, string, math
local awful                       = require("awful")
local beautiful                   = require("beautiful")
local gears                       = require("gears")
local wibox                       = require("wibox")

local config                      = {
	arrow_color      = '#47A590', -- faded teal
	hotkey_color     = '#B162A0', -- faded pink
	submenu_color    = '#1479B1', -- blue
	max_rows         = 5,
	min_entry_height = 16,
	min_entry_width  = 16,
}

-- lib is our returned object.
local lib                         = {}

lib.init                          = function()
	local w = wibox {
		ontop   = true,
		visible = false,
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
	w:setup {
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
		s.modality_box = w
	end)
end

lib.hide                          = function(s)
	local mbox   = s.modality_box
	mbox.visible = false
end

-- lib.show shows the modality box.
-- @s: screen
-- @map: the map of available bindings to show
--
-- The map should be of the form defined in modality paths.
--]]
lib.show                          = function(s, bindings_parent)
	local mbox     = s.modality_box
	mbox.screen    = s

	local name     = bindings_parent.label or "???"

	local mar      = mbox:get_children_by_id("margin")[1]
	local tbc      = mbox:get_children_by_id("textbox_container")[1]
	--tbc:reset()
	tbc.children   = {} -- reset because submenus want redraw

	local titlebox = mbox:get_children_by_id("title_name")[1]

	-- First, lets do the title.
	if name == "" then
		--name = "Modality"
	end

	if name ~= "" then
		titlebox:set_markup("<big><b>" .. name .. "</b></big>\n")
		titlebox.visible = true
	else
		titlebox:set_markup("")
		titlebox.visible = false
	end

	local function get_markup_for_entry(code, label, bindings, fn)
		if code == "separator" then
			--return "\n"
			return ""
		end
		if code == "onClose" then
			return ""
		end

		-- Abbreviate the key name so it looks like Spacemacs.
		code = string.gsub(code, "Return", "RET")
		code = string.gsub(code, "Space", "SPC")
		code = string.gsub(code, "Tab", "TAB")
		code = string.gsub(code, "Escape", "ESC")

		-- Handle configuration problems gracefully.
		if not label or label == "" then
			label = "???"
		end

		-- Assign the default markup value.
		local action_markup = "<span>" .. label .. "</span>"

		if label then
			local is_submenu_name = bindings ~= nil
			if is_submenu_name then
				action_markup = "<span foreground='" .. config.submenu_color .. "'>" .. "+" .. label .. "</span>"
			end
		end

		local underline_matches = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local underline         = "none"
		if string.find(underline_matches, code, 1, true) then
			underline = "single"
		end

		return "<b><span> " ..
				'<span underline="' .. underline .. '" foreground="' .. config.hotkey_color .. '">' ..
				gears.string.xml_escape(code) ..
				'</span>' ..
				'</span>' ..
				"</b>" ..
				"<span foreground='" .. config.arrow_color .. "'> ➞ </span>" ..
				action_markup
	end

	-- Show options
	local _pc            = 0
	--local _last_row, _last_col = 1, 1
	local _largest       = { width = 24, height = 8 }

	sorted_binding_codes = gears.table.keys(bindings_parent.bindings)
	table.sort(sorted_binding_codes)

	for _, code in ipairs(sorted_binding_codes) do
		local bound = bindings_parent.bindings[code]

		local m     = get_markup_for_entry(code, bound.label, bound.bindings, bound.fn)
		if string.lower(code) ~= "escape" and m ~= "" then
			local txtbx = wibox.widget.textbox()
			txtbx:set_markup_silently(m)

			local _w, _h    = txtbx:get_preferred_size()
			_largest.width  = math.max(_largest.width, math.max(config.min_entry_width, _w))
			_largest.height = math.max(_largest.height, math.max(config.min_entry_height, _h))

			--local _r, _c    = tbc:get_next_empty(_last_row, _last_col)
			--if _r > config.max_rows then
			--	-- Reset the row, increment the column.
			--	_r, _c = 1, _c + 1
			--end

			local _r        = _pc % config.max_rows + 1
			local _c        = math.floor(_pc / config.max_rows) + 1

			--tbc:add_widget_at(txtbx, _r, _c, 1, 1) -- child, row, col, ~row_span, ~col_span
			tbc:add_widget_at(txtbx, _r, _c, 1, 1) -- child, row, col, ~row_span, ~col_span
			-- tbc:add(txtbx)
			-- https://awesomewm.org/apidoc/widget_layouts/wibox.layout.grid.html

			_pc = _pc + 1
			--_last_row = _r
			--_last_col = _c
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