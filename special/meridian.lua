local awful     = require("awful")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local gears     = require("gears")
local markup    = require("lain.util.markup")
local wibox     = require("wibox")

return function(s, theme)
	--if theme == nil then
	--	theme = require("beautiful")
	--end

	local meridian_fmt            = "%H:%M%t%z"
	local meridian                = function(tz)
		local watcher = "bash -c 'TZ='" .. tz .. "' date +'%H:%M''"
		if tz == "UTC" then
			watcher = "date -u +'" .. meridian_fmt .. "'"
		end
		return awful.widget.watch(watcher, 60, function(widget, stdout)
			-- markup.fontbg("monospace bold 12", theme.clock_bg, " " .. markup(theme.clock_fg, stdout:gsub("\n", "")) .. " ")
			widget:set_markup(markup.fontbg("monospace bold 12", theme.clock_bg, " " .. markup(theme.clock_fg, stdout:gsub("\n", "")) .. " "))
		end)
	end
	local world_clock_vancouver   = meridian("America/Vancouver")
	local world_clock_denver      = meridian("America/Denver")
	local world_clock_chicago     = meridian("America/Chicago")
	local world_clock_newyork     = meridian("America/New_York")
	local clock_utc               = meridian("UTC")
	local world_clock_london      = meridian("Europe/London")
	local world_clock_berlin      = meridian("Europe/Berlin")
	local world_clock_athens      = meridian("Europe/Athens")
	local world_clock_dubai       = meridian("Asia/Dubai")
	local world_clock_shanghai    = meridian("Asia/Shanghai")
	local world_clock_tokyo       = meridian("Asia/Tokyo")
	local world_clock_buenosaires = meridian("America/Argentina")
	local world_clock_madrid      = meridian("Europe/Madrid")
	local world_clock_anchorage   = meridian("America/Anchorage")
	local world_clock_moscow      = meridian("Europe/Moscow")

	local spr                     = wibox.widget.textbox(" ")

	return awful.popup {
		screen            = s,
		placement         = awful.placement.bottom,
		type              = "dock",
		visible           = false,
		ontop             = true,
		input_passthrough = true,
		shape             = function(c, w, h)
			local tl, tr, br, bl = true, true, false, false
			return gears.shape.partially_rounded_rect(c, w, h, tl, tr, br, bl, h / 3)
		end,
		border_width      = s.is_tv and dpi(4) or dpi(1),
		border_color      = theme.clock_fg,
		widget            = {
			widget = wibox.container.margin,
			top    = 4, left = 4, right = 4,
			{
				layout = wibox.layout.align.horizontal,
				-- left
				{
					layout = wibox.layout.flex.horizontal,
					spr,
				},
				{
					layout = wibox.layout.flex.horizontal,
					{
						{
							wibox.widget.textbox(markup.fontbg("Roboto 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Anchorage'))),
							world_clock_anchorage,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Seattle'))),
							world_clock_vancouver,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Denver'))),
							world_clock_denver,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Chicago'))),
							world_clock_chicago,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'New York'))),
							world_clock_newyork,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Buenos Aires'))),
							world_clock_buenosaires,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'UTC'))),
							clock_utc,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'London'))),
							world_clock_london,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Berlin'))),
							world_clock_berlin,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					--{
					--	{
					--		wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Madrid (CET/CEST)'))),
					--		world_clock_madrid,
					--		layout = wibox.layout.fixed.vertical,
					--	},
					--	widget  = wibox.container.margin,
					--	margins = s.is_tv and 10 or 5,
					--},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Athens,Kiev'))),
							world_clock_athens,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Moscow'))),
							world_clock_moscow,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Dubai'))),
							world_clock_dubai,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Shanghai'))),
							world_clock_shanghai,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					{
						{
							wibox.widget.textbox(markup.fontbg("monospace 8", theme.bg_normal, " " .. markup(theme.clock_fg, 'Tokyo'))),
							world_clock_tokyo,
							layout = wibox.layout.fixed.vertical,
						},
						widget  = wibox.container.margin,
						margins = s.is_tv and 10 or 5,
					},
					--{
					--	{
					--		{
					--			layout = wibox.layout.fixed.horizontal,
					--			mygithubwidget.icon,
					--			spr,
					--			mygithubwidget.widget,
					--		},
					--		{
					--			layout = wibox.layout.fixed.horizontal,
					--			mygithubwidget2.icon,
					--			spr,
					--			mygithubwidget2.widget,
					--		},
					--		layout = wibox.layout.fixed.vertical,
					--	},
					--	widget  = wibox.container.margin,
					--	margins = 10,
					--},
				},
				{
					layout = wibox.layout.flex.horizontal,
					spr,
				},
			},
		}
	}
end

