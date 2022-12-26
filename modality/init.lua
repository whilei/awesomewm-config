---------------------------------------------------------------------------
-- Modality
--
-- Modality is a library that allows you to create
-- leader-based modal keybindings (or "key paths", eg. "ahk" for "a" then "h" then "k"),
-- where only the terminal keybinding's function is executed, and all intermediate keybindings
-- are submenus.
-- It should look and feel just like Spacemacs.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod modality
---------------------------------------------------------------------------

local string, table, ipairs, pairs = string, table, ipairs, pairs
local awful                        = require("awful")
local gears                        = require("gears")
local naughty                      = require("naughty")
local modality_util                = require("modality.util")
local modality_widget              = require("modality.widget")

-- set to true to turn lots of prints on
local debug                        = false

-- toggles whether to print the list of all modality bindings for development reference
local develop_modality_list        = true

local function debug_print(args)
	if debug then
		print(args)
	end
end

---------------------------------------------------------------------------

-- split_string splits a string on a separator and returns a table.
-- Empty values are returned as empty strings.
-- eg.
--  split_string("a:b:c", ":") == {"a", "b", "c"}
--  split_string("a::c", ":")  == {"a", "", "c"}
--  split_string("a", ":")     == {"a"}
-- https://stackoverflow.com/a/7615129
local split_string                  = function(inputstr, sep)
	sep     = sep or '%s'
	local t = {}
	for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
		table.insert(t, field)
		if s == "" then
			return t
		end
	end
end

---------------------------------------------------------------------------

-- modality is the returned object.
local modality                      = {
	_did_calc_longest      = false,
	_longest_target_label  = 0,
	_longest_steps_label   = 0,
	_longest_steps_codes   = 0,
	_longest_hotkeys_label = 0,
}

modality.widget                     = modality_widget

local get_rofi_cmd                  = function(s)
	local tv_prompt     = "rofi -dmenu -p 'modality search' -i -show window -sidebar-mode -location 6 -theme Indego -width 40 -no-plugins -no-config"
	local laptop_prompt = "rofi -dmenu -p 'modality search' -i -show window -sidebar-mode -location 6 -theme Indego -width 60 -no-plugins -no-config"
	return s.is_tv and tv_prompt or laptop_prompt
end

-- search uses Rofi to search for a keybinding/command.
-- TODO Only show unique commands. (Currently dupes commands with multiple modality keypaths).
-- TODO Show awful hotkey bindings.
modality.search                     = function()
	modality.exit()

	-- Get all searchable keypaths and their functions.
	local text_lines = {}
	local keypaths   = {}
	local fns        = {}
	for _, keypath_fn in ipairs(modality.all_keypaths) do
		local keypath   = keypath_fn[1]
		local hotkeys   = keypath_fn[4]
		local fn        = keypath_fn[2]

		local text_line = modality.keypath_readable(keypath, hotkeys, true)
		-- Dedupe the text_lines.
		item_key        = gears.table.hasitem(fns, fn)
		if item_key ~= nil then
			-- Replace the existing text line (keypath, etc) if the current one is SHORTER.
			-- Shorter is preferred because it likely means that the user has configured
			-- something like a top-level "shortcut" shorter keybinding.
			local existing_keypath = keypaths[item_key]
			if #keypath < #existing_keypath then
				-- Replace all data types at that index.
				text_lines[item_key] = text_line
				keypaths[item_key]   = keypath
				fns[item_key]        = fn -- ...even though the function should be the same.
			else
				-- The existing entry(ies) are preferred to the iterated one.
				-- Noop.
				-- TODO Although we eventually do want to actually MERGE the text lines
				-- to be able to show ALL keypaths and ALL keybindings for some function.
			end
		else
			table.insert(text_lines, text_line)
			table.insert(keypaths, keypath)
			table.insert(fns, fn)
		end

	end

	local cmd = "echo '" ..
			table.concat(text_lines, "\n") ..
			"' | " ..
			get_rofi_cmd(awful.screen.focused())

	awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
		local function error(title, text)
			debug_print("[modality] rofi error", "title=", title, "text=", text)
			naughty.notify {
				preset  = naughty.config.presets.critical,
				title   = message,
				text    = stderr,
				timeout = 5,
			}
		end
		if exit_code == 0 then
			local choice = stdout:gsub("\n", "")
			debug_print("[modality] rofi choice=", choice)
			if choice ~= "" then
				-- Get the index of the text line.
				local item_key = gears.table.hasitem(text_lines, choice)
				if item_key then
					-- Get the function associated with the text line.
					local fn = fns[item_key]
					if fn then
						fn()
					else
						error("[modality] search", "keypath function was nil: " .. choice)
					end
				else
					return error("[modality] search", "Could not find function in table for choice: " .. choice)
				end
			else
				return error("[modality] search", "no choice selected")
			end
		else
			return error("[modality] search failed: " .. reason, stderr)
		end
	end)
