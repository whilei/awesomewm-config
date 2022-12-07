--[[

ISAACs layout for tall columns.

I want:

* left top bottom right

|1---|2---|3---|4---|
|----|----|----|----|
|----|----|----|----|
|----|----|----|----|
|----|----|----|----|

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

local vcolumns = {
	name = "vcolumns"
}

local function arrange(p, layout)
	local wa  = p.workarea
	local cls = p.clients
	local t   = p.tag or capi.screen[p.screen].selected_tag


	-- Ultimately this module wants to assign
	-- values to p.geometries[<client>]

	if #cls == 0 then return end

	-- Define column width.
	-- Maximum should be at most 1/3 the work area width.
	local col_w = wa.width / #cls
	col_w = math.min(col_w, wa.width / 3)

	for i = 1, #cls do
		local c, g = cls[i], {}

		g.width = col_w
		g.height = wa.height

		g.y = wa.y
		g.x = ((i-1) * col_w) + wa.x

		p.geometries[c] = g
	end
end

function vcolumns.arrange(p)
	return arrange(p, vcolumns)
end

return vcolumns