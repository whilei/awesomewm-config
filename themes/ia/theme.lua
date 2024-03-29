--[[
     Isaac's Special theme.
     Copyright 2022 Isaac.
--]]

local math                        = math
local string                      = string
local type                        = type
local tonumber                    = tonumber
local tostring                    = tostring
local ipairs                      = ipairs

local client, tag                 = client, tag

local gears                       = require("gears")
local lain                        = require("lain")
local awful                       = require("awful")
local wibox                       = require("wibox")
local common                      = require("awful.widget.common")
local beautiful                   = require("beautiful")
local special                     = require("special")
local special_log_load_time       = require("special").log_load_time
local special_log_load_time_reset = require("special").log_load_time_reset
local dpi                         = beautiful.xresources.apply_dpi
local markup                      = lain.util.markup
local calendar_widget             = require("awesome-wm-widgets.calendar-widget.calendar")
local battery_widget              = require("battery_widget")
local os                          = {
	getenv  = os.getenv,
	tmpname = os.tmpname,
	execute = os.execute,
	remove  = os.remove,
}
local my_table                    = gears.table or awful.util.table -- 4.{0,1} compatibility
local dash                        = require("dash")

local theme                       = {}
theme.dir                         = gears.filesystem.get_configuration_dir() .. "themes/ia"
theme.dir_macos                   = gears.filesystem.get_configuration_dir() .. "awesome-macos/themes/macos-dark"

-- Wallpaper, wallpaper
theme.wallTallIndex               = 0
theme.wallWideIndex               = 0
function wallpaperForScreenByDimension(s)
	-- Default wide.
	local out = theme.dir .. "/walls/iter/wide/wall" .. theme.wallWideIndex .. ".jpg"

	-- If known tall screens.
	if s.geometry.width < s.geometry.height then
		out                 = theme.dir .. "/walls/iter/tall/wall" .. theme.wallTallIndex .. ".jpg"
		theme.wallTallIndex = theme.wallTallIndex + 1
		return out
	end

	theme.wallWideIndex = theme.wallWideIndex + 1
	return out
end
--theme.wallpaper                                 = wallpaperForScreenByDimension
theme.wallpaper                                 = theme.dir .. "/walls/solidcolor_black.png"

-- $ awesome-client
-- $ b = require("beautiful"); local c = "#08158a"; b.titlebar_bg_focus = c; b.tasklist_bg_focus = c;

theme.master_width_factor                       = 0.7

theme.notification_position                     = "top_middle"

theme.font_biggest                              = "monospace 16"
theme.font_bigger                               = "monospace 12"
theme.font_big                                  = "monospace 10"
theme.font                                      = "monospace 9"
theme.font_small                                = "monospace 8"
theme.font_smaller                              = "monospace 7"
theme.font_smallest                             = "monospace 6"

theme.color_white                               = "#FFFFFF"
theme.color_green                               = "#27CC27"
theme.color_yellow                              = "#FFFF00"
theme.color_orange                              = "#FF8000"
theme.color_red                                 = "#DF0101"
theme.color_lightblue                           = "#4070cf"
theme.color_blue                                = "#08158a"
theme.color_darkblue                            = "#05092a"
theme.color_turquoise                           = "#00fcec"

theme.menu_bg_normal                            = "#000000"
theme.menu_bg_focus                             = "#000000"
theme.bg_normal                                 = "#000000" -- is Wibar bg
theme.bg_focus                                  = "#000000"
theme.bg_urgent                                 = "#000000"
theme.fg_normal                                 = "#aaaaaa"
theme.fg_focus                                  = theme.color_turquoise-- "#ff8c00" -- lightblue/turquoise/teal, eg. for tag list highlight
theme.fg_urgent                                 = "#af1d18"
theme.bg_minimize                               = "#2e2d2e"
theme.fg_minimize                               = "#ffffff"

theme.clock_bg                                  = "#191f1a"
theme.colon_fg                                  = "#256c1e"
theme.clock_fg                                  = "#32ab3a" -- #3030c9
theme.clock_mylocal                             = "#A51C48"

-- theme.border_normal                             = "#1c2022"
-- theme.border_focus                              = "#606060"
-- theme.border_marked                             = "#3ca4d8"

theme.border_color_normal                       = theme.bg_normal .. "ff"
theme.border_color_focus                        = theme.color_blue -- "#0B1DC2"
theme.border_color_marked                       = "#f05800"

theme.border_width                              = 0 -- 4
--theme.border_width_active = 10
--theme.border_color_active = "black"
--theme.border_width_normal = 40
--theme.border_color_normal = "black"

theme.tasklist_bg_normal                        = "#05092a" -- "#313452" -- "#c8def7"#f01800
theme.tasklist_bg_focus                         = "#08158a" -- "#420f94"--purple -- blue="#08158a" -- "#1A1A1A"
theme.tasklist_fg_normal                        = "#FFFFFF"
theme.tasklist_fg_focus                         = "#FFFFFF"

theme.titlebar_bg_focus                         = theme.color_blue -- theme.bg_focus
theme.titlebar_bg_normal                        = theme.color_darkblue
theme.titlebar_fg_focus                         = theme.color_white -- "#ffffff" -- theme.fg_focus

theme.menu_height                               = 18
theme.menu_width                                = 140

theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.taglist_squares_sel                       = nil
theme.taglist_squares_unsel                     = nil

theme.layout_icon_color                         = theme.color_turquoise -- "#0B1FEA" -- a little brighter thant theme.color_blue

