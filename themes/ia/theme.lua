--[[

     Powerarrow Dark Awesome WM theme
     github.com/lcpz

--]]

local math     = math
local string   = string
local type     = type
local tonumber = tonumber
local tostring = tostring

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local common = require("awful.widget.common")

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
--local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
--local weather_widget = require("awesome-wm-widgets.weather-widget.weather")

local os = {
    getenv = os.getenv,
    tmpname = os.tmpname,
    execute = os.execute,
    remove = os.remove,
}
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/ia"

-- Wallpaper, wallpaper
theme.wallTallIndex = 0
theme.wallWideIndex = 0
function wallFn(s)
    -- Default wide.
    local out = theme.dir .. "/walls/iter/wide/wall" .. theme.wallWideIndex .. ".jpg"

    -- If known tall screens.
    if s.geometry.width < s.geometry.height then
        out = theme.dir .. "/walls/iter/tall/wall" .. theme.wallTallIndex .. ".jpg"
        theme.wallTallIndex = theme.wallTallIndex + 1
        return out
    end

    theme.wallWideIndex = theme.wallWideIndex + 1
    return out
end
theme.wallpaper                                 = wallFn

theme.font                                      = "xos4 Terminus 9"
theme.color_green = "#2EFE2E"
theme.color_yellow ="#FFFF00"
theme.color_orange = "#FF8000"
theme.color_red = "#DF0101"
theme.color_lightblue = "#4070cf"

theme.menu_bg_normal                            = "#000000"
theme.menu_bg_focus                             = "#000000"
theme.bg_normal                                 = "#000000"
theme.bg_focus                                  = "#000000"
theme.bg_urgent                                 = "#000000"
theme.fg_normal                                 = "#aaaaaa"
theme.fg_focus                                  = "#ff8c00"
theme.fg_urgent                                 = "#af1d18"
theme.bg_minimize                               = "#bf2e3a"
theme.fg_minimize                               = "#ffffff"

theme.clock_bg = "#191f1a"
theme.colon_fg = "#256c1e"
theme.clock_fg = "#32ab3a"

-- theme.border_normal                             = "#1c2022"
-- theme.border_focus                              = "#606060"
-- theme.border_marked                             = "#3ca4d8"

theme.border_normal                             = "#000000ff"
theme.border_focus                              = "#0B1DC2"
theme.border_marked                             = "#f05800"

theme.border_width                              = 4

theme.tasklist_bg_normal                        = "#313452" -- "#c8def7"#f01800
theme.tasklist_bg_focus                         = "#0B1DC2" -- "#1A1A1A"
theme.tasklist_fg_normal                        = "#FFFFFF"
theme.tasklist_fg_focus                         = "#FFFFFF"

theme.titlebar_bg_focus                         = theme.tasklist_bg_focus -- theme.bg_focus
theme.titlebar_bg_normal                        = theme.tasklist_bg_normal
theme.titlebar_fg_focus                         = theme.tasklist_fg_focus -- "#ffffff" -- theme.fg_focus

theme.menu_height                               = 18
theme.menu_width                                = 140

theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
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
theme.widget_mic_on = theme.dir .. "/icons/mic_google_on.png"
theme.widget_mic_off = theme.dir .. "/icons/mic_off.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.tasklist_plain_task_name                  = false -- true
theme.tasklist_disable_icon                     = false -- true
theme.useless_gap                               = 0
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

