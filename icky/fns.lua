---------------------------------------------------------------------------
-- Fns
--
-- Icky functions (for key bindings) and what to do with them.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod icky.fns
---------------------------------------------------------------------------

local client              = client
local handy               = require("handy")
local awful               = require("awful")
local naughty             = require("naughty")
local hints               = require("hints")

local fns                 = {
	apps       = {
		handy = {},
	},
	client     = {},
	screenshot = {},
	tag        = {
		next = awful.tag.viewnext,
		prev = awful.tag.viewprev,
	},
}

fns.apps.handy            = {
	top  = function()
		handy("ffox --class handy-top", awful.placement.top, 0.5, 0.5)
	end,
	left = function()
		handy("ffox --class handy-left", awful.placement.left, 0.25, 0.9)
	end,
}

fns.client.hints          = function()
	hints.focus();
	if not client.focus then
		return
	end
	client.focus:raise()
end

local screenshot_select   = "sleep 0.5 && scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' --quality 100 --silent --select --freeze --exec 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"
local screenshot_window   = "sleep 0.5 && scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' --quality 100 --silent --focused --exec 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"
local screenshot_notifier = function(typeof)
	return function()
		naughty.notify {
			text     = "Screenshot of " .. typeof .. " OK",
			timeout  = 2,
			bg       = "#058B04",
			fg       = "#ffffff",
			position = "bottom_middle",
		}
	end
end

fns.screenshot            = {
	selection = function()
		awful.util.mymainmenu:hide()
		awful.spawn.easy_async_with_shell(screenshot_select, screenshot_notifier("selection"))
	end,
	window    = function()
		awful.util.mymainmenu:hide()
		awful.spawn.easy_async_with_shell(screenshot_window, screenshot_notifier("window"))
	end
}

return fns