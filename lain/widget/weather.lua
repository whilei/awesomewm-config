--[[

     Licensed under GNU General Public License v2
      * (c) 2015, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local json     = require("lain.util").dkjson
local focused  = require("awful.screen").focused
local awful = require("awful")
local naughty  = require("naughty")
local wibox    = require("wibox")
local math     = math
local os       = os
local string   = string
local type     = type
local tonumber = tonumber

-- OpenWeatherMap
-- current weather and X-days forecast
-- lain.widget.weather

--- Return wind direction as a string.
function to_direction(degrees)
    -- Ref: https://www.campbellsci.eu/blog/convert-wind-directions
    if degrees == nil then
        return "Unknown dir"
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

local function factory(args)
    args                        = args or {}

    local weather               = { widget = args.widget or wibox.widget.textbox() }
    local APPID                 = args.APPID or "3e321f9414eaedbfab34983bda77a66e" -- lain's default
    local timeout               = args.timeout or 60 * 15 -- 15 min
    local current_call          = args.current_call  or "curl -s 'https://api.openweathermap.org/data/2.5/weather?id=%s&units=%s&lang=%s&appid=%s'"
    local forecast_call         = args.forecast_call or "curl -s 'https://api.openweathermap.org/data/2.5/forecast/daily?id=%s&units=%s&lang=%s&cnt=%s&appid=%s'"
    local city_id               = args.city_id or 0 -- placeholder
    local units                 = args.units or "metric"
    local lang                  = args.lang or "en"
    local cnt                   = args.cnt or 5
    local icons_path            = args.icons_path or helpers.icons_dir .. "openweathermap/"
    local notification_preset   = args.notification_preset or {}
    local notification_text_fun = args.notification_text_fun or
                                  function (wn)
                                      local day = os.date("%a %d", wn["dt"])
                                        local sunrise = os.date("%H:%M", wn["sunrise"])
                                        local sunset = os.date("%H:%M", wn["sunset"])
                                      local tmin = math.floor(wn["temp"]["min"])
                                      local tmax = math.floor(wn["temp"]["max"])
                                      local desc = wn["weather"][1]["description"]
                                    local winddir = to_direction(wn["deg"])
                                    local windspeed = math.floor(wn["speed"])
                                      return string.format("<b>%s</b>: High: %d°C, Low: %d°C, Wind: %s%d | 🌣 %s 🌜 %s | %s", day, tmax, tmin, winddir, windspeed, sunrise, sunset, desc)
--                                        local winddir = to_direction(wn["wind"]["deg"])
--                                      return string.format("<b>%s</b>: Low: %d°C, High: %d°C, Wind: %s | %s", day, tmin, tmax, winddir, desc)
--                                  local windspeed = math.floor(wn["wind"]["speed"])
--                                      return string.format("<b>%s</b>: Low: %d°C, High: %d°C, Wind: %s | %s", day, tmin, tmax, winddir, desc)
--                                      return string.format("<b>%s</b>: Low: %d°C, High: %d°C, Wind: %d%s | %s", day, tmin, tmax, desc, windspeed, winddir)
                                  end
    local weather_na_markup     = args.weather_na_markup or " N/A "
    local followtag             = args.followtag or false
    local showpopup             = args.showpopup or "on"
    local settings              = args.settings or function() end

    weather.widget:set_markup(weather_na_markup)
    weather.icon_path = icons_path .. "na.png"
    weather.icon = wibox.widget.imagebox(weather.icon_path)

    local function error_display(resp_json)
        --local err_resp = json.decode(resp_json)
        naughty.notify{
            title = 'Weather Widget Error',
            text = "Failed to get weather.",
            preset = naughty.config.presets.low,
        }
        --if err_resp.message then
        --    naughty.notify{
        --        title = 'Weather Widget Error',
        --        text = err_resp.message,
        --        preset = naughty.config.presets.critical,
        --    }
        --else
        --    naughty.notify{
        --        title = 'Weather Widget Error',
        --        text = err_resp,
        --        preset = naughty.config.presets.critical,
        --    }
        --end
    end

    function weather.show(seconds)
        weather.hide()

        if followtag then
            notification_preset.screen = focused()
        end

        if not weather.notification_text then
            weather.update()
            weather.forecast_update()
        end

--        weather.notification = naughty.notify {
--            preset  = notification_preset,
--            text    = weather.notification_text,
----            icon    = weather.icon_path,
--            timeout = type(seconds) == "number" and seconds or notification_preset.timeout
--        }

		local text_widget = wibox.widget.textbox()
		text_widget:set_markup(weather.notification_text)

        weather.popup = awful.popup {
			widget = {
				text_widget,
				margins = 10,
				widget = wibox.container.margin,
			},
			border_color = "#00f",
			screen = awful.screen.focused() or 1,
			placement = awful.placement.centered,
			visible = true,
			ontop = true,
			offset = { y = 40 },
        }
    end

    function weather.hide()
        if weather.popup then
            weather.popup.visible = false
			weather.popup = nil
        end
    end

    function weather.attach(obj)
        obj:connect_signal("mouse::enter", function()
            weather.show(0)
        end)
        obj:connect_signal("mouse::leave", function()
            weather.hide()
        end)
    end

    function weather.forecast_update()
        local cmd = string.format(forecast_call, city_id, units, lang, cnt, APPID)
        helpers.async(cmd, function(f)
            local err
            weather_now, _, err = json.decode(f, 1, nil)

            if not err and type(weather_now) == "table" and tonumber(weather_now["cod"]) == 200 then
                weather.notification_text = ""
                for i = 1, weather_now["cnt"] do
                    weather.notification_text = weather.notification_text ..
                            notification_text_fun(weather_now["list"][i])
                    if i < weather_now["cnt"] then
                        weather.notification_text = weather.notification_text .. "\n"
                    end
                end
            end
        end)
    end

    function weather.update()
        local cmd = string.format(current_call, city_id, units, lang, APPID)
        helpers.async(cmd, function(f)
            local err
            weather_now, _, err = json.decode(f, 1, nil)

            if not err and type(weather_now) == "table" and tonumber(weather_now["cod"]) == 200 then
                local sunrise = tonumber(weather_now["sys"]["sunrise"])
                local sunset  = tonumber(weather_now["sys"]["sunset"])
                local icon    = weather_now["weather"][1]["icon"]
                local loc_now = os.time()

                if sunrise <= loc_now and loc_now <= sunset then
                    icon = string.gsub(icon, "n", "d")
                else
                    icon = string.gsub(icon, "d", "n")
                end

                weather.icon_path = icons_path .. icon .. ".png"
                widget = weather.widget
                settings()
            else
                error_display(f)
                weather.icon_path = icons_path .. "na.png"
                weather.widget:set_markup(weather_na_markup)
            end

            weather.icon:set_image(weather.icon_path)
        end)
    end

    if showpopup == "on" then weather.attach(weather.widget) end

    weather.timer = helpers.newtimer("weather-" .. city_id, timeout, weather.update, false, true)
    weather.timer_forecast = helpers.newtimer("weather_forecast-" .. city_id, timeout, weather.forecast_update, false, true)

    return weather
end

return factory
