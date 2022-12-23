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

-- c api libs
local client               = client

-- awesome libs
local awful                = require("awful")
local naughty              = require("naughty")

-- contrib
local handy                = require("handy")
local hints                = require("hints")
local revelation           = require("revelation")

---------------------------------------------------------------------------

local fns                  = {
	awesome    = {
		show_mainmenu = function()
			awful.util.mymainmenu:show()
		end,
	},
	apps       = {
		handy = {
			top  = function()
				handy("ffox --class handy-top", awful.placement.top, 0.5, 0.5)
			end,
			left = function()
				handy("ffox --class handy-left", awful.placement.left, 0.25, 0.9)
			end,
		},
	},
	client     = {
		focus      = {
			index     = {
				next = function()
					awful.client.focus.byidx(1)
				end,
				prev = function()
					awful.client.focus.byidx(-1)
				end
			},
			direction = {
				up    = function()
					awful.client.focus.global_bydirection("up")
					if client.focus then
						client.focus:raise()
					end
				end,
				down  = function()
					awful.client.focus.global_bydirection("down")
					if client.focus then
						client.focus:raise()
					end
				end,
				left  = function()
					awful.client.focus.global_bydirection("left")
					if client.focus then
						client.focus:raise()
					end
				end,
				right = function()
					awful.client.focus.global_bydirection("right")
					if client.focus then
						client.focus:raise()
					end
				end,
			}
		},
		hints      = function()
			hints.focus();
			if client.focus then
				client.focus:raise()
			end
		end,
		revelation = revelation,
	},
	screenshot = {},
	tag        = {
		next    = awful.tag.viewnext,
		prev    = awful.tag.viewprev,
		restore = awful.tag.history.restore,
	},
}

-- {{{ SCREENSHOT
local screenshot_selection = "sleep 0.5 && scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' --quality 100 --silent --select --freeze --exec 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"
local screenshot_window    = "sleep 0.5 && scrot '%Y-%m-%d-%H%M%S_$wx$h_screenshot.png' --quality 100 --silent --focused --exec 'xclip -selection clipboard -t image/png -i $f;mv $f ~/Pictures/screenshots/'"

-- FIXME:The notifier doesnt work quite right when having done multiple screenshots in a row.
local screenshot_notifier  = function(args)
	return function()
		naughty.notify {
			text     = "Screenshot of " .. (args.label or "???") .. " OK",
			timeout  = 2,
			bg       = "#058B04",
			fg       = "#ffffff",
			position = "bottom_middle",
		}
	end
end

fns.screenshot             = {
	selection = function()
		awful.util.mymainmenu:hide()
		awful.spawn.easy_async_with_shell(
				screenshot_selection,
				screenshot_notifier { label = "selection" }
		)
	end,
	window    = function()
		awful.util.mymainmenu:hide()
		awful.spawn.easy_async_with_shell(
				screenshot_window,
				screenshot_notifier { label = "window" }
		)
	end
}
-- }}}

return fns