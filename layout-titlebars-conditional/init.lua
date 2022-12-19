--[[
	This module wraps some parent layout,
	augmenting it so that if some condition is met (see below, default is IF only 1 client)
	then the clients titlebars are hidden or shown.
--]]

local ipairs = ipairs
local awful  = require("awful")

local function factory(args)
	local ret  = {}
	local args = args or {
		layout = awful.layout.suit.tile,
	}
	ret.name   = args.layout.name
	ret.layout = args.layout
	function ret.arrange(p)
		ret.layout.arrange(p, ret.layout)

		-- Define our condition for showing vs. hiding titlebars.
		local want_titlebars = #p.clients > 1

		for _, cl in ipairs(p.clients) do
			if want_titlebars then
				awful.titlebar.show(cl)
			else
				awful.titlebar.hide(cl)
			end
		end
	end
	return ret
end

return factory