end

-- modality.path_tree establishes the paths table (a tree) that modality will use.
-- It implicitly (for now) assigns defaults (coded below).
-- modality.register(keypath, fn) will add to this table.
modality.path_tree                  = {
	label    = "Modality",
	bindings = {
		["Escape"] = {
			label    = "exit",
			fn       = function()
				return true
			end,
			bindings = nil,
		},
		["Return"] = {
			label    = "search",
			fn       = modality.search,
			bindings = nil,
			stay     = false,
		},
		["?"]      = {
			label    = "search",
			fn       = modality.search,
			bindings = nil,
			stay     = false,
		}
	},
}

-- all_keypaths gets filled with the raw (decorate) keypaths from registered modality paths.
-- This provides a nice list paths:functions that can be used for searching more
-- easily than the tree.
modality.all_keypaths               = {
	-- { keypath, fn },
	-- { keypath, fn },
}

modality.develop_print_all_keypaths = function()
	if not develop_modality_list then
		return
	end
	debug_print("[modality] all_keypaths:")
	for _, keypath_fn in ipairs(modality.all_keypaths) do
		local keypath = keypath_fn[1]
		local hotkeys = keypath_fn[4]
		local fn      = keypath_fn[2]
		local text    = modality.keypath_readable(keypath, hotkeys, true)
		print("[modality]\t", text)
	end
end

-- Assign separator fields as non-local so they can be reassigned by the user.
modality.KEYPATH_SEPARATOR          = "," -- the separator between keypaths
modality.LABEL_SEPARATOR            = ":" -- the separator between keypath code:label
modality.STAY_IN_MODE_CHARACTER     = "~" -- the character that will keep you in the mode, use as suffix to character

