--[[

     Awesome WM configuration template
     github.com/lcpz

--]]
-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, tointeger, type = ipairs, string, os, table, tostring, tonumber, tointeger, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
--local menubar       = require("menubar")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local revelation = require("revelation")

local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error",
        function(err)
            if in_error then
                return
            end
            in_error = true

            naughty.notify({
                preset = naughty.config.presets.critical,
                title = "Oops, an error happened!",
                text = tostring(err)
            })
            in_error = false
        end)
end
-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({ "urxvtd", "unclutter -root" }) -- entries must be comma-separated

-- {{{ Variable definitions

local chosen_theme = "ia"
local modkey = "Mod4"
local altkey = "Mod1"
local terminal = "xterm"
local editor = os.getenv("EDITOR") or "vim"
local gui_editor = "code"
local browser = "ffox"
local guieditor = "code"
local scrlocker = "xlock"
local scrnshotter = "scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' -s -e 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"
local invert_colors = "xrandr-invert-colors"

local clientkeybindings = {}
-- clientkeybindings["z"] = "Konsole"
-- clientkeybindings["a"] = "Google Chrome"
-- clientkeybindings["e"] = "Emacs"

for key, app in pairs(clientkeybindings) do
    awful.key({ "Control", "Shift" },
        key,
        function()
            local matcher = function(c)
                return awful.rules.match(c, { class = app })
            end
            awful.client.run_or_raise(app, matcher)
        end)
end

awful.util.terminal = terminal
--awful.util.tagnames = { "1", "2", "3", "4", "5" }
awful.util.tagnames = { "●", "●", "●", "●", "●" }
--awful.util.tagnames = { "▇", "▇", "▇", "▇", "▇" }
awful.layout.layouts = {
    -- awful.layout.suit.tile.bottom,
    lain.layout.centerwork,
    awful.layout.suit.tile,
    --awful.layout.suit.fair,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
}

awful.util.taglist_buttons = my_table.join(awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end))

awful.util.tasklist_buttons = my_table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() and c.first_tag then
            c.first_tag:view_only()
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end))


local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)
revelation.init()
-- }}}