theme.layout_tile                               = gears.color.recolor_image(theme.dir .. "/icons/tile.png", theme.layout_icon_color)
theme.layout_tileleft                           = gears.color.recolor_image(theme.dir .. "/icons/tileleft.png", theme.layout_icon_color)
theme.layout_tilebottom                         = gears.color.recolor_image(theme.dir .. "/icons/tilebottom.png", theme.layout_icon_color)
theme.layout_tiletop                            = gears.color.recolor_image(theme.dir .. "/icons/tiletop.png", theme.layout_icon_color)
theme.layout_fairv                              = gears.color.recolor_image(theme.dir .. "/icons/fairv.png", theme.layout_icon_color)
theme.layout_fairh                              = gears.color.recolor_image(theme.dir .. "/icons/fairh.png", theme.layout_icon_color)
theme.layout_spiral                             = gears.color.recolor_image(theme.dir .. "/icons/spiral.png", theme.layout_icon_color)
theme.layout_dwindle                            = gears.color.recolor_image(theme.dir .. "/icons/dwindle.png", theme.layout_icon_color)
theme.layout_max                                = gears.color.recolor_image(theme.dir .. "/icons/max.png", theme.layout_icon_color)
--theme.layout_fullscreen                         = gears.color.recolor_image(theme.dir .. "/icons/fullscreen.png", theme.layout_icon_color)
theme.layout_magnifier                          = gears.color.recolor_image(theme.dir .. "/icons/magnifier.png", theme.layout_icon_color)
theme.layout_floating                           = gears.color.recolor_image(theme.dir .. "/icons/floating.png", theme.layout_icon_color)
--theme.layout_centerwork                         = gears.color.recolor_image(theme.dir .. "/icons/centerwork.png", theme.layout_icon_color)
theme.layout_centerwork                         = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "lain/icons/layout/default/centerwork.png", theme.layout_icon_color)
theme.layout_swen                               = gears.color.recolor_image(theme.dir .. "/icons/swen.png", theme.layout_icon_color)
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_mem                                = theme.dir .. "/icons/mem.png"
theme.widget_cpu                                = theme.dir .. "/icons/cpu.png"
theme.widget_temp                               = theme.dir .. "/icons/temp.png"
theme.widget_net                                = theme.dir .. "/icons/net.png"
theme.widget_hdd                                = theme.dir .. "/icons/hdd.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_mic_on                             = theme.dir .. "/icons/mic_google_on.png"
theme.widget_mic_off                            = theme.dir .. "/icons/mic_off.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.tasklist_plain_task_name                  = false -- true
theme.tasklist_disable_icon                     = false -- true
theme.useless_gap                               = 0

-- OPTION 1

--theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
--theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
--
--theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
--theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
--theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
--theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
--
--theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
--theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
--theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
--theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
--
--theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
--theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
--theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
--theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
--
--theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
--theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
--theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
--theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

-- OPTION 2
--
theme.titlebar_close_button_focus               = theme.dir_macos .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir_macos .. "/icons/titlebar/close_normal.png"
--
--theme.titlebar_ontop_button_focus_active        = theme.dir_macos .. "/icons/titlebar/ontop_focus_active.png"
--theme.titlebar_ontop_button_normal_active       = theme.dir_macos .. "/icons/titlebar/ontop_normal_active.png"
--theme.titlebar_ontop_button_focus_inactive      = theme.dir_macos .. "/icons/titlebar/ontop_focus_inactive.png"
--theme.titlebar_ontop_button_normal_inactive     = theme.dir_macos .. "/icons/titlebar/ontop_normal_inactive.png"
--
--theme.titlebar_sticky_button_focus_active       = theme.dir_macos .. "/icons/titlebar/sticky_focus_active.png"
--theme.titlebar_sticky_button_normal_active      = theme.dir_macos .. "/icons/titlebar/sticky_normal_active.png"
--theme.titlebar_sticky_button_focus_inactive     = theme.dir_macos .. "/icons/titlebar/sticky_focus_inactive.png"
--theme.titlebar_sticky_button_normal_inactive    = theme.dir_macos .. "/icons/titlebar/sticky_normal_inactive.png"
--
--theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active_blackburn.png"
----theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
--theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_focus_active_blackburn.png"
--theme.titlebar_floating_button_focus_inactive   = theme.dir_macos .. "/icons/titlebar/floating_focus_inactive.png"
--theme.titlebar_floating_button_normal_inactive  = theme.dir_macos .. "/icons/titlebar/floating_normal_inactive.png"
--
--theme.titlebar_maximized_button_focus_active    = theme.dir_macos .. "/icons/titlebar/maximized_focus_active.png"
--theme.titlebar_maximized_button_normal_active   = theme.dir_macos .. "/icons/titlebar/maximized_normal_active.png"
--theme.titlebar_maximized_button_focus_inactive  = theme.dir_macos .. "/icons/titlebar/maximized_focus_inactive.png"
--theme.titlebar_maximized_button_normal_inactive = theme.dir_macos .. "/icons/titlebar/maximized_normal_inactive.png"

-- OPTION 3

--theme.titlebar_close_button_focus               = theme.dir_macos .. "/icons/titlebar/close_focus.png"
--theme.titlebar_close_button_normal              = theme.dir_macos .. "/icons/titlebar/close_normal.png"

theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/mytitlebar/generated/maximized_active_focus.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/mytitlebar/generated/maximized_active_normal.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/mytitlebar/generated/maximized_inactive_focus.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/mytitlebar/generated/maximized_inactive_normal.png"

theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/mytitlebar/generated/ontop_active_focus.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/mytitlebar/generated/ontop_active_normal.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/mytitlebar/generated/ontop_inactive_focus.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/mytitlebar/generated/ontop_inactive_normal.png"

theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/mytitlebar/generated/sticky_active_focus.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/mytitlebar/generated/sticky_active_normal.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/mytitlebar/generated/sticky_inactive_focus.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/mytitlebar/generated/sticky_inactive_normal.png"

theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/mytitlebar/generated/floating_active_focus.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/mytitlebar/generated/floating_active_normal.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/mytitlebar/generated/floating_inactive_focus.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/mytitlebar/generated/floating_inactive_normal.png"

--theme.titlebar_maximized_button_focus_active    = theme.dir_macos .. "/icons/titlebar/maximized_focus_active.png"
--theme.titlebar_maximized_button_normal_active   = theme.dir_macos .. "/icons/titlebar/maximized_normal_active.png"
--theme.titlebar_maximized_button_focus_inactive  = theme.dir_macos .. "/icons/titlebar/maximized_focus_inactive.png"
--theme.titlebar_maximized_button_normal_inactive = theme.dir_macos .. "/icons/titlebar/maximized_normal_inactive.png"

-- END custom title bar icons

theme.taglist_buttons_hover                     = "#AD67CB"
theme.taglist_button_nohover                    = "#00000000"

theme.modality_box_bg                           = "#222222"
theme.modality_box_fg                           = "#ffffff"
theme.modality_box_border                       = theme.modality_box_bg
theme.modality_box_border_width                 = 10

-- --https://wowwiki.fandom.com/wiki/USERAPI_RGBToHex
-- local function RGBToHex(r, g, b)
-- 	r = r <= 255 and r >= 0 and r or 0
-- 	g = g <= 255 and g >= 0 and g or 0
--     b = b <= 255 and b >= 0 and b or 0
-- 	return string.format("%02x%02x%02x", r, g, b)
-- end

-- https://wowwiki.fandom.com/wiki/USERAPI_RGBPercToHex
local function RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("#%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

-- https://wowwiki.fandom.com/wiki/USERAPI_ColorGradient
local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num                    = select('#', ...) / 3

	local segment, relperc       = math.modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	if r1 > 1 then
		r1, g1, b1, r2, g2, b2 = r1 / 255, g1 / 255, b1 / 255, r2 / 255, g2 / 255, b2 / 255
	end

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

local function HexToRGBPerc(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16) / 255, tonumber(ghex, 16) / 255, tonumber(bhex, 16) / 255
end

local function h2rgb(x)
	return HexToRGBPerc(x)
end

local function BoundedRGBVal(low, high, val)
	if val > high then
		return high
	end
	if val < low then
		return low
	end
	return val
end

local clock = awful.widget.watch(
-- "date +'%a %d %b %R UTC%:::z'",
-- "date +'%a %d %b %R UTC%:::z'",
-- "date +'%Y-%m-%dT%H:%MZ%:z'",
-- "date +'%-m-%d %A %H:%M %:::z'",
-- "date +'%H:%M %a %Y-%m-%d %:::z'",
		"date +'%Y-%m-%d %A %H:%M%-:::z'", 60,
		function(widget, stdout)
			widget:set_markup(
			-- theme.font
					markup.fontbg("monospace bold 10", theme.clock_bg,
								  " " .. markup(theme.clock_fg, stdout:gsub("\n", "")) .. " ")
			)
		end)

special_log_load_time_reset()

local clock_time_only = awful.widget.watch("date +'%H:%M'", 60, function(widget, stdout)
	widget:set_markup(markup.fontbg("monospace bold 14", theme.clock_bg, " " .. markup(theme.clock_fg, stdout:gsub("\n", "")) .. " "))
end)

special_log_load_time("widget: clock_time_only")

-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local mem     = lain.widget.mem {
	settings = function()

		-- get base
		local r, g, b  = ColorGradient((mem_now.perc / 100), 52, 82, 201, 50, 171, 58, 207, 180, 29, 240, 24, 0)
		-- local bg_color = RGBPercToHex(r, g, b)

		r, g, b        = ColorGradient(0.6, r, g, b, 1, 1, 1) -- lighten it
		local fg_color = RGBPercToHex(r, g, b)

		r, g, b        = ColorGradient((mem_now.perc / 100), 52, 82, 201, 50, 171, 58, 207, 180, 29, 240, 24, 0)
		-- local bg_color = RGBPercToHex(r, g, b)

		r, g, b        = ColorGradient(0.8, r, g, b, 0, 0, 0)
		local bg_color = RGBPercToHex(r, g, b)

		local fmt      = string.format("%.0f GB", mem_now.used / 1024)
		widget:set_markup(markup.fontbg(theme.font, bg_color, " " .. markup(fg_color, fmt) .. " "))
		-- widget:set_markup(markup.font(theme.font, " " .. string.format("%.0f", mem_now.used / 1024) .. "GB "))
	end
}
special_log_load_time("widget: mem")

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu     = lain.widget.cpu {
	settings = function()
		-- widget:set_markup(markup.font(theme.font, " " .. string.format("%3d%%", cpu_now.usage)))
		local strf       = string.format("%3d%%", cpu_now.usage)

		local rr, gg, bb = ColorGradient((cpu_now.usage / 100), 52, 82, 201, 50, 171, 58, 207, 180, 29, 240, 24, 0)
		local r, g, b    = ColorGradient(0.6, rr, gg, bb, 0, 0, 0)
		local bg_color   = RGBPercToHex(r, g, b)

		r, g, b          = ColorGradient(0.6, rr, gg, bb, 0.8, 0.8, 0.8) -- lighten it
		local fg_color   = RGBPercToHex(r, g, b)
		if cpu_now.usage == 100 then
			fg_color = '#ff0000'
		end

		widget:set_markup(markup.fontbg(theme.font, bg_color, " " .. markup(fg_color, strf) .. " "))
		-- widget:set_markup(markup.font(theme.font, strf))
	end
}
special_log_load_time("widget: cpu")

-- Coretemp
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp     = lain.widget.temp {
	settings = function()
		-- want: 0.2 (cool), 0.5 (warm), 0.92 (hot)
		local min          = 33
		local max          = 110
		local range        = max - min

		local d            = coretemp_now - min
		local relativeHeat = d / range

		-- if relativeHeat < 0 then relativeHeat = 0 end
		-- if relativeHeat > 1 then relativeHeat = 1 end

		-- blue, green, yellow, red
		-- local blue, green, yellow, red = h2rgb("#3452c9"),   h2rgb("#32ab3a"),  h2rgb("#e8d031"),  h2rgb("#f01800")
		local r, g, b      = ColorGradient(relativeHeat, 52, 82, 201, 50, 171, 58, 207, 180, 29, 240, 24, 0)
		local bg_color     = RGBPercToHex(r, g, b)

		r, g, b            = ColorGradient(0.7, r, g, b, 0, 0, 0)
		local fg_color     = RGBPercToHex(r, g, b)

		-- local bg_color = RGBPercToHex(ColorGradient(relativeHeat,    blue, green, yellow, red))
		-- local fg_color = RGBPercToHex(ColorGradient(relativeHeat / 2,    blue, green, yellow, red))

		widget:set_markup(markup.fontbg(theme.font, bg_color, " " .. markup(fg_color, coretemp_now .. "°C") .. " "))
	end
}
special_log_load_time("widget: temp")

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_battery)
--local bat     = lain.widget.bat {
--	settings = function()
--		if bat_now.status ~= "N/A" then
--			if bat_now.ac_status == 1 then
--				widget:set_markup(markup.font(theme.font, " AC "))
--				baticon:set_image(theme.widget_ac)
--				return
--			elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
--				baticon:set_image(theme.widget_battery_empty)
--			elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
--				baticon:set_image(theme.widget_battery_low)
--			else
--				baticon:set_image(theme.widget_battery)
--			end
--			widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
--		else
--			widget:set_markup(markup.font(theme.font, " AC "))
--			baticon:set_image(theme.widget_ac)
--		end
--	end
--}

