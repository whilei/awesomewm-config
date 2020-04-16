--[[

     Powerarrow Dark Awesome WM theme
     github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")

local os = { getenv = os.getenv }
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/ia"
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
theme.color_lightblue = "#2ECCFA"

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
theme.border_normal                             = "#1c2022"
theme.border_focus                              = "#606060"
theme.border_marked                             = "#3ca4d8"

theme.border_width                              = 0

theme.tasklist_bg_normal                        = "#313452"-- "#c8def7"
theme.tasklist_bg_focus                         = "#0B1DC2" -- "#1A1A1A"
theme.tasklist_fg_normal                        = "#FFFFFF"
theme.tasklist_fg_focus                         = "#FFFFFF"

theme.titlebar_bg_focus                         = theme.bg_focus
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_focus                         = theme.fg_focus
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

-- Textclock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.watch(
    "date +'%a %d %b %R UTC%:::z'", 60,
    function(widget, stdout)
        widget:set_markup(" " .. markup.font(theme.font, stdout))
    end
)

-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.font(theme.font, " " .. string.format("%.0f", mem_now.used / 1024) .. "GB "))
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.font(theme.font, " " .. string.format("%3d%%", cpu_now.usage)))
    end
})

-- Coretemp
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = lain.widget.temp({
    settings = function()
        if coretemp_now == "N/A" then
            widget:set_markup(markup.font(theme.font, " " .. markup(theme.fg_normal, coretemp_now .. "°C")))
        elseif tonumber(coretemp_now) > 90.0 then
            widget:set_markup(markup.fontbg(theme.font, theme.color_red, " " .. markup("#000000", coretemp_now .. "°C") .. " "))
        elseif tonumber(coretemp_now) > 80.0 then
            widget:set_markup(markup.fontbg(theme.font, theme.color_orange, " " .. markup("#000000", coretemp_now .. "°C") .. " "))
        elseif tonumber(coretemp_now) > 70.0 then
            widget:set_markup(markup.fontbg(theme.font, theme.color_yellow, " " .. markup("#000000", coretemp_now .. "°C") .. " "))
        elseif tonumber(coretemp_now) > 60.0 then
            widget:set_markup(markup.fontbg(theme.font, theme.color_green, " " .. markup("#000000", coretemp_now .. "°C") .. " "))
        else
            widget:set_markup(markup.fontbg(theme.font, theme.color_lightblue, " " .. markup("#000000", coretemp_now .. "°C") .. " "))
        end
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
        if input_now.status == "on" then
            micicon:set_image(theme.widget_mic_on)
            -- micicon:set_image()
            widget:set_markup(markup.fontbg(theme.font, theme.color_red, markup("#ffffff", " ((( • On Air • ))) ")))
        
        elseif input_now.status == "off" then
            micicon:set_image(theme.widget_mic_off)
            widget:set_markup(markup.font(theme.font, markup("#cfb1e0", " _ Off Air _ ")))
            -- widget:set_markup(markup.font(theme.font, " "))
        end
    end
})

-- ALSA volume
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume = lain.widget.alsa({
    settings = function()
        if output_now.status == "off" then
            volicon:set_image(theme.widget_vol_mute)
        elseif tonumber(output_now.level) == 0 then
            volicon:set_image(btheme.widget_vol_no)
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
        widget:set_markup(markup.font(theme.font,
                          markup("#FF4943", net_now.sent .. "↑")
                          .. "  " ..
                          markup("#2ECCFA", "↓" .. net_now.received)
                          .. " kb"
                          ))
    end
})

-- Separators
local spr     = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(theme.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", theme.bg_focus)

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
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
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 18, bg = theme.bg_normal, fg = theme.fg_normal })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,

            s.mytaglist,
                       -- Layout
                       spr,
                       s.mylayoutbox,
                       spr,

            s.mypromptbox,
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

                    spr,


                    -- Net up/down
                    neticon,
                    -- How to wrap items in a custom background.
--                     wibox.container.background(neticon, theme.bg_focus),
--                     wibox.container.background(net.widget, theme.bg_focus),
                    net.widget,

                    spr,

                    cpu_widget({
                        width = 100,
                        step_width = 2,
                        step_spacing = 0,
                        color = '#434c5e'
                    }),

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
