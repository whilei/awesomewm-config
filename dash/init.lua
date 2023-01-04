local io                    = io

local awful                 = require("awful")
local beautiful             = require("beautiful")
local gears                 = require("gears")
local lain                  = require("lain")
local special               = require("special")
local wibox                 = require("wibox")
local markup                = lain.util.markup
local special_log_load_time = require("special").log_load_time
local calendar_widget       = require("awesome-wm-widgets.calendar-widget.calendar")

local m                     = {}

local spr                   = wibox.widget.textbox(" ")


-- IP Locale
local locale                = wibox.widget.textbox()
local line                  = "unknown"
local file                  = io.open("/home/ia/ipinfo.io/locale", "r")
line                        = file:read()
file:close()
locale:set_markup(markup.font(beautiful.font, "" .. line .. ""))

special_log_load_time("widget: ip locale")

-- Net Up/Down

-- Net
local net_widget = wibox.widget {
	layout  = wibox.layout.fixed.horizontal,
	expand  = "none",
	spacing = 10,
	{
		{
			id     = 'up',
			widget = wibox.widget.textbox,
		},
		widget = wibox.container.background,
		--top    = 4,
	},
	wibox.widget.textbox(" ⇅ "),
	{
		{
			id     = 'dn',
			widget = wibox.widget.textbox,
		},
		widget = wibox.container.background,
		--top    = 4,
	},
}

-- Credit: https://github.com/xtao/ntopng/blob/master/scripts/lua/modules/lua_utils.lua
function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
-- Convert bits to human readable format
local function bitsToSize(bits)
	if type(bits) == "string" then
		bits = tonumber(bits)
	end
	precision = 0
	kilobit   = 1024;
	megabit   = kilobit * 1024;
	gigabit   = megabit * 1024;
	terabit   = gigabit * 1024;

	if ((bits >= kilobit) and (bits < megabit)) then
		return round(bits / kilobit, precision), 'Kb/s';
	elseif ((bits >= megabit) and (bits < gigabit)) then
		precision = 2
		return round(bits / megabit, precision), 'Mb/s';
	elseif ((bits >= gigabit) and (bits < terabit)) then
		precision = 2
		return round(bits / gigabit, precision), 'Gb/s';
	elseif (bits >= terabit) then
		precision = 2
		return round(bits / terabit, precision), 'Tb/s';
	else
		return round(bits, precision), 'b/s';
	end
end

local net = lain.widget.net {
	widget   = net_widget,
	units    = 1, -- in bits
	settings = function()
		-- 🠉 🠋 ↥ ⇅

		local n_bits, units_str = bitsToSize(net_now.sent)
		widget:get_children_by_id("up")[1]:set_markup(markup.font(beautiful.font,
																  markup("#fcc9ff",
																		 "" .. tostring(n_bits) ..
																				 "" ..
																				 markup.font(beautiful.font_small, units_str))))

		n_bits, units_str = bitsToSize(net_now.received)
		widget:get_children_by_id("dn")[1]:set_markup(markup.font(beautiful.font,
																  markup("#2ECCFA",
																		 "" .. tostring(n_bits) ..
																				 "" ..
																				 markup.font(beautiful.font_small, units_str))))

	end
}

special_log_load_time("widget: net")


-- FS
local fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
local fs     = lain.widget.fs {
	notification_preset = { fg = beautiful.fg_normal, bg = beautiful.bg_normal, font = "xos4 Terminus 10" },
	settings            = function()
		widget:set_markup(markup.font(beautiful.font, " " .. fs_now["/"].percentage .. "% "))
	end
}

special_log_load_time("widget: fs")

-- acalendar is going to hold a calendar widget shared between all screens.
local calendar = calendar_widget {
	theme                 = "dark",
	--placement = 'bottom_right',
	--start_sunday = true,
	--radius = 8,
	-- with customized next/previous (see table above)
	previous_month_button = 1,
	next_month_button     = 3,
	placement             = "centered",
	shape                 = gears.shape.rounded_rect,
}

special_log_load_time("widget: calendar")

m.init = function()
	m.bar = awful.popup {
		--screen       = s,
		placement    = awful.placement.centered,
		--placement    = function(c)
		--	return awful.placement.top_right(c, {
		--		honor_workarea = true,
		--		honor_padding  = false,
		--		margins        = {
		--			top   = 20,
		--			right = 20,
		--		}
		--	})
		--end,
		visible      = false,
		ontop        = true,
		border_width = 0,
		border_color = "#B8BFD6",
		shape        = gears.shape.rounded_rect,
		bg           = "#00000099",
		widget       = {
			widget = wibox.container.background,
			bg     = "#00000099",
			{
				widget  = wibox.container.margin,
				margins = 20,
				{
					layout                 = wibox.layout.grid,
					--forced_num_rows        = 5,
					forced_num_cols        = 1,
					--homogeneous     = true,
					horizontal_homogeneous = true,
					vertical_homogeneous   = false,
					--expand          = true,
					spacing                = 10,

					{
						layout = wibox.layout.align.horizontal,
						expand = "outside",
						nil,
						{
							layout = wibox.layout.fixed.horizontal,
							{
								widget = wibox.container.constraint,
								width  = 64,
								special.weather.icon,
							},
							special.weather.widget,
							nil,
						},
						nil,
					},
					special.weather.dash_forecast,
					{
						widget = wibox.container.place,
						valign = "center",
						halign = "center",
						calendar,
					},
					{
						widget = wibox.container.place,
						valign = "center",
						halign = "center",
						{
							widget = wibox.container.constraint,
							width  = 512,
							wibox.widget {
								widget     = wibox.widget.imagebox,
								image      = "/tmp/gcdw1_hg.png",
								clip_shape = gears.shape.rounded_rect,
							},
						},
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = "outside",
						nil,
						{
							layout     = wibox.layout.fixed.horizontal,
							fill_space = true,
							{
								widget = wibox.container.constraint,
								width  = 32,
								wibox.widget.imagebox(beautiful.widget_net),
							},
							wibox.widget.textbox("IP Location: "),
							locale,
						},
						nil,
					},
					{
						widget   = wibox.container.place,
						valign   = "center",
						halign   = "center",
						children = { net.widget, },
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = "outside",
						nil,
						{
							layout = wibox.layout.fixed.horizontal,
							{
								widget = wibox.container.constraint,
								width  = 32,
								wibox.widget.imagebox(beautiful.widget_hdd),
							},
							fs.widget,
							nil,
						},
						nil,
					},
				},
			},
		}

	}
	return m
end

local function show(s)
	if not m.bar then m.init() end
	m.bar.screen  = s
	m.bar.visible = true
end

local function hide()
	m.bar.visible = false
end

screen.connect_signal("request::dash::toggle", function(s)
	if m.bar and m.bar.visible then
		hide()
	else
		show(s)
	end
end)

return m