special_log_load_time("widget: bat")

-- ALSA microphone
--local micicon         = wibox.widget.imagebox()
theme.mic = lain.widget.alsa {
	channel  = "Capture",
	settings = function()
		-- if input_now.status == "on" then
		--     micicon:set_image(theme.widget_mic_on)
		--     -- micicon:set_image()
		--     widget:set_markup(markup.fontbg(theme.font, theme.color_red, markup("#ffffff", " ((( • On Air • ))) ")))

		-- elseif input_now.status == "off" then
		--     micicon:set_image(theme.widget_mic_off)
		--     -- #2a0054
		--     widget:set_markup(markup.fontbg(theme.font, "#2a0054", markup("#ffffff", " ((( • On Air • ))) ")))
		--     widget:set_markup(markup.font(theme.font, markup("#cfb1e0", " _ Off Air _ ")))
		--     -- widget:set_markup(markup.font(theme.font, " "))
		-- end
		--local words = " • On Air "
		local words = " • "
		local bg    = "#d93600" -- theme.color_red
		local fg    = "#fbff00"
		if volume_now.status == "off" then
			--words = " • Off Air " --✕
			words = " x " --✕
			bg    = "#3b383e" -- "#370e5c"
			fg    = "#887b94"
		end
		widget:set_markup(markup.fontbg(theme.font, bg, markup(fg, words)))
	end
}
special_log_load_time("widget: mic")

-- ALSA volume
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume  = lain.widget.alsa {
	settings = function()
		if not volume_now then
			return
		end

		if volume_now.status == "off" then
			volicon:set_image(theme.widget_vol_mute)
		elseif tonumber(volume_now.level) == 0 then
			volicon:set_image(theme.widget_vol_no)
		elseif tonumber(volume_now.level) <= 50 then
			volicon:set_image(theme.widget_vol_low)
		else
			volicon:set_image(theme.widget_vol)
		end

		widget:set_markup(markup.font(theme.font, " " .. volume_now.level .. "% "))
	end
}
special_log_load_time("widget: volume")

special_log_load_time("widget: net")

local mysystray = wibox.widget.systray()
special_log_load_time("widget: systray")


--local mygithubwidget  = lain.widget.mywidget({
--												 TOKEN       = os_getenv("GITHUB_MEOWSBITS_PERSONAL"),
--												 name        = "Github Notifications",
--												 labelprefix = "meowsbits: ",
--												 timeout     = 60 * 2,
--											 })
--local mygithubwidget2 = lain.widget.mywidget({
--												 TOKEN       = os_getenv("GITHUB_WHILEI_PERSONAL"),
--												 name        = "Github Notifications",
--												 labelprefix = "whilei: ",
--												 timeout     = 60 * 2,
--											 })

--local function set_random_wallpaper()
--    local wallpaper_path = theme.dir .. "walls"
--    local wallpaper = wallpaper_path .. "/" .. gears.filesystem.get_random_file_from_dir(wallpaper_path, {"jpg", "png", "bmp"})
--    gears.wallpaper.maximized(wallpaper, nil, false)
--end
--
--gears.timer {timeout = 6, call_now = true, autostart = true, callback = set_random_wallpaper}
--
--screen.connect_signal("request::wallpaper", set_random_wallpaper)

-- Separators
local spr = wibox.widget.textbox(" ")

--local client_props_widget = wibox.widget.textbox("hello world")
--client.connect_signal("focus", function(c)
--	if not c then return end
--
--	local w   = client_props_widget
--	local geo = c:geometry()
--
--	local t   = "" ..
--			(c.floating and " floating " or "") ..
--			(c.ontop and " ontop " or "") ..
--			(c.maximized and " Z " or "") ..
--			(c.sticky and " sticky " or "") ..
--			(c.fullscreen and " fullscreen " or "") ..
--			(c.hidden and " hidden " or "") ..
--			geo.width .. "x" .. geo.height ..
--			""
--
--	w:set_text(t)
--end)

