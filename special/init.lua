local awful  = require("awful")
local client = client

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

return {
	focus_previous_client_global = focus_previous_client_global,
}