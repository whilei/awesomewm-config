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

klack.choose_key   = function()
	local cmd    = "" ..
			-- Get a list of filenames (file NAMES only).
			"ls -l klack/sounds/mixkit.com/ | rev | cut -d' ' -f1 | rev " ..
			-- And pipe them to Rofi for choosing.
			"| rofi -dmenu -p 'klack search' -i -location 0" ..
			""

	-- NOT asynchronous.
	local choice = ""
	a_spawn.with_shell(cmd, function(stdout, stderr, reason, code)
		if code ~= 0 then
			naughty.notification {
				title   = "klack.choose_key (" .. reason .. ")",
				text    = "Error: " .. stderr,
				timeout = 0,
			}
			return -- nil
		end
		choice = stdout:gsub("\n", "")
	end)
	return choice
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
			--"mixkit-typewriter-soft-click-1125.wav"

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
					}
				end
			end)
		end
	end

	klack.kg         = a_keygrabber {
		autostart           = true,
		keypressed_callback = play_sound(klack.choose_key())
	}
end

return setmetatable(klack, { __call = function(_, ...)
	return klack
end })