local markup = lain.util.markup
local separators = lain.util.separators

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
	return string.format("#%02x%02x%02x", math.floor(r*255), math.floor(g*255), math.floor(b*255))
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
	
	local num = select('#', ...) / 3

    local segment, relperc = math.modf(perc*(num-1))
    local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
    
    if r1 > 1 then
        r1, g1, b1, r2, g2, b2 =	r1/255, g1/255, b1/255, r2/255, g2/255, b2/255
    end

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local function HexToRGBPerc(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
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

-- Textclock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.watch(
    -- "date +'%a %d %b %R UTC%:::z'", 
    -- "date +'%a %d %b %R UTC%:::z'", 
    -- "date +'%Y-%m-%dT%H:%MZ%:z'",
    --"date +'%-m-%d %A %H:%M %:::z'",
    "date +'%H:%M %a %-m-%d %:::z'",
    60,
    function(widget, stdout)
        -- widget:set_markup(" " .. markup.font(theme.font, stdout))

        widget:set_markup(
            -- theme.font
            markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
        )
    end
)

local world_clock_vancouver = awful.widget.watch(
        "bash -c 'TZ='America/Vancouver' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_chicago = awful.widget.watch(
        "bash -c 'TZ='America/Chicago' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)


local world_clock_newyork = awful.widget.watch(
        "bash -c 'TZ='America/New_York' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local clock_utc = awful.widget.watch(
        "date -u +'%H:%M'",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_london = awful.widget.watch(
        "bash -c 'TZ='Europe/London' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_berlin = awful.widget.watch(
        "bash -c 'TZ='Europe/Berlin' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_madrid = awful.widget.watch(
        "bash -c 'TZ='Europe/Madrid' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)


local world_clock_athens = awful.widget.watch(
        "bash -c 'TZ='Europe/Athens' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_dubai = awful.widget.watch(
        "bash -c 'TZ='Asia/Dubai' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_shanghai = awful.widget.watch(
        "bash -c 'TZ='Asia/Shanghai' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)

local world_clock_tokyo = awful.widget.watch(
        "bash -c 'TZ='Asia/Tokyo' date +'%H:%M_%:::z''",
        60,
        function(widget, stdout)
            -- widget:set_markup(" " .. markup.font(theme.font, stdout))

            widget:set_markup(
            -- theme.font
                    markup.fontbg("Roboto Bold 10", theme.clock_bg, " " .. markup(theme.clock_fg, stdout) .. " ")
            )
        end
)



-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local mem = lain.widget.mem({
    settings = function()

        -- get base
        local r, g, b = ColorGradient((mem_now.perc / 100),   52, 82, 201 , 50, 171, 58, 207, 180, 29, 240, 24, 0)
        -- local bg_color = RGBPercToHex(r, g, b)

        r, g, b = ColorGradient(0.6 , r,g,b, 1,1,1) -- lighten it
        local fg_color = RGBPercToHex(r, g, b)

        r, g, b = ColorGradient((mem_now.perc / 100),   52, 82, 201 , 50, 171, 58, 207, 180, 29, 240, 24, 0)
        -- local bg_color = RGBPercToHex(r, g, b)

        r, g, b = ColorGradient(0.8,  r, g, b,  0,0,0)
        local bg_color = RGBPercToHex(r, g, b)

        local fmt = string.format("%.0f GB", mem_now.used / 1024)
        widget:set_markup(markup.fontbg(theme.font, bg_color, " " .. markup(fg_color, fmt) .. " "))
        -- widget:set_markup(markup.font(theme.font, " " .. string.format("%.0f", mem_now.used / 1024) .. "GB "))
    end
})


-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        -- widget:set_markup(markup.font(theme.font, " " .. string.format("%3d%%", cpu_now.usage)))
        local strf = string.format("%3d%%", cpu_now.usage)

        local rr, gg, bb = ColorGradient((cpu_now.usage / 100),   52, 82, 201 , 50, 171, 58, 207, 180, 29, 240, 24, 0)
        local r, g, b = ColorGradient(0.6, rr, gg, bb, 0, 0, 0)
        local bg_color = RGBPercToHex(r, g, b)

        r, g, b = ColorGradient(0.6 , rr, gg, bb, 0.8,0.8,0.8) -- lighten it
        local fg_color = RGBPercToHex(r, g, b)
        if cpu_now.usage == 100 then
          fg_color = '#ff0000'
        end

        widget:set_markup(markup.fontbg(theme.font, bg_color, " " .. markup(fg_color, strf) .. " "))
        -- widget:set_markup(markup.font(theme.font, strf))
    end
})

-- Coretemp
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = lain.widget.temp({
    settings = function()


        -- want: 0.2 (cool), 0.5 (warm), 0.92 (hot)
        local min = 33
        local max = 110
        local range = max - min

        local d = coretemp_now - min
        local relativeHeat = d / range

        -- if relativeHeat < 0 then relativeHeat = 0 end
        -- if relativeHeat > 1 then relativeHeat = 1 end

        -- blue, green, yellow, red
        -- local blue, green, yellow, red = h2rgb("#3452c9"),   h2rgb("#32ab3a"),  h2rgb("#e8d031"),  h2rgb("#f01800")
        local r, g, b = ColorGradient(relativeHeat,   52, 82, 201 , 50, 171, 58, 207, 180, 29, 240, 24, 0)
        local bg_color = RGBPercToHex(r, g, b)

        r, g, b = ColorGradient(0.7 , r,g,b, 0,0,0)
        local fg_color = RGBPercToHex(r, g, b)

        -- local bg_color = RGBPercToHex(ColorGradient(relativeHeat,    blue, green, yellow, red))
        -- local fg_color = RGBPercToHex(ColorGradient(relativeHeat / 2,    blue, green, yellow, red))

        widget:set_markup(markup.fontbg(theme.font, bg_color, " " .. markup(fg_color, coretemp_now .. "°C") .. " "))
    end
})

-- / fs
local fsicon = wibox.widget.imagebox(theme.widget_hdd)
theme.fs = lain.widget.fs({
    notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = "xos4 Terminus 10" },
    settings = function()
        widget:set_markup(markup.font(theme.font, " " .. fs_now["/"].percentage .. "% "))
    end
})

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_battery)
local bat = lain.widget.bat({
    settings = function()
        if bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                widget:set_markup(markup.font(theme.font, " AC "))
                baticon:set_image(theme.widget_ac)
                return
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                baticon:set_image(theme.widget_battery_empty)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                baticon:set_image(theme.widget_battery_low)
            else
                baticon:set_image(theme.widget_battery)
            end
            widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
        else
            widget:set_markup(markup.font(theme.font, " AC "))
            baticon:set_image(theme.widget_ac)
        end
    end
})

-- ALSA microphone
local micicon = wibox.widget.imagebox()
theme.mic = lain.widget.alsa({
    channel = "Capture",
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
        local bg = "#d93600" -- theme.color_red
        local fg = "#fbff00"
        if input_now.status == "off" then
            --words = " • Off Air " --✕
            words = " x " --✕
            bg = "#3b383e" -- "#370e5c"
            fg = "#887b94"
        end
        widget:set_markup(markup.fontbg(theme.font, bg, markup(fg, words)))
    end
})

-- ALSA volume
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume = lain.widget.alsa({
    settings = function()
        if output_now.status == "off" then
            volicon:set_image(theme.widget_vol_mute)
        elseif tonumber(output_now.level) == 0 then
            volicon:set_image(theme.widget_vol_no)
        elseif tonumber(output_now.level) <= 50 then
            volicon:set_image(theme.widget_vol_low)
        else
            volicon:set_image(theme.widget_vol)
        end

        widget:set_markup(markup.font(theme.font, " " .. output_now.level .. "% "))
    end
})

-- Net
local neticon = wibox.widget.imagebox(theme.widget_net)
local net = lain.widget.net({
    settings = function()
        -- https://www.lua.org/pil/8.3.html
        local line = "unknown"
        local file = io.open("/home/ia/ipinfo.io/locale", "r")
        line = file:read()
        file:close()
        widget:set_markup(markup.font(theme.font,
                            line .. "  " ..
                          markup("#fcc9ff", net_now.sent .. "↑")
                          .. "  " ..
                          markup("#2ECCFA", "↓" .. net_now.received)
                          .. " kb"
                          ))
    end
})

--local weather = weather_widget({
--    api_key = "25fb73929c3c4030dc1800e70518aedb"
--})

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

local function os_getenv(varname)
    -- get a temporary file name
    local n = os.tmpname()
    -- execute a command
    os.execute (". /home/ia/.dotfiles/private/env.bash && echo ${" .. varname .. "} > " .. n)
    local file = io.open(n, "r")
    local line = ""
    line = file:read()
    file:close()
    -- remove temporary file
    os.remove(n)
    return line
end

local weather = lain.widget.weather({
    APPID = os_getenv("OPENWEATHERMAP_API_KEY"),
    city_id = tonumber(os_getenv("OPENWEATHERMAP_CITY_ID")),
    timeout = 60 * 30, -- 15 * 60 = 15 minutes
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
        local str = ""

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
            markup.font(theme.font,  " " .. math.floor(weather_now["main"]["temp"]) .. "°C" ..
                    " " .. to_direction(weather_now["wind"]["deg"]) .. math.floor(weather_now["wind"]["speed"]))
        )
--    showpopup = "off",
    end
})

