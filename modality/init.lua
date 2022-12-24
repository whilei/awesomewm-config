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
	local steps     = split_string(keypath, modality.keypath_separator)
	local last_step = steps[#steps]
	return split_string(last_step, modality.label_separator)[2] or ""
end

-- register registers a keypath (eg. "ahk") to a function.
-- @keypath: the keypath to register
-- @fn: the function to execute when the keypath is completed
modality.register             = function(keypath, fn)
	--modality.paths[keypath] = fn

	-- split the keypath into a table
	-- eg.
	-- nested: "a:applications,r:raise or spawn,f:firefox" => {"a:applications", "r:raise or spawn", "f:firefox"}
	-- flat: "i:hints"
	local codes_w_labels = split_string(keypath, modality.keypath_separator)

	local binding_parent = modality.paths.bindings

	for i, cl in ipairs(codes_w_labels) do

		local is_last = i == #codes_w_labels

		local spl     = split_string(cl, modality.label_separator)
		-- "a:applications" => {"a", "applications"}
		-- "r:raise or spawn" => {"r", "raise or spawn"}
		-- "f:firefox" => {"f", "firefox"}

		local code    = spl[1]
		local label   = spl[2] or "???"

		-- eg. "a" = { label = "applications", ... }
		if binding_parent[code] == nil then
			binding_parent[code] = {
				label    = label,
				bindings = {}
			}
		else
			-- Overwrite any label and function with the new one.
			binding_parent[code].label = label
			--
			-- Do not overwrite any existing bindings.
		end
		if is_last then
			binding_parent[code] = {
				label = label,
				fn    = fn,
			}
		else
			-- Reassign binding_parent because we're not at the end of the keypath
			-- Nest deeper.
			binding_parent = binding_parent[code].bindings
		end
	end
end

modality.init                 = function()
	modality.widget.init()
end

-- enter enters the modality mode.
-- @bindings_parent: the parent bindings object to start with.
--   This object should have {label, bindings} fields.
modality.enter                = function(bindings_parent)
	local s = awful.screen.focused()

	-- Docs: https://awesomewm.org/apidoc/core_components/awful.keygrabber.html
	local function stop_parse(self, stop_key, stop_mods, sequence)

		print("stop_parse", stop_key, stop_mods, sequence)

		local function exit()
			modality.widget.hide(s)
			return true
		end

		if not bindings_parent then
			return exit()
		end

		if not bindings_parent.bindings then
			-- TODO Show error? (Unmatched keybinding.)
			return exit()
		end

		local binding = bindings_parent.bindings[stop_key]
		if not binding then
			return exit()
		end

		if binding.fn then
			modality.widget.hide(s)
			return binding.fn() -- call the function and return its result

		elseif binding.bindings then
			modality.enter(s, binding.bindings, binding.label)

		else
			-- TODO Handle case when both label and binding are nil, which is not allowed
			return true
		end
	end

	modality.widget.show(s, bindings_parent)

	awful.keygrabber {
		-- Start the grabbing immediately.
		autostart     = true,

		-- The event on which the keygrabbing will be terminated.
		stop_event    = "press",

		-- The key on which the keygrabber listen to terminate itself.
		stop_key      = gears.table.keys(bindings_parent.bindings),

		---- If any key is pressed that is not in this list, the keygrabber is stopped.
		--allowed_keys  = gears.table.keys(bindings_parent.bindings),

		-- The callback when the keygrabbing stops.
		stop_callback = stop_parse,
	}

end

modality.exit                 = function()
	modality.widget.hide(awful.screen.focused())
end

return modality

--return setmetatable(modality, {
--	__call = function(_, args)
--		args = args or {}
--		return modality.init()
--	end
--})