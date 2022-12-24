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

local string, table, ipairs   = string, table, ipairs
local awful                   = require("awful")
local gears                   = require("gears")
local modality_util           = require("modality.util")

---------------------------------------------------------------------------

-- split_string splits a string on a separator and returns a table.
-- Empty values are returned as empty strings.
-- eg.
--  split_string("a:b:c", ":") == {"a", "b", "c"}
--  split_string("a::c", ":")  == {"a", "", "c"}
--  split_string("a", ":")     == {"a"}
-- https://stackoverflow.com/a/7615129
local split_string            = function(inputstr, sep)
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
local modality                = {}
modality.widget               = require("modality.widget")

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
modality.paths                = {
	label    = "Modality",
	bindings = {
		["Escape"] = {
			label    = "exit",
			fn       = function()
				return true
			end,
			bindings = nil,
		},
	},
}

-- Assign separator fields as non-local so they can be reassigned by the user.
modality.keypath_separator    = "," -- the separator between keypaths
modality.label_separator      = ":" -- the separator between keypath code:label

-- keypath_target_label returns the label of the function that a keypath binding ultimately describes (the "target").
-- If no label is provided (eg. "a:awesome,h:help,k"), then an empty string is returned.
modality.keypath_target_label = function(keypath)
	-- Split keypath to get last element.
	local steps = split_string(keypath, modality.keypath_separator)
	if #steps == 0 then
		return ""
	end

	-- Get the last element from the keypath.
	local last_step = steps[#steps]
	return split_string(last_step, modality.label_separator)[2] or ""
end

local function install_steps(parent, steps, fn)

	--[[
	ROOT

	modality.paths                = {
	label    = "Modality",
	bindings = {
		["Escape"] = {
	--]]

	-- Split the keypath into a table of steps.
	-- eg.
	-- nested: "a:applications,r:raise or spawn,f:firefox" => {"a:applications", "r:raise or spawn", "f:firefox"}
	-- flat: "i:hints"
	local steps_list = split_string(steps, modality.keypath_separator)

	local is_last    = #steps_list == 1
	local first_step = steps_list[1]

	local spl        = split_string(first_step, modality.label_separator)
	-- "a:applications" => {"a", "applications"}
	-- "r:raise or spawn" => {"r", "raise or spawn"}
	-- "f:firefox" => {"f", "firefox"}

	local code       = spl[1]
	local label      = spl[2] or "???"

	if not parent.bindings then
		parent.bindings = {}
	end

	-- The parent bindings table does not have an entry at this key.
	-- Initialize it as a table.
	-- eg. "a" = { label = "applications", ... }
	if not parent.bindings[code] then
		parent.bindings[code]          = {
			label = label,
		}
		parent.bindings[code].bindings = {}
	end

	-- Overwrite any label and function with the new one.
	parent.bindings[code].label = label

	if is_last then
		-- All last elements in keypaths are required to have functions, for now.
		parent.bindings[code].fn       = fn
		parent.bindings[code].bindings = nil
	else
		-- Recurse.
		-- We remove the first element from the steps list because we've already processed it.
		local remaining_steps = table.concat(steps_list, modality.keypath_separator, 2)
		install_steps(parent.bindings[code], remaining_steps, fn)
	end
end

-- register registers a keypath (eg. "ahk") to a function.
-- @keypath: the keypath to register
-- @fn: the function to execute when the keypath is completed
modality.register = function(keypath, fn)
	install_steps(modality.paths, keypath, fn)
end

modality.init     = function()
	modality.widget.init()
end

-- Docs: https://awesomewm.org/apidoc/core_components/awful.keygrabber.html
local function stop_parser(bindings_parent)
	return function(self, stop_key, stop_mods, sequence)

		print("[modality] stop_parse", "key=", stop_key, "mods=", stop_mods, "sequence=", sequence)

		print "[modality] stop_parse bindings_parent:"
		modality_util.debug_print_paths("[modality]", bindings_parent)

		local function exit(reason)
			print("[modality] stop_parse exiting: " .. reason)
			modality.widget.hide(awful.screen.focused())
			return true
		end

		if not bindings_parent.bindings then
			-- TODO Show error? (No list of bindings.)
			return exit("no bindings")
		end

		local bound = bindings_parent.bindings[stop_key]
		if not bound then
			-- TODO Show error? (Invalid binding, no such binding.)
			return exit("unmatched binding")
		end
		print("[modality] matched binding", "key=", stop_key, "binding.label=", bound.label)
		print "[modality] bound:"
		modality_util.debug_print_paths("[modality]", bound)

		if bound.fn then
			print("[modality] matched binding has function, executing")
			modality.widget.hide(awful.screen.focused())
			return bound.fn() -- call the function and return its result

		elseif bound.bindings then
			print("[modality] entering submenu", "label=", bound.label, "#bindings=", #bound.bindings)
			modality.enter(bound)
			return true
		else
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
	if not gears.table.hasitem(stop_keys, "Escape") then
		table.insert(stop_keys, "Escape")
	end

	modality.kg = awful.keygrabber {
		-- Start the grabbing immediately.
		autostart     = true,

		-- The event on which the keygrabbing will be terminated.
		stop_event    = "press",

		-- The key on which the keygrabber listen to terminate itself.
		stop_key      = stop_keys,

		---- If any key is pressed that is not in this list, the keygrabber is stopped.
		--allowed_keys  = gears.table.keys(bindings_parent.bindings),

		-- The callback when the keygrabbing stops.
		stop_callback = stop_parser(bindings_parent),
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