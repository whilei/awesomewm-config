local wibox = require("wibox")
local helpers  = require("lain.helpers")
local json     = require("lain.util").dkjson

local string   = string

local function factory(args)
    args = args or {}
    local mywidget = { widget = args.widget or wibox.widget.textbox() }
    local TOKEN = args.TOKEN or "xxxFIXMExxx"
    local myname = args.name or "The Widget That Does Stuff"
    local mylabelprefix = args.labelprefix or "Notifications: "
    local mycmd = args.cmd or "curl -s -H 'Authorization: token %s' 'https://api.github.com/notifications'"
    local timeout               = args.timeout or 60 * 15 -- 15 min

    local icons_path            = args.icons_path or helpers.icons_dir .. "mywidget/"


    -- Defaults
    local mywidget_textcontent_empty = "?"
    mywidget.widget:set_markup(mywidget_textcontent_empty)
    mywidget.icon_path = icons_path .. "na.png"
    mywidget.icon = wibox.widget.imagebox(mywidget.icon_path)

    local function error_display(resp_json)
        local err_resp = json.decode(resp_json)
        naughty.notify{
            title = myname .. ' Error',
            text = err_resp.message,
            preset = naughty.config.presets.critical,
        }
    end

    function mywidget.update()
        local cmd = string.format(mycmd, TOKEN)
        helpers.async(cmd, function(res)

            local err
            mywidget_response, _, err = json.decode(res, 1, nil)

            if err then
                -- Handle error.
                error_display(res)
                mywidget.widget:set_markup("!".. mywidget_textcontent_empty)
            else
                -- Response was OK (no error).
                local table_len = #mywidget_response
                mywidget.widget:set_markup(string.format("%s%d", mylabelprefix, table_len))

            end

            --mywidget.icon:set_image(icons_path .. "GitHub-128.png")
            mywidget.icon:set_image(icons_path .. "mark-github-border-128.png")

        end)
    end

    mywidget.timer = helpers.newtimer("mywidget-abc", timeout, mywidget.update, false, true)

    return mywidget
end

return factory