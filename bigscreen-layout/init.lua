--[[

ISAACs layout for the big screen.

I want:

* left top bottom right

|2---|3_______|4----|
|----|________|-----|
|----|--------|-----|
|----|1_______|-----|
|----|________|-----|

This layout ONLY HANDLES 4 clients.
Any number of clients on a tag beyond 4 will be ignored by this layout.

--]]

local ipairs = ipairs
local math = math
local capi =
{
	client = client,
	screen = screen,
	mouse = mouse,
	mousegrabber = mousegrabber
}

local bigscreen = {
	name = "bigscreen"
}

local function arrange(p, layout)
	local wa  = p.workarea
	local cls = p.clients
	local t   = p.tag or capi.screen[p.screen].selected_tag


	-- Ultimately this module wants to assign
	-- values to p.geometries[<client>]

	if #cls == 0 then return end

	-- ac is a client
	local ac = cls[1]
	p.geometries[ac] = {
		height = wa.height / 2,
		width = wa.width / 2,
		y = wa.y + wa.height / 2,
		x = wa.x + wa.width / 2 / 2,
	}
	if #cls == 1 then return end

	ac = cls[2]
	p.geometries[ac] = {
		height = wa.height,
		width = wa.width / 2 / 2,
		y = wa.y,
		x = wa.x,
	}
	if #cls == 2 then return end

	ac = cls[3]
	p.geometries[ac] = {
		height = wa.height / 2,
		width = wa.width / 2,
		y = wa.y,
		x = wa.x + wa.width / 2 / 2,
	}
	if #cls == 3 then return end

	ac = cls[4]
	p.geometries[ac] = {
		height = wa.height,
		width = wa.width / 2 / 2,
		y = wa.y,
		x = wa.x + wa.width - (wa.width / 2 / 2),
	}
	if #cls >= 4 then return end

end

function bigscreen.arrange(p)
	return arrange(p, bigscreen)
end

return bigscreen