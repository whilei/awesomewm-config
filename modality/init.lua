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

local string, table, ipairs = string, table, ipairs
local awful                 = require("awful")
local gears                 = require("gears")
local naughty               = require("naughty")
local modality_util         = require("modality.util")
local modality_widget       = require("modality.widget")

-- set to true to turn lots of prints on
local debug                 = false

-- toggles whether to print the list of all modality bindings for development reference
local develop_modality_list = true

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
local modality                      = {}
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
		local fn        = keypath_fn[2]
		local text_line = modality.keypath_readable(keypath, true)

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
		local fn      = keypath_fn[2]
		local text    = modality.keypath_readable(keypath, true)
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
local format_target_label           = function(target_label)
	return string.format("%s", target_label)
end

-- keypath_readable takes a raw keypath (eg. "t:tag,m:move,l:left")
-- and returns a readable keypath (eg. "left [ t m l ] ( tag move left ) ").
-- @aligned: a boolean whether to reference the global dictionary and try to align
-- fields nicely (based on longest values).
-- FIXME This function implicitly references the module registry "modality.all_keypaths" if align=true.
-- It has to do this to get the longest values as a reference maximum.
modality.keypath_readable           = function(keypath, aligned)
	if not aligned then
		local target_label = modality.keypath_target_label(keypath)
		local steps_labels = modality.keypath_step_labels(keypath)
		local codes        = modality.keypath_step_codes(keypath)
		return string.format("%s %s %s",
							 format_target_label(target_label),
							 format_step_codes(codes),
							 format_step_labels(steps_labels))
	end
	-- else: aligned
	local _longest_target_label, _longest_steps_label, _longest_steps_codes = 0, 0, 0

	for _, keypath_fn in ipairs(modality.all_keypaths) do
		local target_label    = format_target_label(modality.keypath_target_label(keypath_fn[1]))
		local step_labels     = format_step_labels(modality.keypath_step_labels(keypath_fn[1]))
		local step_codes      = format_step_codes(modality.keypath_step_codes(keypath_fn[1]))
		_longest_target_label = math.max(_longest_target_label, #target_label)
		_longest_steps_label  = math.max(_longest_steps_label, #step_labels)
		_longest_steps_codes  = math.max(_longest_steps_codes, #step_codes)
	end

	local target_label = format_target_label(modality.keypath_target_label(keypath))
	local step_labels  = format_step_labels(modality.keypath_step_labels(keypath))
	local step_codes   = format_step_codes(modality.keypath_step_codes(keypath))

	return string.format("%s %s %s",
						 target_label .. string.rep(" ", _longest_target_label - #target_label),
						 step_codes .. string.rep(" ", _longest_steps_codes - #step_codes),
						 step_labels .. string.rep(" ", _longest_steps_label - #step_labels))

end

---- get_all_keypaths returns a table of all keypaths.
--local function get_all_keypaths(paths, prefix)
--	prefix         = prefix or ""
--	local keypaths = {}
--	for key, binding in pairs(paths.bindings) do
--		local keypath = prefix .. key
--		if binding.bindings then
--			local sub_keypaths = get_all_keypaths(binding, keypath .. modality.keypath_separator)
--			for _, sub_keypath in ipairs(sub_keypaths) do
--				table.insert(keypaths, sub_keypath)
--			end
--		else
--			table.insert(keypaths, keypath)
--		end
--	end
--	return keypaths
--end

-- register_keypath is a recursive function that iterates through the keypath
-- and ultimately adds the function to the modality.paths map under the appropriately-nested
-- object, eg. modality.paths.bindings["a"].bindings["h"].bindings["k"] = { fn = fn, label = "label" }
local function register_keypath(parent, steps, fn)

	assert(type(parent) == "table", "[modality] parent must be a table")
	assert(type(steps) == "string", "[modality] steps must be a string")
	--assert(type(fn) == "function", "[modality] fn must be a function, steps=" .. steps) -- FIXME Revelation fails this.

	-- Split the keypath into a table of steps.
	-- eg.
	-- nested: "a:applications,r:raise or spawn,f:firefox" => {"a:applications", "r:raise or spawn", "f:firefox"}
	-- flat: "i:hints"
	local steps_list = split_string(steps, modality.KEYPATH_SEPARATOR)

	assert(#steps_list > 0, "[modality] keypath must have at least one step")

	-- Parse the keypath:obj into our bindings tree.

	local is_last    = #steps_list == 1
	local first_step = steps_list[1]

	local is_action  = is_last and fn ~= nil

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

	--assert(((is_action) and (not parent.bindings[code]) or (not is_action)),
	--	   "[modality] keypath already exists: " ..
	--			   "code=" .. code .. " label=" .. label ..
	--			   "existing.label=" .. parent.bindings[code].label or "???")

	-- The parent bindings table does not have an entry at this key.
	-- Initialize it as a table.
	-- eg. "a" = { label = "applications", ... }
	if not parent.bindings[code] then
		parent.bindings[code] = {
			label    = label,
			stay     = stay,
			bindings = is_action and nil or {},
			fn       = is_action and fn,
		}
	end

	parent.n_bindings = #gears.table.keys(parent.bindings)

	if not is_action then
		-- Recurse.
		-- We remove the first element from the steps list because we've already processed it.
		local remaining_steps = table.concat(steps_list, modality.KEYPATH_SEPARATOR, 2)
		register_keypath(parent.bindings[code], remaining_steps, fn)
	end
end

-- register registers a keypath (eg. "ahk") to a function.
-- @keypath: the keypath to register
-- @fn: the function to execute when the keypath is completed
-- @stay: boolean: whether the keygrabber should exit/exist after the first use.
modality.register = function(keypath, fn)
	debug_print("[modality] register", keypath, fn)
	register_keypath(modality.path_tree, keypath, fn)

	table.insert(modality.all_keypaths, { keypath, fn })
end

modality.init     = function()
	modality.widget.init(modality)
end

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
			-- TODO Show error? (Invalid binding, no such binding.)
			-- Exiting the mode seems like a harsh punishment for a typo...
			return exit("unmatched binding")
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

	modality.widget.show(s, bindings_parent)

	local stop_keys = gears.table.keys(bindings_parent.bindings)

	-- TODO: This is a hack to make the keygrabber stop when the user presses Escape according to Copilot.
	-- Other 'special' keys could also be added here.
	if not gears.table.hasitem(stop_keys, "Escape") then
		table.insert(stop_keys, "Escape") -- Exit mode.
	end
	if not gears.table.hasitem(stop_keys, "?") then
		table.insert(stop_keys, "?") -- Show (interactive) help mode.
	end

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