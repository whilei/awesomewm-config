local awful      = require("awful")
local client     = client
local keygrabber = keygrabber
local naughty    = require("naughty")
local pairs      = pairs
local beautiful  = require("beautiful")
local wibox      = require("wibox")

--module("hints")
local hints      = {
	--charorder = "jkluiopyhnmfdsatgvcewqzx1234567890",
	--charorder = "asetwdf0$*kgzxcvb",
	--charorder = "asetwdfqcxz0$*niohurlyj",
	charorder = "teaswdfbcgqkzx*niohurlyj",
	hintbox   = {} -- Table of letter wiboxes with characters as the keys
}

--function debuginfo( message )
--  nid = naughty.notify({ text = message, timeout = 10 })
--end

-- Create the wiboxes, but don't show them
function hints.init()
	hintsize        = 60
	local fontcolor = beautiful.fg_normal
	local letterbox = {}
	for i = 1, #hints.charorder do
		local char                 = hints.charorder:sub(i, i)

		--hints.hintbox[char] = wibox({
		--  fg=beautiful.fg_normal,
		--  bg=beautiful.bg_focus,
		--  border_color=beautiful.border_focus,
		--  border_width=beautiful.border_width})

		hints.hintbox[char]        = wibox({
											   --fg=beautiful.fg_normal,
											   --bg=beautiful.bg_focus,
											   --border_color=beautiful.border_focus,
											   --border_width=beautiful.border_width,
											   fg           = "#ffffff",
											   bg           = "#08158A", -- dark green, like a road sign
											   border_color = "#efefef",
											   border_width = "3",
										   })

		hints.hintbox[char].ontop  = true
		hints.hintbox[char].width  = hintsize
		hints.hintbox[char].height = hintsize
		letterbox[char]            = wibox.widget.textbox()
		letterbox[char]:set_markup("<span color=\"" .. "#ffffff" .. "\"" .. ">" .. char.upper(char) .. "</span>")
		letterbox[char]:set_font("dejavu sans mono 40")
		letterbox[char]:set_align("center")
		hints.hintbox[char]:set_widget(letterbox[char])
	end
end

function hints.focus()
	local hintindex  = {} -- Table of visible clients with the hint letter as the keys
	local clientlist = awful.client.visible()
	for i, thisclient in pairs(clientlist) do
		-- Move wiboxes to center of visible windows and populate hintindex
		local char                  = hints.charorder:sub(i, i)
		hintindex[char]             = thisclient
		local geom                  = thisclient.geometry(thisclient)
		hints.hintbox[char].visible = true
		hints.hintbox[char].x       = geom.x + geom.width / 2 - hintsize / 2
		hints.hintbox[char].y       = geom.y + geom.height / 2 - hintsize / 2
		--hints.hintbox[char].x = geom.x + hintsize/2
		--hints.hintbox[char].y = geom.y + hintsize/2
		hints.hintbox[char].screen  = thisclient.screen
	end
	keygrabber.run(function(mod, key, event)
		if event == "release" then
			return true
		end
		keygrabber.stop()
		if hintindex[key] then
			client.focus = hintindex[key]
			hintindex[key]:raise()
		end
		for i, j in pairs(hintindex) do
			hints.hintbox[i].visible = false
		end
	end)
end

return hints