-- Separators
local spr     = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(theme.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", theme.bg_focus)

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({
        app = "konsole",
        name = "xterm-konsole",
        extra = "--hide-menubar --hide-tabbar",
        followtag = true,
        vert = "bottom",
        keepclientattrs = true,
        border = 0,
        settings = function (client)
            -- these don't work. don't know why.
            client.opacity = 0.7
            client.border_color = gears.color.parse_color("#ff0000ff")
            client.titlebars_enabled = false

            local geo
            geo = client:geometry()
            if geo.width > 2000 then
                geo.x = geo.x + (geo.width / 4)
                geo.width = geo.width / 2
                client:geometry(geo)
            end
        end
    })

    s.quakeBrowser = lain.util.quake2({
        app = "ffox", -- uses: 'snap alias firefox ffox'
        extra = "",
        name = "MozillaFirefoxDD",
        argname = "",
        followtag = true,
        vert = "top",
        keepclientattrs = true,
        settings = function(client)
            local geo
            geo = client:geometry()
            if geo.width > 2000 then
                geo.x = geo.x + (geo.width / 4)
                geo.width = geo.width / 2
                geo.height = geo.height * 2
                client:geometry(geo)
            else
                geo.height = geo.height * 2
                client:geometry(geo)
            end
        end
    })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    --gears.wallpaper.maximized(wallpaper, s, false)
    gears.wallpaper.fit(wallpaper, s)

    -- Tags
    -- Use the first layout as the default one for all tags.
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
 
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt({
        prompt = "> ",
        bg = "#0000ff", -- "#1E2CEE", -- "#000000",
        fg = "#ffffff",
        bg_cursor = "#e019c9", --pink
        fg_cursor = "#e019c9" --pink
    })
    
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    local function list_update(w, buttons, label, data, objects)
        common.list_update(w, buttons, label, data, objects)
        w:set_max_widget_size(120)
    end
    -- awful.widget.tasklist()
    s.mytasklist = awful.widget.tasklist(
        s, -- screen
        awful.widget.tasklist.filter.currenttags, -- filter
        awful.util.tasklist_buttons, -- buttons
        nil, -- style
        list_update -- update function
    )

    -- Create the wibox
    -- opacity isnt affected even with the table keybecause you need to add the two hex codes to the bg, eg.  '.. "aa"'
    s.mywibox = awful.wibar({
        position = "top", -- top, bottom
        screen = s,
        height = 18,
        bg = theme.bg_normal,
        fg = theme.fg_normal,
        opacity = 0.5,
    })

    s.mywibox_worldtimes = awful.wibar({
        -- visible = false,
        position = "right",
        --stretch = true,
        ontop = true,
        screen = s,
        --height = 18,
        width = 100,
        y = 18,
        bg = theme.bg_normal,
        fg = theme.fg_normal,
        opacity = 0.5,
    })

    s.mywibox_worldtimes:setup {
        layout = wibox.layout.align.vertical,
        -- left
        {
            layout = wibox.layout.fixed.vertical,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Vancouver'))),
            world_clock_vancouver,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Chicago'))),
            world_clock_chicago,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'New York'))),
            world_clock_newyork,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'UTC'))),
            clock_utc,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'London'))),
            world_clock_london,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Berlin'))),
            world_clock_berlin,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Madrid'))),
            world_clock_madrid,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Athens'))),
            world_clock_athens,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Dubai'))),
            world_clock_dubai,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Shanghai'))),
            world_clock_shanghai,
            --spr,

            wibox.widget.textbox(markup.fontbg("Roboto 8", theme.clock_bg, " " .. markup(theme.clock_fg, 'Tokyo'))),
            world_clock_tokyo,
            --spr,


        },
        -- middle
        {
            layout = wibox.layout.fixed.vertical,
        },
        -- right
        {
            layout = wibox.layout.fixed.vertical,

        },
    }

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal, 
            
            s.mypromptbox,
            spr,

            s.mytaglist,
            spr,

            s.mylayoutbox,
            spr,
 
            s.mytasklist,
        },
        -- middle
        {
            layout = wibox.layout.fixed.horizontal,
        },
        
        { -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    wibox.widget.systray(),

            -- weather insert
            spr,
            --                    wibox.widget.imagebox(weather.icon),
            --                    wibox.widget.textbox('weather: '),
                    --
            weather.icon,
            weather.widget,
            --        weather_widget({
            --            api_key=os_getenv("OPENWEATHERMAP_API_KEY"),
            --            coordinates = {46.786671, -92.100487},
            --        }),
            --

                    -- Net up/down
                    spr,
                    neticon,
                    -- How to wrap items in a custom background.
--                     wibox.container.background(neticon, theme.bg_focus),
--                     wibox.container.background(net.widget, theme.bg_focus),
                    net.widget,

                    -- spr,
                    -- cpu_widget({
                    --     width = 100,
                    --     step_width = 2,
                    --     step_spacing = 0,
                    --     color = "#4070cf" -- '#434c5e'
                    -- }),

                    -- CPU
                    spr,
                    cpuicon,
                    cpu.widget,
                    
                    -- Memory
                    -- spr,
                    -- memicon,
                    mem.widget,

                    -- Battery
                    spr,
                    baticon,
                    bat.widget,

                    -- Filesytem
                    spr,
                    fsicon,
                    theme.fs.widget,

                    -- Volume
                    spr,
                    volicon,
                    theme.volume.widget,


                    -- Clock
                    spr,
                    clock,
                    --wibox.widget.textbox('/'),
                    -- clock_utc,

                    -- Microphone
                     spr,
                     theme.mic.widget,
                    -- micicon,

                    -- Temperature
                    spr,
                    -- tempicon,
                    temp.widget,
        },
    }
end

return theme
