local util              = {}

util.debug_print_paths  = function(prefix, v)
	if v == nil then
		print(prefix, "<nil>")
	end
	for k, v in pairs(v) do
		if type(v) == "table" then
			print(prefix, k, "")
			util.debug_print_paths(prefix .. "\t", v)
			print(prefix)
		else
			print(prefix, k, v)
		end
	end
end

util.keycode_ui_aliases = {
	["cmd"]       = "⌘",
	["alt"]       = "⌥",
	["ctrl"]      = "⌃",
	["shift"]     = "⇧", -- Thank you Copilot.

	["mod4"]      = "⌘",
	["mod1"]      = "⌥",
	["control"]   = "⌃",

	["return"]    = "⏎",
	["tab"]       = "⇥",

	-- Thanks again Copilot.
	--["escape"]  = "⎋",
	["space"]     = "␣",
	[" "]         = "␣",
	["backspace"] = "⌫",
	["delete"]    = "⌦",
	--["home"]    = "↖",
	--["end"]     = "↘",
	--["pageup"]  = "⇞",
	--["pagedown"]= "⇟",

	--["left"]      = "←",
	--["right"]     = "→",
	--["up"]        = "↑",
	--["down"]      = "↓",
	["left"]      = "🠨",
	["right"]     = "🠪",
	["up"]        = "🠩",
	["down"]      = "🠫",

	["f1"]        = "F1",
	["f2"]        = "F2",
	["f3"]        = "F3",
	["f4"]        = "F4",
	["f5"]        = "F5",
	["f6"]        = "F6",
	["f7"]        = "F7",
	["f8"]        = "F8",
	["f9"]        = "F9",
	["f10"]       = "F10",
	["f11"]       = "F11",
	["f12"]       = "F12",
	["f13"]       = "F13",
	["f14"]       = "F14",
	["f15"]       = "F15",
	["f16"]       = "F16",
	["f17"]       = "F17",
	["f18"]       = "F18",
	["f19"]       = "F19",
	["f20"]       = "F20",
	["f21"]       = "F21",
	["f22"]       = "F22",
	["f23"]       = "F23",
	["f24"]       = "F24",
	["f25"]       = "F25",
	["f26"]       = "F26",
	["f27"]       = "F27",
	["f28"]       = "F28",
	["f29"]       = "F29",
	["f30"]       = "F30",
	["f31"]       = "F31",
	["f32"]       = "F32",
}

--lib.keycode_ui_aliases            = {
--	["return"]      = "RET",
--	["space"]       = "SPC",
--	[" "]           = "SPC",
--	["tab"]         = "TAB",
--	["escape"]      = "ESC",
--	["super_l"]     = "SUPER",
--	["delete"]      = "DEL",
--
--	-- Thanks Copilot.
--	["backspace"]   = "BS",
--	["left"]        = "←",
--	["right"]       = "→",
--	["up"]          = "↑",
--	["down"]        = "↓",
--	["home"]        = "HOME",
--	["end"]         = "END",
--	["page_up"]     = "PGUP",
--	["page_down"]   = "PGDN",
--	["insert"]      = "INS",
--	["print"]       = "PRTSC",
--	["pause"]       = "PAUSE",
--	["num_lock"]    = "NUM",
--	["scroll_lock"] = "SCR",
--	["caps_lock"]   = "CAPS",
--	["f1"]          = "F1",
--	["f2"]          = "F2",
--	["f3"]          = "F3",
--	["f4"]          = "F4",
--	["f5"]          = "F5",
--	["f6"]          = "F6",
--	["f7"]          = "F7",
--	["f8"]          = "F8",
--	["f9"]          = "F9",
--	["f10"]         = "F10",
--	["f11"]         = "F11",
--	["f12"]         = "F12",
--	["f13"]         = "F13",
--	["f14"]         = "F14",
--	["f15"]         = "F15",
--	["f16"]         = "F16",
--	["f17"]         = "F17",
--	["f18"]         = "F18",
--	["f19"]         = "F19",
--	["f20"]         = "F20",
--	["f21"]         = "F21",
--	["f22"]         = "F22",
--	["f23"]         = "F23",
--	["f24"]         = "F24",
--	["f25"]         = "F25",
--	["f26"]         = "F26",
--	["f27"]         = "F27",
--	["f28"]         = "F28",
--	["f29"]         = "F29",
--	["f30"]         = "F30",
--	["f31"]         = "F31",
--	["f32"]         = "F32",
--}

return util