local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local quake     = require("lain").util.quake
local weather   = require("special.weather")
local markup    = lain.util.markup

local tonumber  = tonumber
local os        = os
local math      = math
local io        = io

local x         = {}

x.quake         = quake {
	app             = "konsole",
	name            = "xterm-konsole",
	extra           = "--hide-menubar --hide-tabbar",
	followtag       = true,
	vert            = "bottom",
	horiz           = "center",
	height          = 0.3,
	width           = 0.5,
	keepclientattrs = true,
	border          = 0,
	screen          = awful.screen.focused() or screen[1],

	settings        = function(c)

		c.opacity           = 0.7
		c.border_width      = 2
		c.border_color      = "#000000"
		c.titlebars_enabled = false
		c.skip_taskbar      = true
		c.shape             = function(cc, w, h)
			return gears.shape.partially_rounded_rect(
					cc, w, h, true, true, false, false, 10
			)
		end
	end
}

local function os_getenv(varname)
	-- get a temporary file name
	local n = os.tmpname()
	-- execute a command
	os.execute(". /home/ia/.dotfiles/private/env.bash && . /home/ia/.dotfiles/private/github.bash && echo ${" .. varname .. "} > " .. n)
	local file = io.open(n, "r")
	local line = ""
	line       = file:read()
	file:close()
	-- remove temporary file
	os.remove(n)
	return line
end

--- Return wind direction as a string.
local function to_direction(degrees)
	-- Ref: https://www.campbellsci.eu/blog/convert-wind-directions
	if degrees == nil then
		return "?"
	end
	local directions = {
		"N",
		"NNE",
		"NE",
		"ENE",
		"E",
		"ESE",
		"SE",
		"SSE",
		"S",
		"SSW",
		"SW",
		"WSW",
		"W",
		"WNW",
		"NW",
		"NNW",
		"N",
	}
	return directions[math.floor((degrees % 360) / 22.5) + 1]
end

x.weather = weather {
	APPID    = os_getenv("OPENWEATHERMAP_API_KEY"),
	city_id  = tonumber(os_getenv("OPENWEATHERMAP_CITY_ID")),
	timeout  = 60 * 30, -- 15 * 60 = 15 minutes
	--    notification_text_fun = function (wn)
	--        local day = os.date("%a %d", wn["dt"])
	--        local tmin = math.floor(wn["temp"]["min"])
	--        local tmax = math.floor(wn["temp"]["max"])
	--        local desc = wn["weather"][1]["description"]
	--        return string.format("<b>%s</b>: %s, %d - %d ", day, desc, tmin, tmax)
	--    end,
	--    notification_text_fun = function (wn)
	--        local day = os.date("%a %d", wn["dt"]) or "DATE"
	--        local tmin = math.floor(wn["temp"]["min"]) or -42
	--        local tmax = math.floor(wn["temp"]["max"]) or 69
	--        local desc = wn["weather"][1]["description"] or "Outside"
	----        local name = wn["name"] or "NONAME"
	----        return string.format("%s", tostring(wn))
	--        return string.format("<b>%s</b>: %s, High: %d Low: %d ", day, desc, tmax, tmin)
	--    end,
	settings = function()


		--        local loc_now = os.time()
		--        local sunrise = tonumber(weather_now["sys"]["sunrise"])
		--        local sunset  = tonumber(weather_now["sys"]["sunset"])
		--        if sunrise <= loc_now and loc_now <= sunset then
		--            -- day time, pre sunset; show sunset time
		--            str = string.format(" %s 🌜", os.date("%H:%M", weather_now["sys"]["sunset"]))
		--        elseif loc_now <= sunrise then
		--            -- pre dawn
		--            str = string.format(" %s 🌣", os.date("%H:%M", weather_now["sys"]["sunrise"]))
		--        elseif sunset <= loc_now then
		--            -- after sunset
		--            str =  string.format(" 🌜 %s", os.date("%H:%M", weather_now["sys"]["sunset"]))
		--        end

		widget:set_markup(
				markup.font(beautiful.font, " " .. math.floor(weather_now["main"]["temp"]) .. "°C" ..
						" " .. to_direction(weather_now["wind"]["deg"]) .. math.floor(weather_now["wind"]["speed"]))
		)

		--    showpopup = "off",
	end
}
return x