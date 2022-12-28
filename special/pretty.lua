---------------------------------------------------------------------------
-- Pretty
--
-- Pretty beautiful configuration choices I've made with potentially mysterious dependencies.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod pretty
---------------------------------------------------------------------------

local os, tostring              = os, tostring

local pretty                    = {}

-- pretty.rofi_theme_path references special themes for rofi
-- available at https://github.com/adi1090x/rofi.
-- I have that installed as described in the repo's install steps.
local rofi_theme_path           = function(type_n, style_n)
	return os.getenv("HOME") ..
			"/.config/rofi/launchers" ..
			"/type-" .. tostring(type_n) ..
			"/style-" .. tostring(style_n) ..
			".rasi"
end

pretty.rofi_theme_path_modality = rofi_theme_path(4, 4)
pretty.rofi_theme_path_drun     = rofi_theme_path(2, 7)
pretty.rofi_theme_path_window   = rofi_theme_path(2, 1)

return pretty