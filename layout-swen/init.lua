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
	local wa                       = p.workarea
	local cls                      = p.clients
	local t                        = p.tag or capi.screen[p.screen].selected_tag

	local south, west, east, north = 1, 2, 3, 4

	local mwfact                   = t.master_width_factor
	local main_width               = math.floor(wa.width * mwfact)
	local main_height              = (#cls < 4) and math.floor(wa.height * 3 / 4) or math.floor(wa.height / 2)

	local slave_width_ew           = (wa.width - main_width) / 2 -- sides a,b
	local slave_width_n            = main_width

	local wa_bottom                = wa.y + wa.height
	local wa_right                 = wa.x + wa.width

	for i, cl in ipairs(cls) do
		if i == south then
			p.geometries[cl] = {
				height = main_height,
				width  = main_width,
				y      = wa_bottom - main_height,
				x      = wa.x + slave_width_ew,
			}
		elseif i == west then
			p.geometries[cl] = {
				height = wa.height,
				width  = slave_width_ew,
				y      = wa.y,
				x      = wa.x,
			}
		elseif i == east then
			p.geometries[cl] = {
				height = wa.height,
				width  = slave_width_ew,
				y      = wa.y,
				x      = wa_right - slave_width_ew,
			}
		elseif i == north then
			p.geometries[cl] = {
				height = wa.height - main_height,
				width  = main_width,
				y      = wa.y,
				x      = wa.x + slave_width_ew,
			}
		else
			-- What to do with the rest of the clients?

		end
	end
end

function swen.arrange(p)
	return arrange(p, swen)
end

return swen