function theme.at_screen_connect(s)


	--s.client_focused_props_widget = client_props_widget

	local bat = battery_widget {
		--screen             = s,
		instant_update     = true, -- default=false
		use_display_device = true,
		widget_template    = wibox.widget.textbox,
	}
	bat:connect_signal("upower::update", function(widget, device)
		widget.text = string.format('%3d', device.percentage) .. '%'
	end)

	special_log_load_time_reset()

	if s.geometry.width > 3000 then
		s.is_tv = true
	else
		s.is_tv = false
	end
	if s.is_tv then
		-- Add padding on the left because I the TV
		-- is both hard to see over there and has a weird
		-- refraction thing going on.
		-- I want to do the same for the wibar, but screen.padding
		-- skips the wibar, so I have to do it with a margin within the wibar.
		s.padding = { left = 5, right = 5 }
	end

	-- Hide Handy clients on screen connect;
	-- otherwise they show up (on top) when I restart Awesome.
	-- TODO Move this to rules.
	for _, cl in ipairs(s.clients) do
		if cl:get_xproperty("handy_id") ~= "" then
			cl.visible = false
		end
	end

	special_log_load_time("hide handy clients")

	-- If wallpaper is a function, call it with the screen
	special_log_load_time_reset()
	--local wallpaper = theme.wallpaper
	--if type(wallpaper) == "function" then
	--	wallpaper = wallpaper(s)
	--end
	--gears.wallpaper.maximized(wallpaper, s, false)
	--awful.wallpaper {
	--	screen = s,
	--	widget = {
	--		{
	--			image  = wallpaper,
	--			resize = true,
	--			widget = wibox.widget.imagebox,
	--		},
	--		valign = "center",
	--		halign = "center",
	--		widget = wibox.container.place,
	--	},
	--}

	--special_log_load_time("wallpaper")

	-- Tags
	-- I want to define names for the tags that differ by screen, eg.
	-- A1 => screen 1 (A), tag 1
	-- B3 => screen 2 (B), tag 3
	-- This helps with rofi, because it shows the tag name when selecting
	-- clients, and its nice to know where rofi is going to go in case there
	-- are clients with instances on multiple screens.
	-- So now, with Rofi, I can see 'A3' and know that its over on screen A, tag 3.
	local my_tags      = {
		tags = {
			{
				-- "L" is for Laptop.
				names   = { "L:1", "L:2", "L:3", "L:4", "L:5" },
				layouts = {
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.suit.floating, -- 5th tag is floating by default
				},
			},
			{
				-- "TV" is for TV.
				names   = { "TV:1", "TV:2", "TV:3", "TV:4", "TV:5" },
				layouts = {
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.suit.floating, -- 5th tag is floating by default
				},
			},
			{
				names   = { "C1", "C2", "C3", "C4", "C5" },
				layouts = {
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.suit.floating, -- 5th tag is floating by default
				},
			},
			{
				names   = { "D1", "D2", "D3", "D4", "D5" },
				layouts = {
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.suit.floating, -- 5th tag is floating by default
				},
			},
			{
				names   = { "E1", "E2", "E3", "E4", "E5" },
				layouts = {
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.layouts[1],
					awful.layout.suit.floating, -- 5th tag is floating by default
				},
			}
			-- I'm never going to have more than 5 screens connected.
		}
	}
	local screen_index = s.index
	awful.tag(my_tags.tags[screen_index].names, s, my_tags.tags[screen_index].layouts)

	special_log_load_time("tags")

	-- This is the default tag assignment boilerplate, which
	-- uses the awful.util.tagnames assignment defined in rc.lua.
	-- awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	-- This is only used by default library stuff,
	-- like renaming tags.
	-- For stuff like launching applications,
	-- I have a custom prompt box that gets handled with a keybinding.
	s.mypromptbox = awful.widget.prompt({
											prompt    = "> ",
											bg        = "#0000ff", -- "#1E2CEE", -- "#000000",
											fg        = "#ffffff",
											bg_cursor = "#e019c9", --pink
											fg_cursor = "#e019c9", --pink
											--textbox = my_promptbox_textbox,
										})
	
	special_log_load_time("widget: promptbox")

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox { screen = s }
	special_log_load_time("widget: layoutbox")

	-- I think this is assigning buttons to keystrokes
	-- awful.button:new (mod, _button, press, release)
	-- https://awesomewm.org/doc/api/classes/awful.button.html
	-- Update: Yea, looks like so. The buttons its assigning (1,3,4,5) are MOUSE buttons
	-- and they work as expected:
	--   left mouse button (1): move forward
	--   right mouse button (3): move backward
	s.mylayoutbox:buttons(my_table.join(
			awful.button({ }, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({ }, 3, function()
				awful.layout.inc(-1)
			end),
			awful.button({ }, 4, function()
				awful.layout.inc(1)
			end),
			awful.button({ }, 5, function()
				awful.layout.inc(-1)
			end)))

	---- Create a taglist widget
	--s.mytaglist = awful.widget.taglist(
	--		s,
	--		awful.widget.taglist.filter.all,
	--		awful.util.taglist_buttons,
	--		{
	--			-- style
	--			--fg_focus = "#3846c7", -- theme.color_lightblue, -- theme.tasklist_bg_focus,
	--			fg_occupied = "#666666", -- "#777777",
	--			fg_empty    = "#222222",
	--
	--			bg_focus    = "#00000000",
	--			bg_urgent   = "#00000000",
	--			bg_occupied = "#00000000",
	--			bg_empty    = "#00000000",
	--			bg_volatile = "#00000000",
	--			--taglist_squares_sel
	--		}
	--)

	local function taglist_create_update(self, tag, index, tags)
		local tag_occupied = #tag:clients() > 0
		if tag_occupied and tag.selected then
			self:get_children_by_id("inner_background_role")[1].border_width = 1
			self:get_children_by_id("inner_background_role")[1].border_color = theme.fg_focus
			self:get_children_by_id("text_background_role")[1].bg            = "#142924"
		elseif tag_occupied then
			self:get_children_by_id("inner_background_role")[1].border_width = 1
			self:get_children_by_id("inner_background_role")[1].border_color = "#666666"
			self:get_children_by_id("inner_background_role")[1].bg           = "#000000"
			self:get_children_by_id("text_background_role")[1].bg            = "#00000000"
		else
			self:get_children_by_id("inner_background_role")[1].border_width = 0
			self:get_children_by_id("inner_background_role")[1].bg           = "#000000"
			self:get_children_by_id("text_background_role")[1].bg            = "#000000"
		end

		if not tag_occupied then
			self:get_children_by_id("outer_margin_role")[1].right = 0
		else
			self:get_children_by_id("outer_margin_role")[1].right = 5
		end

		self:get_children_by_id("client_icons_role")[1]:reset()
		local icons = {}

		for _, cl in ipairs(tag:clients()) do
			-- Exclude clients with a 'handy_id'.
			-- These are client created via the Handy module,
			-- which is intended to be HUD/Quake style dropdown/on-demand
			-- application window.
			-- Update: I've now also added a condition against clients with the 'skip_taglist' property.
			-- I just made this property up (it doesn't exist in the default AwesomeWM codebase),
			-- and its useful for excluding clients like Quake from the taglist on (re-)startup.
			if not cl.skip_taglist and (not cl:get_xproperty("handy_id") or cl:get_xproperty("handy_id") == "")
			then
				local icon = wibox.widget {
					{
						id     = "icon_container",
						{
							id     = "icon",
							resize = true,
							widget = wibox.widget.imagebox
						},
						widget = wibox.container.place
					},
					forced_width = dpi(18),
					--forced_height = dpi(10),
					left         = dpi(3),
					right        = dpi(6),
					widget       = wibox.container.margin
				}
				icon.icon_container.icon:set_image(cl.icon)
				table.insert(icons, icon)
			end
		end

		---- An experiment in having the tag list entry show the client name (a shortened version)
		---- when there is only one client in the tag. (Instead of the tag name, eg. B3).
		--if #tag:clients() == 1 then
		--	local cl          = tag:clients()[1]
		--	local first_space = cl.name:find(" ")
		--	if first_space then
		--		local short_name = cmd:sub(1, first_space)
		--		self:get_children_by_id("text_role")[1]:set_markup_silently("<span>" .. short_name .. "</span>")
		--	end
		--else
		--	-- reset text_role to normal
		--end

		self:get_children_by_id("client_icons_role")[1].children = icons
	end

	s.mytaglist = awful.widget.taglist {
		screen          = s,
		filter          = awful.widget.taglist.filter.all,
		buttons         = awful.util.taglist_buttons,
		style           = {
			--fg_occupied = "#666666", -- "#777777",
			fg_occupied = "#ffffff", -- "#777777",
			fg_focus    = theme.fg_focus,
			--fg_empty    = "#222222",
			-- Use same as occupied because
			-- now I have a border doing the job of telling me if a tag is empty
			-- or occupied.
			--fg_empty    = "#666666",

			bg_focus    = "#00000000",
			bg_urgent   = "#ff0000",
			bg_occupied = "#00000000",
			bg_empty    = "#00000000",
			bg_volatile = "#00000000",
		},
		layout          = wibox.layout.fixed.horizontal,
		widget_template = {
			{
				{
					{
						{
							id     = "index_role",
							widget = wibox.widget.textbox,
						},
						{
							id     = "icon_role",
							widget = wibox.widget.imagebox,
						},
						{
							{
								{
									id     = "text_role",
									widget = wibox.widget.textbox,
								},
								left   = 10,
								right  = 10,
								widget = wibox.container.margin,
							},
							id     = "text_background_role",
							--bg     = "#222222",
							--shape  = gears.shape.rectangle,
							widget = wibox.container.background,
						},
						{
							{
								id     = "client_icons_role",
								widget = wibox.layout.fixed.horizontal,
							},
							widget = wibox.container.margin,
							left   = 3,
							right  = 3,
							top    = dpi(2),
							bottom = dpi(2),
						},
						layout = wibox.layout.fixed.horizontal,
					},
					id     = "inner_background_role",
					widget = wibox.container.background,
					shape  = function(cr, width, height)
						return gears.shape.rounded_rect(cr, width, height, height / 10)
					end,
					--border_width = 1,
					--border_color = theme.fg_focus,
				},
				id     = "outer_margin_role",
				left   = 0,
				right  = 10,
				widget = wibox.container.margin
			},
			id              = "background_role",
			widget          = wibox.container.background,

			-- https://awesomewm.org/apidoc/widgets/awful.widget.taglist.html
			create_callback = taglist_create_update,
			update_callback = taglist_create_update,
		},
	}

	--- Common update method.
	-- @param w The widget.
	-- @tab buttons
	-- @func label Function to generate label parameters from an object.
	--   The function gets passed an object from `objects`, and
	--   has to return `text`, `bg`, `bg_image`, `icon`.
	-- @tab data Current data/cache, indexed by objects.
	-- @tab objects Objects to be displayed / updated.
	local function my_common_tasklist_updater(w, buttons, label, data, objects)
		-- update the widgets, creating them if needed
		w:reset()
		for i, o in ipairs(objects) do
			local cache = data[o]
			local ib, tb, bgb, tbm, ibm, l
			--local ib, bgb, tbm, ibm, l
			if cache then
				ib  = cache.ib
				tb  = cache.tb
				bgb = cache.bgb
				tbm = cache.tbm
				ibm = cache.ibm
			else
				ib  = wibox.widget.imagebox()
				tb  = wibox.widget.textbox()
				bgb = wibox.container.background()
				tbm = wibox.container.margin(tb, dpi(4), dpi(4))
				ibm = wibox.container.margin(ib, dpi(4))
				l   = wibox.layout.fixed.horizontal()

				-- All of this is added in a fixed widget
				l:fill_space(true)
				l:add(ibm)
				l:add(tbm)

				-- And all of this gets a background
				bgb:set_widget(l)

				bgb:buttons(common.create_buttons(buttons, o))

				data[o] = {
					ib  = ib,
					tb  = tb,
					bgb = bgb,
					tbm = tbm,
					ibm = ibm,
				}
			end

			local text, bg, bg_image, icon, args = label(o, tb)
			args                                 = args or {}

			-- IA
			-- This is my special additional
			-- to REMOVE TEXT (LEAVING ONLY ICON)
			-- if the task does indeed have an icon.
			if icon then
				text = ""
			end

			-- The text might be invalid, so use pcall.
			local no_text = text == nil or text == ""
			if no_text then
				tbm:set_margins(0)
			else
				tbm:set_margins({
									left   = dpi(2),
									right  = dpi(8),
									top    = dpi(2),
									bottom = dpi(2),
								})
				if not tb:set_markup_silently(text) then
					tb:set_markup("<i>&lt;Invalid text&gt;</i>")
				end
			end
			--tb:set_markup(" ")
			bgb:set_bg(bg)
			if type(bg_image) == "function" then
				-- TODO: Why does this pass nil as an argument?
				bg_image = bg_image(tb, o, nil, objects, i)
			end
			bgb:set_bgimage(bg_image)
			if icon then
				ib:set_image(icon)
			else
				ibm:set_margins(dpi(4))
			end
			ibm:set_margins({
								left   = dpi(8),
								right  = no_text and dpi(8) or dpi(4),
								top    = dpi(4),
								bottom = dpi(4),
							})

			bgb.shape = args.shape or function(cc, ww, hh)
				gears.shape.rounded_rect(cc, ww, hh, hh / 2)
			end
			if not o.floating then
				bgb.shape = function(cc, ww, hh)
					gears.shape.rounded_rect(cc, ww, hh, hh / 10)
				end
			end
			bgb.border_width = args.border_width
			bgb.border_color = args.border_color

			local bgbm       = wibox.container.margin(bgb, dpi(4), dpi(0))
			w:add(bgbm)
		end
	end

	-- Create a tasklist widget
	local function my_tasklist_updater(w, buttons, label, data, objects)
		--common.list_update(w, buttons, label, data, objects)
		my_common_tasklist_updater(w, buttons, label, data, objects)
		if not s.is_tv then
			w:set_max_widget_size(200)
		end

	end

	-- awful.widget.tasklist()
	s.mytasklist       = awful.widget.tasklist {
		screen          = s, -- screen
		filter          = awful.widget.tasklist.filter.currenttags, -- filter
		buttons         = awful.util.tasklist_buttons, -- buttons
		style           = nil,
		update_function = my_tasklist_updater,
		--create_callback = my_tasklist_updater,
		--update_callback = my_tasklist_updater, -- update function
	}


	-- Create the wibox
	local mywibar_args = {
		position          = "top", -- top, bottom
		screen            = s,
		height            = 18,
		bg                = theme.bg_normal .. "00",
		fg                = theme.fg_normal,
		opacity           = 1,
		visible           = true,
		restrict_workarea = true, -- Allow or deny the tiled client to cover the wibar.
		margins           = { left = 0, right = 0, top = 0, bottom = dpi(5) },
	}

	if s.is_tv then
		mywibar_args.position = "top"
		mywibar_args.height   = 24
		mywibar_args.width    = s.workarea.width / 3 * 2
	end

	s.mywibox            = awful.wibar(mywibar_args)

	--s.mywibox_tasks = awful.wibar {
	--	position          = "bottom",
	--	type              = "toolbar", -- https://awesomewm.org/apidoc/core_components/client.html#type
	--	screen            = s,
	--	height            = 24,
	--	bg                = "#00000000",
	--	fg                = "#ffffff",
	--	opacity           = 0.8,
	--	visible           = true,
	--	restrict_workarea = false, -- Allow or deny the tiled client to cover the wibar.
	--	ontop             = true,
	--	input_passthrough = true,
	--	margins           = { left = 0, right = 0, bottom = dpi(5), top = 0 },
	--}
	--s.mywibox_tasks:setup {
	--	layout = wibox.layout.align.horizontal,
	--	expand = "outside",
	--	wibox.widget.textbox(""),
	--	{
	--		layout = wibox.layout.fixed.horizontal,
	--        s.mytasklist,
	--	},
	--	wibox.widget.textbox(""),
	--}

	-- The important part to make this actually float on top of all the stuff is
	-- that it's a WIBOX and a not a WIBAR.
	-- It's also NOT an awful.wibox, but just a wibox. These are important things.
	--[[
		 --position          = mywibar_args.position,
		 --screen            = s,
		 --height            = mywibar_args.height,
		 --width             = 500,
		 --bg                = nil,
		 --restrict_workarea = false,
		 --stretch           = false,
		 --visible           = not s.mywibox.visible,
		 --ontop             = true,
		 ----type              = "dock",
		 ----Valid types are:
		 ----
		 ----desktop: The root client, it cannot be moved or resized.
		 ----dock: A client attached to the side of the screen.
		 ----splash: A client, usually without titlebar shown when an application starts.
		 ----dialog: A dialog, see transient_for.
		 ----menu: A context menu.
		 ----toolbar: A floating toolbar.
		 ----utility:
		 ----dropdown_menu: A context menu attached to a parent position.
		 ----popup_menu: A context menu.
		 ----notification: A notification popup.
		 ----combo: A combobox list menu.
		 ----dnd: A drag and drop indicator.
		 ----normal: A normal application main window.
	--]]
	--s.mywibox_slim       = awful.popup {
	--	widget = {
	--		{
	--			{
	--				s.mypromptbox,
	--				spr,
	--
	--				s.mytaglist,
	--				spr,
	--
	--				s.mylayoutbox,
	--				spr,
	--
	--				clock_time_only,
	--				layout = wibox.layout.fixed.horizontal,
	--			},
	--			margins = 10,
	--			widget  = wibox.container.margin
	--		},
	--		border_color = "#00ff00",
	--		border_width = 5,
	--		screen       = s,
	--		placement    = awful.placement.bottom,
	--		shape        = gears.shape.rounded_rect,
	--		visible      = true,
	--		height       = 24,
	--		width        = 500,
	--		ontop        = true,
	--		type         = "dock",
	--	}
	--}

	--client.connect_signal("focus", function(c)
	--	if c.screen == s then
	--		s.mywibox_slim.border_width = 2
	--	else
	--		s.mywibox_slim.border_width = 0
	--	end
	--end)

	s.mywibox_worldtimes = special.meridian(s, theme)

	s.indicators         = {
		config    = {
			icons  = {
				focused   = gears.filesystem.get_configuration_dir() .. 'awesome-buttons/icons/eye.svg',
				unfocused = gears.filesystem.get_configuration_dir() .. 'awesome-buttons/icons/eye-off.svg',
			},
			colors = {
				focused   = "#1B8A23",
				unfocused = "#000000",
			}
		},
		set_state = function(self, focused)
			if focused then
				self.widget:get_children_by_id('icon')[1]:set_image(self.config.icons.focused)
				self.widget:get_children_by_id('background')[1]:set_bg(self.config.colors.focused)
			else
				self.widget:get_children_by_id('icon')[1]:set_image(self.config.icons.unfocused)
				self.widget:get_children_by_id('background')[1]:set_bg(self.config.colors.unfocused)
			end
		end,
		widget    = wibox.widget {
			{
				{
					{
						{
							id     = 'icon',
							image  = gears.filesystem.get_configuration_dir() .. 'awesome-buttons/icons/eye-off.svg',
							resize = true,
							widget = wibox.widget.imagebox,
						},
						left   = 4,
						right  = 4,
						top    = 2,
						bottom = 2,
						widget = wibox.container.margin,
					},
					valign  = 'center',
					halign  = 'center',
					margins = 2,
					widget  = wibox.container.place,
				},
				id     = 'background',
				bg     = "#222222",
				shape  = function(c, w, h)
					return gears.shape.rounded_rect(c, w, h, 2)
				end,
				widget = wibox.container.background,
			},
			margins = 4,
			widget  = wibox.container.margin,
		},
	}

	-- This works but its overkill.
	-- There are often several clients shifting focus on a sceen and/or tag,
	-- so this is called redundantly.
	-- I want to connect to signal for only when the focused screen (best) or tag (better) changes.
	client.connect_signal("focus", function(c)
		s.indicators:set_state(c.screen and c.screen == s)
	end)
	-- But these are ineffectual:
	--tag.connect_signal("request::select", function(t)
	--tag.connect_signal("property::selected", function(t)
	--	s.indicators:set_state(t.screen and t.screen == s)
	--end)

	s.mywibox_slim = awful.popup {
		widget       = {
			{
				{
					--s.indicators.widget,
					s.mypromptbox,
					s.mytaglist,
					clock_time_only,
					layout = wibox.layout.fixed.horizontal,
				},
				margins = 0,
				widget  = wibox.container.margin,
			},
			forced_height = 24,
			widget        = wibox.container.constraint
		},
		screen       = s,
		type         = "dock",
		placement    = awful.placement.bottom,
		shape        = function(c, w, h)
			local tl, tr, br, bl = true, true, false, false
			return gears.shape.partially_rounded_rect(c, w, h, tl, tr, br, bl, h / 3)
		end,
		visible      = false,
		ontop        = true,
		border_width = 0,
		border_color = "#0000ff",
	}

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,

			s.indicators.widget,

			spr,
			s.mylayoutbox,
			spr,

			s.mytaglist,
			spr,
			s.mypromptbox,
			spr,

		},

		-- middle
		s.mytasklist,
		--{
		--	layout = wibox.layout.fixed.horizontal,
		--expand = "outside",
		--spr,
		--spr,
		--},

		-- Right widgets
		{
			layout = wibox.layout.fixed.horizontal,

			s.client_focused_props_widget,

			mysystray,

			-- Net up/down
			spr,

			-- CPU
			spr,
			cpuicon,
			cpu.widget,

			-- Memory
			memicon,
			mem.widget,

			-- Battery
			spr,
			baticon,
			bat,

			-- Filesytem
			--spr,
			--fsicon,
			--theme.fs.widget,

			-- Volume
			spr,
			volicon,
			theme.volume.widget,

			-- Clock
			spr,
			clock,

			-- Microphone
			spr,
			theme.mic.widget,

			-- Temperature
			spr,
			temp.widget,
		},
	}
end

return theme
