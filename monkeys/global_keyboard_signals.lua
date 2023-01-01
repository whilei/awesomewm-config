local awesome                                  = awesome
local awful_keyboard                           = require("awful.keyboard")

local awful_keyboard_append_global_keybindings = awful_keyboard.append_global_keybindings
awful_keyboard.append_global_keybindings       = function(keybindings)
	awful_keyboard_append_global_keybindings(keybindings)
	awesome.emit_signal("monkey::global_keybindings::added", keybindings)
end
print("[monkey] +signal awful.keyboard.append_global_keybindings -> monkey::global_keybindings::add")

local awful_keyboard_append_global_keybinding = awful_keyboard.append_global_keybinding
awful_keyboard.append_global_keybinding       = function(keybinding)
	awful_keyboard_append_global_keybinding(keybinding)
	awesome.emit_signal("monkey::global_keybinding::added", keybinding)
end
print("[monkey] +signal awful.keyboard.append_global_keybinding -> monkey::global_keybinding::add")

local awful_keyboard_remove_global_keybinding = awful_keyboard.remove_global_keybinding
awful_keyboard.remove_global_keybinding       = function(keybinding)
	awful_keyboard_remove_global_keybinding(keybinding)
	awesome.emit_signal("monkey::global_keybinding::removed", keybinding)
end
print("[monkey] +signal awful.keyboard.remove_global_keybinding -> monkey::global_keybinding::remove")
