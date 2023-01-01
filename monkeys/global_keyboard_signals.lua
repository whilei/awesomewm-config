local awesome = awesome

local function wrap(mod, fn, signal)
	local m        = require(mod)
	local original = m[fn]
	m[fn]          = function(...)
		local ret = original(...)
		awesome.emit_signal(signal, ...)
		return ret
	end
	print("[monkey] wrapping", mod, fn, signal)
end

wrap("awful.keyboard", "append_global_keybindings", "monkey::global_keybindings::added")
wrap("awful.keyboard", "append_global_keybinding", "monkey::global_keybinding::added")
wrap("awful.keyboard", "remove_global_keybinding", "monkey::global_keybinding::removed")
wrap("awful.keyboard", "remove_client_keybinding", "monkey::client_keybinding::removed")
