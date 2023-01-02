local io        = io

local awful     = require("awful")
local beautiful = require("beautiful")
local lain      = require("lain")
local special   = require("special")
local wibox     = require("wibox")
local markup    = lain.util.markup

local m         = {}

local spr       = wibox.widget.textbox(" ")


-- IP Locale
local locale    = wibox.widget.textbox()
local line      = "unknown"
local file      = io.open("/home/ia/ipinfo.io/locale", "r")
line            = file:read()
file:close()
locale:set_markup(markup.font(beautiful.font, "" .. line .. ""))


-- Net Up/Down

-- Net
local net_widget = wibox.widget {
	layout = wibox.layout.align.horizontal,
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

m.init    = function(s)
	m.bar = awful.popup {
		screen       = s,
		placement    = awful.placement.centered,
		visible      = true,
		ontop        = true,
		border_width = 1,
		border_color = "#ff0000",
		widget       = {
			widget  = wibox.container.margin,
			margins = 10,
			{
				layout = wibox.layout.fixed.vertical,
				--expand = "outside",
				special.weather.dash_forecast,
				locale,
				net.widget,
			},
		},

	}
end

return m