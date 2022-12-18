--[[

ISAACs layout for the big screen.

I want:

- For 4 clients:

|2---|4_______|3----|
|2---|4_______|3----|
|2---|1_______|3----|
|2---|1_______|3----|

- For 1, 2, or 3 clients:

|2---|        |3----|
|2---|1_______|3----|
|2---|1_______|3----|
|2---|1_______|3----|
|2---|1_______|3----|

- For 1 client:

|    |        |     |
|--|1___________|---|
|--|1___________|---|
|--|1___________|---|
|--|1___________|---|


This layout ONLY HANDLES 4 clients.
Any number of clients on a tag beyond 4 will be ignored by this layout.

--]]

local ipairs = ipairs
local math   = math
local capi   = {
	client       = client,
	screen       = screen,
	mouse        = mouse,
	mousegrabber = mousegrabber
}

local swen   = {
	name = "SWEN"
}

local function arrange(p, layout)
	local wa  = p.workarea
	local cls = p.clients
	local t   = p.tag or capi.screen[p.screen].selected_tag

	-- 1: South
	-- 2: West
	-- 3: East
	-- 4: North

	if #cls == 0 then
		return
	end

	-- ac is a client
	-- South:
	local south_client         = cls[1]
	p.geometries[south_client] = {
		height = wa.height / 3 * 2,
		width  = wa.width / 3 * 2,
		y      = wa.y + wa.height / 3,
		x      = wa.x + wa.width / 3 / 2,
	}
	if #cls == 1 then
		return
	end

	-- There are more than 1 clients.

	-- Make 'south' positioned client (the first one)
	-- skinnier than it would be if it were the only client.
	-- This allows room for the West client.
	p.geometries[south_client] = {
		height = wa.height / 3 * 2, -- stays the same
		width  = wa.width / 2,
		y      = wa.y + wa.height / 3,
		x      = wa.x + wa.width / 2 / 2,
	}

	-- West:
	local west_client          = cls[2]
	p.geometries[west_client]  = {
		height = wa.height,
		width  = wa.width / 2 / 2,
		y      = wa.y,
		x      = wa.x,
	}
	if #cls == 2 then
		return
	end

	-- East:
	local east_client         = cls[3]
	p.geometries[east_client] = {
		height = wa.height,
		width  = wa.width / 2 / 2,
		y      = wa.y,
		x      = wa.x + wa.width / 2 / 2 * 3,
	}
	if #cls == 3 then
		return
	end

	-- North:
	local north_client         = cls[4]
	p.geometries[north_client] = {
		height = wa.height / 2,
		width  = wa.width / 2,
		y      = wa.y,
		x      = wa.x + wa.width / 2 / 2,
	}
	p.geometries[south_client] = {
		height = wa.height / 2,
		width  = wa.width / 2,
		y      = wa.y + wa.height / 2,
		x      = wa.x + wa.width / 2 / 2,
	}

	if #cls >= 4 then
		return
	end

end

function swen.arrange(p)
	return arrange(p, swen)
end

return swen