-- {{{ Menwesomeu
local myawesomemenu = {
    {
        "hotkeys",
        function()
            return false, hotkeys_popup.show_help
        end
    },
     --{ "layouts", function() return false, layoutlist_popup.widget end },
    -- { "manual", terminal .. " -e man awesome" },
    -- { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart }
--    {
--        "quit",
--        function()
--            awesome.quit()
--        end
--    }
}
awful.util.mymainmenu =
freedesktop.menu.build({
    icon_size = beautiful.menu_height or 18,
    before = {
        -- other triads can be put here
    },
    after = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Open terminal", terminal }
        -- other triads can be put here
    }
})
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry",
    function(s)
        -- Wallpaper
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Key bindings
globalkeys =
my_table.join(-- Take a screenshot
-- https://github.com/lcpz/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p",
        function()
            os.execute(scrnshotter)
        end,
        { description = "take a screenshot", group = "hotkeys" }),
    awful.key({ modkey }, "x",
        function()
            os.execute(invert_colors)
        end,
        { description = "invert colors on all screens with xrandr", group = "hotkeys" }),

    -- Hotkeys
    awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

    -- Tag browsing
    awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
    awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),


    -- Revelation client focus
--    awful.key({ modkey }, "e", revelation),

    -- Default client focus
    awful.key({ altkey },
        "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }),
    awful.key({ altkey },
        "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }),
    -- By direction client focus
    awful.key({ modkey },
        "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "focus down", group = "client" }),
    awful.key({ modkey },
        "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "focus up", group = "client" }),
    awful.key({ modkey },
        "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "focus left", group = "client" }),
    awful.key({ modkey },
        "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "focus right", group = "client" }),
    awful.key({ modkey },
        "w",
        function()
            awful.util.mymainmenu:show()
        end,
        { description = "show main menu", group = "awesome" }),
    -- Layout manipulation
    awful.key({ modkey, "Shift" },
        "j",
        function()
            awful.client.swap.byidx(1)
        end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" },
        "k",
        function()
            awful.client.swap.byidx(-1)
        end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" },
        "j",
        function()
            awful.screen.focus_relative(1)
        end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" },
        "k",
        function()
            awful.screen.focus_relative(-1)
        end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey },
        "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Show/Hide Wibox
    awful.key({ modkey },
        "d",
        function()
            --for s in screen do
            local s = awful.screen.focused()
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
                if s.mywibox_slim then
                    s.mywibox_slim.visible = not s.mywibox_slim.visible
                end
            --end
        end,
        { description = "toggle wibox", group = "awesome" }),

    -- Show/Hide Global Time Clock wibar
    awful.key({ modkey },
            "g", -- g for Global times (and is on right)
            function()
                local s =  awful.screen.focused()
                --for s in screen do
                    s.mywibox_worldtimes.visible = not s.mywibox_worldtimes.visible
                --end
            end,
            { description = "toggle world times wibox", group = "awesome" }),

    ---- Show/Hide Time/Clock box
    --awful.key({ modkey },
    --        "t", -- g for Global times (and is on right)
    --        function()
    --            local s =  awful.screen.focused()
    --            --for s in screen do
    --            s.mywibox_clock.visible = not s.mywibox_clock.visible
    --            --end
    --        end,
    --        { description = "toggle time/clock wibox", group = "awesome" }),

    ---- Show/Hide Slimified Wibar
    --awful.key({ modkey },
    --            "t", -- t for top
    --            function()
    --                for s in screen do
    --                    s.mywibox_slim.visible = not s.mywibox_slim.visible
    --                end
    --            end,
    --            { description = "toggle slim wibox wibarZ", group = "awesome" }),

    -- On the fly useless gaps change
    awful.key({ modkey, altkey },
        "`",
        function()
            lain.util.useless_gaps_resize(10)
        end,
        { description = "increment useless gaps", group = "tag" }),
    awful.key({ modkey, altkey },
        "-",
        function()
            lain.util.useless_gaps_resize(-10)
        end,
        { description = "decrement useless gaps", group = "tag" }),
    -- Dynamic tagging
    --awful.key({ modkey, "Shift" },
    --    "n",
    --    function()
    --        lain.util.add_tag()
    --    end,
    --    { description = "add new tag", group = "tag" }),
    --awful.key({ modkey, "Shift" },
    --    "r",
    --    function()
    --        lain.util.rename_tag()
    --    end,
    --    { description = "rename tag", group = "tag" }),
    awful.key({ modkey, "Shift" },
        "Left",
        function()
            lain.util.move_tag(-1)
        end,
        { description = "move tag to the left", group = "tag" }),
    awful.key({ modkey, "Shift" },
        "Right",
        function()
            lain.util.move_tag(1)
        end,
        { description = "move tag to the right", group = "tag" }),
    --awful.key({ modkey, "Shift" },
    --    "d",
    --    function()
    --        lain.util.delete_tag()
    --    end,
    --    { description = "delete tag", group = "tag" }),
    -- Standard program
    awful.key({ modkey },
        "Return",
        -- rofi binding
        function()
            -- Location values:
            -- 1   2   3
            -- 8   0   4
            -- 7   6   5

            -- -sidebar-mode shows 'tabs' of available modi

            commandPrompter = "rofi --modi window,run -show window -sidebar-mode -location 5 -theme Indego"
            awful.spawn.easy_async(commandPrompter, function()
                awful.screen.focus(client.focus.screen)
            end)
        end, { description = "run Rofi", group = "awesome" }),

    awful.key({ modkey, "Shift", }, "n",
    -- cool buttons (custom program) binding
            function(c)

                --commandPrompter = "cool-buttons"
                --awful.spawn.easy_async(commandPrompter, function()
                --    awful.screen.focus(client.focus.screen)
                --    --awful.client.floating = true;
                --    c.floating = true;
                --end)
                awful.spawn("cool-buttons", {
                    requests_no_titlebar = true,
                    floating  = true,
                    tag       = mouse.screen.selected_tag,
                    placement = awful.placement.top_left,
                })
            end, { description = "run cool-buttons", group = "awesome" }),

    awful.key({ altkey, "Shift" },
        "l",
        function()
            awful.tag.incmwfact(0.05)
        end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ altkey, "Shift" },
        "h",
        function()
            awful.tag.incmwfact(-0.05)
        end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ altkey, "Control", "Shift" },
        "g",
        function()
            awful.tag.setmwfact(0.618)
        end,
        { description = "golden ratio client width", group = "client" }),
    awful.key({ modkey, "Shift" },
        "h",
        function()
            awful.tag.incnmaster(1, nil, true)
        end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" },
        "l",
        function()
            awful.tag.incnmaster(-1, nil, true)
        end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" },
        "h",
        function()
            awful.tag.incncol(1, nil, true)
        end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" },
        "l",
        function()
            awful.tag.incncol(-1, nil, true)
        end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey },
        "space",
        function()
            awful.layout.inc(1)
        end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" },
        "space",
        function()
            awful.layout.inc(-1)
        end,
        { description = "select previous", group = "layout" }),
    awful.key({ modkey, "Control" },
        "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        { description = "restore minimized", group = "client" }),
    -- Dropdown application
    awful.key({ modkey },
        "z",
        function()
            awful.screen.focused().quake:toggle()
        end,
        { description = "dropdown application", group = "launcher" }),

    awful.key({ modkey },
        "y",
        function()
            awful.screen.focused().quakeBrowser:toggle()
        end,
        { description = "dropdown application", group = "launcher" }),

    -- ALSA volume control
    awful.key({ altkey, "Control" },
        "0",
        function()
            -- os.execute("if amixer get Capture | grep -q -E 'Capture.*off'; then amixer set Capture cap ; else amixer set Capture nocap; fi")
            os.execute("amixer -q set Capture toggle")
            beautiful.mic.update()
        end,
        { description = "microphone toggle", group = "hotkeys" }),

    awful.key({ altkey },
        "Up",
        function()
            os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        { description = "volume up", group = "hotkeys" }),
    awful.key({ altkey },
        "Down",
        function()
            os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        { description = "volume down", group = "hotkeys" }),
    awful.key({ altkey },
        "m",
        function()
            os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
            beautiful.volume.update()
        end,
        { description = "toggle mute", group = "hotkeys" }),

    awful.key({ altkey, "Control" },
        "m",
        function()
            -- os.execute(string.format("amixer -q set %s 100%%", beautiful.volume.channel))
            os.execute("unmute.sh")
            beautiful.volume.update()
        end,
        { description = "volume 100%", group = "hotkeys" }),

    -- Prompt
    awful.key({ modkey },
        "r",
        function()
            awful.screen.focused().mypromptbox:run()
        end,
        { description = "run prompt", group = "launcher" }))

clientkeys =
my_table.join(awful.key({ altkey, "Shift" }, "m", lain.util.magnify_client, { description = "magnify client", group = "client" }), awful.key({ modkey },

    "f",
    function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),

    awful.key({ modkey, "Shift" },
        "c",
        function(c)
            c:kill()
        end,
        { description = "close", group = "client" }),

    -- Place the client window floating in the middle, centered, on top.
    -- This is a nice focus geometry.
    awful.key({ modkey, "Control" },
        "space",
        function(c)
            awful.client.floating.toggle()
            awful.client.maximized = false

            if c.floating then
                -- place the screen in the middle
                local geo
                geo = c:geometry()
                local sgeo
                sgeo = c.screen.geometry

                local margin_divisor = 8
                if sgeo.width > 3000 then
                    margin_divisor = margin_divisor * 2
                end

                geo.x = sgeo.x + sgeo.width / margin_divisor
                geo.y = sgeo.y + sgeo.height / margin_divisor

                geo.width = sgeo.width - ((sgeo.width / margin_divisor)*2)
                geo.height = sgeo.height - ((sgeo.height / margin_divisor)*2)
                c:geometry(geo)
            end
            client.focus = c
            c:raise()
        end,
        { description = "toggle floating", group = "client" }),

    -- Place the client window floating in the middle, on top.
    -- This is a nice focus geometry.
    -- *BUT* this version will stretch the floating geometry vertically,
    -- easier for reading.
    awful.key({ altkey, "Control", "Shift", }, -- MEH=ctl+alt+shift
            "space",
            function(c)
                awful.client.floating.toggle()
                awful.client.maximized = false

                if c.floating then
                    -- place the screen in the middle
                    local geo
                    geo = c:geometry()
                    local sgeo
                    sgeo = c.screen.geometry

                    geo.x = sgeo.x + sgeo.width / 4
                    geo.y = sgeo.y

                    geo.width = sgeo.width * 2 / 4
                    geo.height = sgeo.height
                    c:geometry(geo)
                end
                client.focus = c
                c:raise()
            end,
            { description = "toggle floating", group = "client" }),

    awful.key({ modkey, "Control" },
        "Return",
        function(c)
            c:swap(awful.client.getmaster())
        end,
        { description = "move to master", group = "client" }),

    awful.key({ modkey },
        "i",
        function(c)
            c:move_to_screen(c.screen.index - 1)
        end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey },
        "o",
        function(c)
            c:move_to_screen()
        end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey },
        "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey },
        "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "maximize", group = "client" }))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = { description = "view tag #", group = "tag" }
        descr_toggle = { description = "toggle tag #", group = "tag" }
        descr_move = { description = "move focused client to tag #", group = "tag" }
        descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
    end
    globalkeys =
    my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey },
            "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            descr_view),
        -- Toggle tag display.
        awful.key({ modkey, "Control" },
            "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            descr_toggle),
        -- Move client to tag.
        awful.key({ modkey, "Shift" },
            "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" },
            "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            descr_toggle_focus))
end

-- Set up client management buttons FOR THE MOUSE.
-- (1 is left, 3 is right)
clientbuttons =
my_table.join(awful.button({},
    1,
    function(c)
        client.focus = c
        c:raise()
    end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    --[[  ]]
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred, --.focused(),
            -- placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            placement = awful.placement.no_offscreen,
            size_hints_honor = false
        }
    },
    -- Titlebars
    {
        rule_any = { type = { "dialog", "normal" } },
        -- properties = {titlebars_enabled = true}
        properties = { titlebars_enabled = true }
    },
    --     -- Set Firefox to always map on the first tag on screen 1.
    --     { rule = { class = "Firefox" },
    --       properties = { screen = 1, tag = awful.util.tagnames[1] } },

    {
        rule = { class = "Gimp", role = "gimp-image-window" },
        properties = { maximized = true }
    },
    -- https://youtrack.jetbrains.com/issue/IDEA-112015#focus=Comments-27-2797933.0-0
    {
        -- IntelliJ has dialogs, which shall not get focus, e.g. open type or open resource.
        -- These are Java Dialogs, which are not X11 Dialog Types.
        rule_any = {
            instance = { "sun-awt-X11-XWindowPeer", "sun-awt-X11-XDialogPeer", "keybase" }
        },
        properties = {
            focusable = false,
            placement = awful.placement.under_mouse+awful.placement.no_offscreen
        }
    },
    {
        -- IntelliJ has dialogs, which do not get focus, e.g. Settings Dialog or Paste Dialog.
        rule = {
            type = "dialog",
            instance = "sun-awt-X11-XDialogPeer"
        },
        properties = {
            focusable = true,
            focus = true
        }
    }

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage",
    function(c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end
    end)

-- https://www.reddit.com/r/awesomewm/comments/sok8dm/how_to_hide_titlebar/
--client.connect_signal("request::default_keybindings", function()
--    awful.keyboard.append_client_keybindings({
--        -- show/hide titlebar
--        awful.key({ modkey }, "t", awful.titlebar.toggle,
--                {description = "Show/Hide Titlebars", group="client"}),
--    })
--end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars",
    function(c)
        -- Custom
        if beautiful.titlebar_fun then
            beautiful.titlebar_fun(c)
            return
        end

        -- Default
        -- buttons for the titlebar
        local buttons =
        my_table.join(awful.button({},
            1,
            function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end),
            awful.button({},
                3,
                function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end))

        awful.titlebar(c, { size = 14 }):setup {
            {
                -- Left
                awful.titlebar.widget.iconwidget(c),
                wibox.widget.textbox(' '),
                awful.titlebar.widget.titlewidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            {
--                -- Middle
--                {
--                    -- Title
--                    align = "center",
--                    widget = awful.titlebar.widget.titlewidget(c)
--                },
                buttons = buttons,
                layout = wibox.layout.flex.horizontal
            },
            {
                -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                --awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter",
    function(c)
        local focused = client.focus
        local isJavaInstance = function(instance)
            -- xprop WM_CLASS
            -- WM_CLASS(STRING) = "sun-awt-X11-XFramePeer", "jetbrains-studio"

            -- THIS ONE IS THE ORIGINAL GOOD ONE:
            return instance and instance ~= "" and string.match(instance, '^sun-awt-X11-X')

            -- THIS ONE IS EXPERIMENTS:
            --return instance and instance ~= "" and string.match(instance, '^.*')
            --return true
        end
        if focused and focused.class == c.class
            and isJavaInstance(focused.instance)
            and isJavaInstance(c.instance) then
            return -- early
        end

        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

-- No border for maximized clients
function border_adjust(c)
    if c.maximized then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
    if c.focused then
        c.border_width = 30
    end
end

-- make rofi possible to raise minimized clients
client.connect_signal("request::activate",
    function(c, context, hints)
        if c.minimized then
            c.minimized = false
        end
        awful.ewmh.activate(c, context, hints)
    end)

client.connect_signal("focus", border_adjust)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end)

-- }}}

-- https://unix.stackexchange.com/questions/401539/how-to-disallow-any-application-from-stealing-focus-in-awesome-wm
--awful.ewmh.add_activate_filter(function() return false end, "ewmh")
--awful.ewmh.add_activate_filter(function() return false end, "rules")
