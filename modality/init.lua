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

local string, table, ipairs     = string, table, ipairs
local awful                     = require("awful")
local gears                     = require("gears")
local modality_util             = require("modality.util")
local modality_widget           = require("modality.widget")

---------------------------------------------------------------------------

-- split_string splits a string on a separator and returns a table.
-- Empty values are returned as empty strings.
-- eg.
--  split_string("a:b:c", ":") == {"a", "b", "c"}
--  split_string("a::c", ":")  == {"a", "", "c"}
--  split_string("a", ":")     == {"a"}
-- https://stackoverflow.com/a/7615129
local split_string              = function(inputstr, sep)
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
local modality                  = {}
modality.widget                 = modality_widget

-- modality.paths establishes the paths table that modality will use.
-- It implicitly (for now) assigns defaults (coded below).
-- modality.register(keypath, fn) will add to this table.
--[[
paths = {
	label = "Modality",
	bindings = {
		["a"] = {
			label = "applications",
			fn = nil,
			bindings = {
				["h"] = {
					["k"] = function()
						-- do something
					end
				},
				["i"] = function()
					-- do something
				end
			}
		},
		["b"] = {
			label = "do things that starts with b",
			fn = function()
				-- do something
			end
			bindings = nil,
		}
		["c"] = {
			["d"] = function()
				-- do something
			end
		}
	},
}
]]
--]]
modality.path_tree              = {
	label    = "Modality",
	bindings = {
		["Escape"] = {
			label    = "exit",
			fn       = function()
				return true
			end,
			bindings = nil,
		},
		["?"]      = {
			label    = "search",
			fn       = function()
				modality.search_mode = true
				modality.widget.show_search(awful.screen.focused())
			end,
			bindings = nil,
			stay     = true,
		}
	},
}

modality.all_keypaths           = {
	-- { keypath, fn },
	-- { keypath, fn },
}

modality.search                 = function(query)
	modality.widget.search_mode(query)
end

-- Assign separator fields as non-local so they can be reassigned by the user.
modality.KEYPATH_SEPARATOR      = "," -- the separator between keypaths
modality.LABEL_SEPARATOR        = ":" -- the separator between keypath code:label
modality.STAY_IN_MODE_CHARACTER = "~" -- the character that will keep you in the mode, use as suffix to character

-- keypath_target_label returns the label (of some function)
-- that a keypath binding ultimately describes (the "target").
-- If no label is provided (eg. "a:awesome,h:help,k"), then an empty string is returned.
modality.keypath_target_label   = function(keypath)
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
modality.keypath_step_codes     = function(keypath)
	local decorated_steps = split_string(keypath, modality.KEYPATH_SEPARATOR)
	local steps           = {}
	for _, step in ipairs(decorated_steps) do
		local c = split_string(step, modality.LABEL_SEPARATOR)[1]:sub(1, 1)
		table.insert(steps, c)
	end
	return steps
end

modality.keypath_step_labels    = function(keypath)
	local decorated_steps = split_string(keypath, modality.KEYPATH_SEPARATOR)
	local steps           = {}
	for _, step in ipairs(decorated_steps) do
		-- TODO Get actual labels from the tree.
		-- We cannot assume that all keypaths registered use labels for all steps
		-- because modality has soft, implicit defaults for labels;
		-- so keypaths using implicit labels will not have them in this returned data.
		local c = split_string(step, modality.LABEL_SEPARATOR)[2]
		table.insert(steps, c)
	end
	return steps
end

-- keypaths_textfn_lines takes a query string and returns a list
-- of all matching keypaths and their functions in the form { txt, fn },
-- where txt is a formatted string describing the keypath in a human readable way.
modality.keypaths_textfn_lines  = function(matching)
	local lines = {}
	for _, keypath_fn in ipairs(modality.all_keypaths) do
		local keypath      = keypath_fn[1]
		local fn           = keypath_fn[2]
		local target_label = modality.keypath_target_label(keypath)
		local steps_labels = modality.keypath_step_labels(keypath)
		local codes        = modality.keypath_step_codes(keypath)
		local txt          = string.format("%s  [ %s ] ( %s )",
										   target_label,
										   table.join(codes, " "),
										   table.join(steps_labels, " "))

		if matching == nil or matching == "" or string.gfind(txt, matching) then
			table.insert(lines, txt)
		end
	end
	return lines
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

	assert(type(parent) == "table", "parent must be a table")
	assert(type(steps) == "string", "steps must be a string")
	assert(type(fn) == "function", "fn must be a function")

	-- Split the keypath into a table of steps.
	-- eg.
	-- nested: "a:applications,r:raise or spawn,f:firefox" => {"a:applications", "r:raise or spawn", "f:firefox"}
	-- flat: "i:hints"
	local steps_list = split_string(steps, modality.KEYPATH_SEPARATOR)

	assert(#steps_list > 0, "keypath must have at least one step")

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
		code = string.sub(code, 1, 1)
	end

	-- eg. "a~"

	if not parent.bindings then
		parent.bindings = {}
	end

	-- The parent bindings table does not have an entry at this key.
	-- Initialize it as a table.
	-- eg. "a" = { label = "applications", ... }
	if not parent.bindings[code] then
		parent.bindings[code] = {
			label    = label,
			stay     = stay,
			bindings = {},
			fn       = is_last and fn,
		}
		--parent.bindings[code].bindings = {}
	end

	-- Overwrite any label and function with the new one.
	parent.bindings[code].label = label
	parent.bindings[code].fn    = is_action and fn

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
	print("[modality] register", keypath, fn)
	register_keypath(modality.path_tree, keypath, fn)

	table.insert(modality.all_keypaths, { keypath, fn })
end

modality.init     = function()
	modality.widget.init(modality)
end

-- Docs: https://awesomewm.org/apidoc/core_components/awful.keygrabber.html
local function keypressed_callback(bindings_parent)
	return function(self, mods, key, event)
		print("[modality] keypressed", "event=", event, "key=", key, "mods=", mods, "sequence=", sequence)

		-- exit provides a handy exit function that
		-- stop the keygrabber and hides the widget.
		local function exit(reason)
			print("[modality] keypressed exiting: " .. reason)

			self:stop()
			modality.widget.hide(awful.screen.focused())
			return true
		end

		if event ~= "press" then
			return true
		end

		-- HACK: This is a hack to get around the fact that the keygrabber
		-- is still running, but I want the user input to go to the prompt box widget
		-- to execute the search.
		if modality.search_mode and key:lower() ~= "escape" then
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

		print "[modality] keypressed bindings_parent:"
		modality_util.debug_print_paths("[modality]", bindings_parent)

		local bound = bindings_parent.bindings[key]
		if not bound then
			-- TODO Show error? (Invalid binding, no such binding.)
			-- Exiting the mode seems like a harsh punishment for a typo...
			return exit("unmatched binding")
		end

		print("[modality] matched binding", "key=", key, "binding.label=", bound.label)
		modality_util.debug_print_paths("[modality]", bound)

		if bound.fn then
			print("[modality] matched binding has function, executing")

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
			print("[modality] entering submenu", "label=", bound.label, "#bindings=", #bound.bindings)

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
		print("[modality] already running, stopping")
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