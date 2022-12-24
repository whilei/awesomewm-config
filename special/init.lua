---------------------------------------------------------------------------
-- Special
--
-- Special functions and (variable) instances that are primarily for me and how I like things.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod special
---------------------------------------------------------------------------

local client = client
local awful  = require("awful")
local lain   = require("lain")
local gears  = require("gears")

-- focus_previous_client_global is a function that returns the last
-- focused client _anywhere_.
-- It accesses the history list directly to
-- get the global history.
-- The usual function for "going back" (eg. Mod4+Tab),
-- uses awful.client.focus.history.previous(), which
-- (I assume) filters the history list, limiting the
-- clients to those of the same tag as the current client.
-- This is not what we want here.
-- I want to go back in history globally; no matter the tag or the screen.
-- Copy-pasta from https://unix.stackexchange.com/questions/623337/how-to-jump-to-previous-window-in-history-in-awesome-wm
local function focus_previous_client_global()

	local c = awful.client.focus.history.list[2]

	local t = c and c.first_tag or nil
	if t then
		t:view_only()
	end
	client.focus = c
	c.visible    = true -- Except this, I added this.
	c:raise()
end

local quake             = lain.util.quake({
											  app             = "konsole",
											  name            = "xterm-konsole",
											  extra           = "--hide-menubar --hide-tabbar",
											  followtag       = true,
											  vert            = "bottom",
											  keepclientattrs = true,
											  border          = 0,
											  settings        = function(client)
												  -- these don't work. don't know why.
												  client.opacity           = 0.7
												  client.border_color      = gears.color.parse_color("#ff0000ff")
												  client.titlebars_enabled = false
												  client.skip_taskbar      = true

												  local geo
												  geo                      = client:geometry()
												  if geo.width > 2000 then
													  geo.x     = geo.x + (geo.width / 4)
													  geo.width = geo.width / 2
													  client:geometry(geo)
												  end
											  end
										  })

local toggle_wibar_slim = function()
	local s = awful.screen.focused()
	if s.mywibox then
		s.mywibox.visible = not s.mywibox.visible
	end
	if s.mywibox and s.mywibox_slim then
		s.mywibox_slim.visible = not s.mywibox.visible
	end

end

return {
	focus_previous_client_global = focus_previous_client_global,
	quake                        = quake,
	popup_launcher               = require("special.popup-launcher"),
	toggle_wibar_slim            = toggle_wibar_slim,
}