-- keypath_target_label returns the label (of some function)
-- that a keypath binding ultimately describes (the "target").
-- If no label is provided (eg. "a:awesome,h:help,k"), then an empty string is returned.
modality.keypath_target_label       = function(keypath)
	-- Split keypath to get last element.
	local steps = split_string(keypath, modality.KEYPATH_SEPARATOR)
	if #steps == 0 then
		return ""
	end

	-- Get the last element from the keypath.
	local last_step = steps[#steps]
	return split_string(last_step, modality.LABEL_SEPARATOR)[2] or ""
end

-- keypath_step_codes takes a raw keypath (eg. "a:awesome,h:help,k") and returns a table of step codes (eg. {"a", "h", "k"}).
modality.keypath_step_codes         = function(keypath)
	local decorated_steps = split_string(keypath, modality.KEYPATH_SEPARATOR)
	local steps           = {}
	for _, step in ipairs(decorated_steps) do
		-- This logic needs to be mindful that not all keys (codes) are single-character, eg. Return, Tab, Escape, etc.
		local c = split_string(step, modality.LABEL_SEPARATOR)[1]
		if #c > 1 and string.find(c, "~") then
			c = c:sub(1, #c - 1)
		end
		table.insert(steps, c)
	end
	return steps
end

modality.keypath_step_labels        = function(keypath)
	local decorated_steps = split_string(keypath, modality.KEYPATH_SEPARATOR)
	local steps           = {}
	for _, step in ipairs(decorated_steps) do
		-- TODO Get actual labels from the tree.
		-- We cannot assume that all keypaths registered use labels for all steps
		-- because modality has soft, implicit defaults for labels;
		-- so keypaths using implicit labels will not have them in this returned data.
		local c = split_string(step, modality.LABEL_SEPARATOR)[2] or "???"
		table.insert(steps, c)
	end
	return steps
end

-- format_step_codes formats the step codes (eg. a, b ,c) into a human-readable string (eg. [ a b c ]).
local format_step_codes             = function(codes)
	-- →
	return string.format("[ %s ]", table.concat(codes, " "))
end

-- format_step_labels formats the step labels (eg. awesome, help, keybindings) into a human-readable string (eg. '( awesome help keybindings )').
local format_step_labels            = function(step_labels)
	return string.format("( %s )", table.concat(step_labels, " | "))
end

-- format_target_label formats the target label (eg. awesome) into a human-readable string (eg. 'awesome').
local format_fn_label               = function(target_label)
	return string.format("%s", target_label)
end

-- keyboard_key_labels is used for presenting the user with a human-readable version of a key stroke.
modality.keyboard_key_labels        = {
	["cmd"]       = "⌘ ",
	["alt"]       = "⌥ ",
	["ctrl"]      = "⌃ ",
	["shift"]     = "⇧ ", -- Thank you Copilot.

	["mod4"]      = "⌘ ",
	["mod1"]      = "⌥ ",
	["control"]   = "⌃ ",

	["return"]    = "⏎ ",
	["tab"]       = "⇥ ",

	-- Thanks again Copilot.
	--["escape"]  = "⎋ ",
	--["space"]   = "␣ ",
	["backspace"] = "⌫ ",
	["delete"]    = "⌦ ",
	--["home"]    = "↖ ",
	--["end"]     = "↘ ",
	--["pageup"]  = "⇞ ",
	--["pagedown"]= "⇟ ",

	--["left"]      = "← ",
	--["right"]     = "→ ",
	--["up"]        = "↑ ",
	--["down"]      = "↓ ",
	["left"]      = "🠨 ",
	["right"]     = "🠪 ",
	["up"]        = "🠩 ",
	["down"]      = "🠫 ",

	["f1"]        = "F1 ",
	["f2"]        = "F2 ",
	["f3"]        = "F3 ",
	["f4"]        = "F4 ",
	["f5"]        = "F5 ",
	["f6"]        = "F6 ",
	["f7"]        = "F7 ",
	["f8"]        = "F8 ",
	["f9"]        = "F9 ",
	["f10"]       = "F10 ",
	["f11"]       = "F11 ",
	["f12"]       = "F12 ",
}

-- format_hotkeys_label returns a string of hotkeys (eg. "⌘⇧⌥⌃") for a given keypath.
-- @hotkeys is a table
modality.format_hotkeys_label       = function(hotkeys)
	if not hotkeys or type(hotkeys) ~= "table" then
		return ""
	end
	local hotkeys_strings = {}
	for _, hotkey in ipairs(hotkeys) do
		local mods = hotkey.mods or {}
		local code = hotkey.code or ""
		if #mods == 0 and code == "" then
			-- no hotkey
			-- empty
		else
			for i, m in ipairs(mods) do
				mods[i] = modality.keyboard_key_labels[m:lower()] or m
			end
			local s = string.format("%s", table.concat(mods, "") .. "" .. (modality.keyboard_key_labels[code:lower()] or code))
			table.insert(hotkeys_strings, s)
		end
	end
	if #hotkeys_strings == 0 then
		return ""
	end
	return table.concat(hotkeys_strings, ",")
end

-- keypath_readable takes a raw keypath (eg. "t:tag,m:move,l:left")
-- and returns a readable keypath (eg. "left [ t m l ] ( tag move left ) ").
-- @aligned: a boolean whether to reference the global dictionary and try to align
-- fields nicely (based on longest values).
-- FIXME This function implicitly references the module registry "modality.all_keypaths" if align=true.
-- It has to do this to get the longest values as a reference maximum.
modality.keypath_readable           = function(keypath, hotkeys, aligned)
	if not aligned then
		local target_label = modality.keypath_target_label(keypath)
		local steps_labels = modality.keypath_step_labels(keypath)
		local codes        = modality.keypath_step_codes(keypath)
		return string.format("%s %s %s %s",
							 format_fn_label(target_label),
							 format_step_codes(codes),
							 modality.format_hotkeys_label(hotkeys),
							 format_step_labels(steps_labels))
	end
	-- else: aligned

	if not modality._did_calc_longest then
		for _, list_entry in ipairs(modality.all_keypaths) do
			local target_label              = format_fn_label(modality.keypath_target_label(list_entry[1]))
			local step_labels               = format_step_labels(modality.keypath_step_labels(list_entry[1]))
			local step_codes                = format_step_codes(modality.keypath_step_codes(list_entry[1]))
			local hotkeys_label             = modality.format_hotkeys_label(list_entry[4] or {}) or ""

			modality._longest_target_label  = math.max(modality._longest_target_label, #target_label)
			modality._longest_steps_label   = math.max(modality._longest_steps_label, #step_labels)
			modality._longest_steps_codes   = math.max(modality._longest_steps_codes, #step_codes)
			modality._longest_hotkeys_label = math.max(modality._longest_hotkeys_label, #hotkeys_label)
		end
		modality._did_calc_longest = true
	end

	local target_label  = format_fn_label(modality.keypath_target_label(keypath))
	local step_labels   = format_step_labels(modality.keypath_step_labels(keypath))
	local step_codes    = format_step_codes(modality.keypath_step_codes(keypath))
	local hotkeys_label = modality.format_hotkeys_label(hotkeys or {}) or ""

	return string.format("%s %s %s %s",
						 target_label .. string.rep(" ", modality._longest_target_label - #target_label),
						 step_codes .. string.rep(" ", modality._longest_steps_codes - #step_codes),
						 hotkeys_label .. string.rep(" ", modality._longest_hotkeys_label - #hotkeys_label),
						 step_labels .. string.rep(" ", modality._longest_steps_label - #step_labels)
	)

end

-- register_keypath is a recursive function that iterates through the keypath
-- and ultimately adds the function to the modality.paths map under the appropriately-nested
-- object, eg. modality.paths.bindings["a"].bindings["h"].bindings["k"] = { fn = fn, label = "label" }
local function register_keypath(parent, steps, fn_press, _, hotkeys, data)

	assert(type(parent) == "table", "[modality] parent must be a table")
	assert(type(steps) == "string", "[modality] steps must be a string")
	-- Revelation is a table, not a function. I think metatables are lurking.
	assert(type(fn_press) == "function" or type(fn_press) == "table", "[modality] fn must be a function, steps=" .. steps)

	-- Split the keypath into a table of steps.
	-- eg.
	-- nested: "a:applications,r:raise or spawn,f:firefox" => {"a:applications", "r:raise or spawn", "f:firefox"}
	-- flat: "i:hints"
	local steps_list = split_string(steps, modality.KEYPATH_SEPARATOR)

	assert(#steps_list > 0, "[modality] keypath must have at least one step")

	-- Parse the keypath:obj into our bindings tree.

	local is_fn      = #steps_list == 1
	local first_step = steps_list[1]

	local spl        = split_string(first_step, modality.LABEL_SEPARATOR)
	-- "a:applications" => {"a", "applications"}
	-- "r:raise or spawn" => {"r", "raise or spawn"}
	-- "f:firefox" => {"f", "firefox"}

	local code       = spl[1]
	local stay       = false
	local label      = spl[2] or "???"

	-- Decode the character that if suffixed to the characters means: Stay in Mode.
	-- If true, reassign the variable.
	-- eg. "a~"
	local stay_i, _  = string.find(code, modality.STAY_IN_MODE_CHARACTER, 1, true)
	if stay_i ~= nil and stay_i == 2 then
		stay = true
		-- Clean up the dangling '~' character.
		code = string.sub(code, 1, #code - 1)
	end

	-- eg. "a~"

	if not parent.bindings then
		parent.bindings   = {}
		parent.n_bindings = 0
	end

	-- The parent bindings table does not have an entry at this key.
	-- Initialize it as a table.
	-- eg. "a" = { label = "applications", ... }
	if not parent.bindings[code] then
		parent.bindings[code] = {
			label         = label,
			stay          = stay,
			bindings      = is_fn and nil or {},
			fn            = is_fn and fn_press,
			hotkeys       = is_fn and hotkeys,
			hotkeys_label = is_fn and modality.format_hotkeys_label(hotkeys),
			data          = is_fn and data,
		}
	end

	parent.n_bindings = #gears.table.keys(parent.bindings)

	if not is_fn then
		-- Recurse.
		-- We remove the first element from the steps list because we've already processed it.
		local remaining_steps = table.concat(steps_list, modality.KEYPATH_SEPARATOR, 2)
		register_keypath(parent.bindings[code], remaining_steps, fn_press, _, hotkeys, data)
	end
end

-- register registers a keypath (eg. "ahk") to a function.
-- @keypath: the keypath to register
-- @fn: the function to execute when the keypath is completed
-- @stay: boolean: whether the keygrabber should exit/exist after the first use.
modality.register = function(keypath, fn_press, fn_release, hotkeys, data)
	debug_print("[modality] register", keypath, fn_press)
	register_keypath(modality.path_tree, keypath, fn_press, fn_release, hotkeys, data)

	table.insert(modality.all_keypaths, { keypath, fn_press, fn_release, hotkeys, data })
end

modality.init     = function()
	modality.widget.init(modality)
end

--function copy(obj, seen)
--	if type(obj) ~= 'table' then
--		return obj
--	end
--	if seen and seen[obj] then
--		return seen[obj]
--	end
--	local s   = seen or {}
--	local res = setmetatable({}, getmetatable(obj))
--	s[obj]    = res
--	for k, v in pairs(obj) do
--		res[copy(k, s)] = copy(v, s)
--	end
--	return res
--end


-- Docs: https://awesomewm.org/apidoc/core_components/awful.keygrabber.html
local function keypressed_callback(bindings_parent)
	--local sequence = ""
	return function(self, mods, key, event)
		--sequence = sequence .. key
		print("[modality] keypressed", "event=", event, "key=", key, "mods=", mods)

		-- exit provides a handy exit function that
		-- stop the keygrabber and hides the widget.
		local function exit(reason)
			debug_print("[modality] keypressed exiting: " .. reason)

			self:stop()
			modality.widget.hide(awful.screen.focused())
			return true
		end

		if event ~= "press" then
			return true
		end

		if key == "Escape" then
			return exit("Escape")
		end

		-- Without bindings we can't do anything.
		if not bindings_parent.bindings then
			-- TODO Show error? (No list of bindings.)
			return exit("no bindings")
		end

		-- This happens, for example, when the user wants L and pressed
		-- L_SHIFT to get an uppercase L.
		-- Other modifiers are not checked because I haven't had problems with them yet.
		if (not key) or (key == "") or (string.find(key:lower(), "shift")) then
			-- Returning true keeps the keygrabber running (and the widget visible).
			return true
		end

		debug_print("[modality] keypressed bindings_parent:")
		if debug then
			modality_util.debug_print_paths("[modality]", bindings_parent)
		end

		local bound = bindings_parent.bindings[key]
		if not bound then
			-- -- Option 1: Exit immediately if binding is unmatched.
			-- Exiting the mode seems like a harsh punishment for a typo...
			--return exit("unmatched binding")

			-- Option 2: Show error (invalid binding) and keep the mode running.
			local n = naughty.notification {
				text     = "Invalid binding: " .. key .. " (Use ESC to exit.)",
				timeout  = 0.75,
				position = "bottom_middle",
				bg       = "#ff0000",
				fg       = "#ffffff",
			}
			--awful.placement.next_to(n, {
			--	mode                = "geometry_inside",
			--	preferred_positions = { "top", "right", "left", "bottom" },
			--	preferred_anchors   = { "middle", "front", "back" },
			--	geometry            = modality_widget.get_widget(awful.screen.focused()):geometry(),
			--})
			return true
		end

		debug_print("[modality] matched binding", "key=", key, "binding.label=", bound.label)
		if debug then
			modality_util.debug_print_paths("[modality]", bound)
		end

		if bound.fn then
			debug_print("[modality] matched binding has function, executing")

			if bindings_parent.stay or bound.stay then
				bound.fn()
				return true
			else
				self:stop()
				modality.widget.hide(awful.screen.focused())
				bound.fn()
				return false -- call the function and return its result
			end

		elseif bound.bindings then
			debug_print("[modality] entering submenu", "label=", bound.label, "#bindings=", #bound.bindings)

			self:stop()
			modality.enter(bound)
			return true

		else
			-- Should be nearly usually mostly probably unreachable.
			exit("no fn or bindings!")
		end
	end
end

-- enter enters the modality mode.
-- @bindings_parent: the parent bindings object to start with.
--   This object should have {label, bindings} fields.
modality.enter = function(bindings_parent)
	local s = awful.screen.focused()

	if modality.kg and modality.kg.is_running then
		debug_print("[modality] already running, stopping")
		modality.widget.hide(s)
		modality.kg:stop()
		modality.kg = nil
	end

	--local stop_keys = gears.table.keys(bindings_parent.bindings)
	--
	---- TODO: This is a hack to make the keygrabber stop when the user presses Escape according to Copilot.
	---- Other 'special' keys could also be added here.
	--if not gears.table.hasitem(stop_keys, "Escape") then
	--	table.insert(stop_keys, "Escape") -- Exit mode.
	--end
	--if not gears.table.hasitem(stop_keys, "?") then
	--	table.insert(stop_keys, "?") -- Show (interactive) help mode.
	--end

	modality.kg = awful.keygrabber {
		-- Start the grabbing immediately.
		autostart           = true,

		-- The event on which the keygrabbing will be terminated.
		--stop_event    = "press",

		-- The key on which the keygrabber listen to terminate itself.
		--stop_key      = stop_keys,

		---- If any key is pressed that is not in this list, the keygrabber is stopped.
		--allowed_keys  = gears.table.keys(bindings_parent.bindings),

		-- The callback when the keygrabbing stops.
		keypressed_callback = keypressed_callback(bindings_parent),
	}

	modality.widget.show(s, bindings_parent)

end

modality.exit  = function()
	modality.widget.hide(awful.screen.focused())
end

return modality

--return setmetatable(modality, {
--	__call = function(_, args)
--		args = args or {}
--		return modality.init()
--	end
--})