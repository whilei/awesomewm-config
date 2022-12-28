---------------------------------------------------------------------------
-- Klack
--
-- Klacky functions for klicky keyboards.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod klack
---------------------------------------------------------------------------

local a_keygrabber = require("awful.keygrabber")
local a_spawn      = require("awful.spawn")
local g_filesystem = require("gears.filesystem")
local naughty      = require("naughty")

local klack        = {}

klack.stop         = function()
	klack.kg:stop()
end

klack.choose_key   = function(cb_with_choice)
	local cmd    = "" ..
			-- Get a list of filenames (file NAMES only).
			"ls -l " ..
			g_filesystem.get_configuration_dir() .. "klack/sounds/mixkit.com/ " ..
			"| rev | cut -d' ' -f1 | rev " ..
			-- And pipe them to Rofi for choosing.
			"| rofi -dmenu -p 'klack search' -i -location 0 " ..
			""

	-- NOT asynchronous.
	local choice = ""
	a_spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, code)
		if code ~= 0 then
			naughty.notification {
				title   = "klack.choose_key (" .. reason .. ")",
				text    = "Error: " .. stderr,
				timeout = 0,
			}
			cb_with_choice(nil)
			return
		end
		choice = stdout:gsub("\n", "")
		cb_with_choice(choice)
	end)
end

klack.start        = function()
	local play_sound = function(chosen_sound)
		return function(self, mods, key, event)
			if event ~= "press" then
				return true
			end

			if key:lower() == "escape" then
				self:stop()
				return true
			end

			local cmd = "" ..
					"play " ..
					"-q " ..
					"--single-threaded " ..
					"--rate 150000 " .. -- Sample rate of audio.
					g_filesystem.get_configuration_dir() ..
					"/klack/sounds/" ..
					"mixkit.com/" ..
					chosen_sound

			a_spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, code)
				if code ~= 0 then
					naughty.notification {
						title    = "Klack",
						text     = "" ..
								"Failed to play sound: " ..
								reason .. "\n\n" ..
								stderr .. "\n" ..
								"",
						timeout  = 0,
						position = "top_middle",
						bg       = "#ff0000",
						fg       = "#ffffff",
						position = "top_middle",
					}
				end
			end)
		end
	end

	klack.choose_key(function(choice)
		if choice == nil then
			naughty.notification {
				title    = "no choice made",
				timeout  = 2,
				position = "top_middle",
			}
			return
		end
		naughty.notification {
			title    = "klack",
			message  = choice,
			bg       = "#ffffff",
			fg       = "#000000",
			timeout  = 2,
			position = "top_middle",
		}
		klack.kg = a_keygrabber {
			autostart           = true,
			keypressed_callback = play_sound(choice),
			stop_keys           = { "Escape" },
			stop_callback       = function()
				naughty.notification {
					preset   = naughty.config.presets.normal,
					title    = "klack",
					text     = "stopped",
					bg       = "#ff0000",
					fg       = "#ffffff",
					timeout  = 2,
					position = "top_middle",
				}
			end
		}
	end)
end

return setmetatable(klack, { __call = function(_, ...)
	return klack
end })