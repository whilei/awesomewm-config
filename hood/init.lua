---------------------------------------------------------------------------
-- Hood
--
-- Hood HUD view to see what's going on in Awesome.
--
-- @author whilei
-- @author Isaac &lt;isaac.ardis@gmail.com&gt;
-- @copyright 2022 Isaac
-- @coreclassmod hood
---------------------------------------------------------------------------
local awesome, mouse          = awesome, mouse
local table, tostring, string = table, tostring, string
local wibox                   = require("wibox")
local a_spawn                 = require("awful.spawn")
local g_table                 = require("gears.table")
local g_debug                 = require("gears.debug")

---------------------------------------------------------------------------

-- hood is the return object.
local hood                    = {}

hood.hud                      = wibox {
	type              = "toolbar",
	ontop             = true,
	visible           = false,
	honor_workarea    = true,
	input_passthrough = true,
	x                 = 0,
	y                 = 0,
}

local function hood_hud_awesome_props()
	local props = {
		{ "awesome.version", awesome.version },
		{ "awesome.release", awesome.release },
		{ "awesome.api_level", awesome.api_level },
		{ "awesome.conffile", awesome.conffile },
		{ "awesome.startup", awesome.startup },
		{ "awesome.startup_errors", awesome.startup_errors },
		{ "awesome.composite_manager_running", awesome.composite_manager_running },
		--{ "awesome.unix_signal", awesome.unix_signal },
		{ "awesome.hostname", awesome.hostname },
		{ "awesome.themes_path", awesome.themes_path },
		{ "awesome.icon_path", awesome.icon_path },
	}
	local function add_awesome_prop(pp)
		local prop         = pp[1]
		local val          = pp[2]
		local container    = hood.hud:get_children_by_id("section_top")[1]
		local children     = container.children

		local value_string = tostring(val)
		if type(val) == "table" then
			value_string = g_debug.dump_return(val, "", nil)
		end

		local child = wibox.widget {
			layout  = wibox.layout.fixed.horizontal,
			spacing = 5,
			{
				widget = wibox.widget.textbox,
				markup = "<b>" .. prop .. "</b>",
			},
			wibox.widget.textbox(" = "),
			{
				widget = wibox.widget.textbox,
				text   = value_string,
			},
		}
		table.insert(children, child)
		container.children = children
	end
	for _, pp in ipairs(props) do
		add_awesome_prop(pp)
	end
end

local function hood_hud_tail_logs()
	-- The rev-cut-rev command chain here gets the LAST pid from `pidof`.
	-- If there are more than one awesome procs running, we want the first (oldest)
	-- process, which I expect `pidof` to return as the last element (space separated).
	-- This chain should work with 1 or more procs.
	-- FIXME
	-- This only retrieves the first-running PID,
	-- which means that this feature does not work in a Xephyr emulated environment (ie development).
	print("[hood] start tailing awesome logs...")

	local noisy = "bash -c 'tail -F -n 20 /proc/$(pidof awesome | rev | cut -d\" \" -f1 | rev)/fd/2'"

	a_spawn.with_line_callback(noisy, {
		stdout = function(line)
			local container = hood.hud:get_children_by_id("section_middle")[1]
			local tb        = wibox.widget.textbox(line, true)
			local children  = container.children
			table.insert(children, tb)
			if #children > 10 then
				table.remove(children, 1)
			end
			container.children = children
		end,
	})
end

-- inspector_mouse_enter creates a signal listener for the mouse::enter signal.
-- When the mouse enters the client/widget, the client/widget is debug-dumped
-- to the allocated textbox for inspection of its properties.
local inspector_mouse_enter = function()
	if mouse.current_client then
		local c        = mouse.current_client
		local children = hood.hud:get_children_by_id("section_bottom")[1].children

		local dump     = g_debug.dump_return(c, "mouse.current_client", nil)
		print(dump)

		local dumped = wibox.widget.textbox()
		dumped:set_text(dump)
		table.insert(children, dumped)

		-- FIXME
		-- Instead of copy-pasta from the docs site,
		-- it would be better to iterate over the actual object props and dump them according to type.
		-- I was hoping g_debug.dump_return would do this, but it doesn't.
		local props_list = {
			{ "window", "integer", "The X window id. 	Read only" },
			{ "name", "string", "The client title." },
			{ "skip_taskbar", "boolean", "True if the client does not want to be in taskbar." },
			{ "type", "string", "The window type. 	Read only" },
			{ "class", "string", "The client class. 	Read only" },
			{ "instance", "string", "The client instance. 	Read only" },
			{ "pid", "integer", "The client PID, if available. 	Read only" },
			{ "role", "string", "The window role, if available. 	Read only" },
			{ "machine", "string", "The machine the client is running on. 	Read only" },
			{ "icon_name", "string", "The client name when iconified. 	Read only" },
			{ "icon", "image", "The client icon as a surface." },
			{ "icon_sizes", "table", "The available sizes of client icons. 	Read only" },
			{ "screen", "screen", "Client screen." },
			{ "hidden", "boolean", "Define if the client must be hidden (Never mapped, invisible in taskbar)." },
			{ "minimized", "boolean", "Define if the client must be iconified (Only visible in taskbar)." },
			{ "size_hints_honor", "boolean", "Honor size hints, e.g." },
			{ "border_width", "integer or nil", "The client border width." },
			{ "border_color", "color or nil ", "The client border color." },
			{ "urgent", "boolean", "Set to true when the client ask for attention." },
			{ "content", "raw_curface", "A cairo surface for the client window content. 	Read only" },
			{ "opacity", "number", "The client opacity." },
			{ "ontop", "boolean", "The client is on top of every other windows." },
			{ "above", "boolean", "The client is above normal windows." },
			{ "below", "boolean", "The client is below normal windows." },
			{ "fullscreen", "boolean", "The client is fullscreen or not." },
			{ "maximized", "boolean", "The client is maximized (horizontally and vertically) or not." },
			{ "maximized_horizontal", "boolean", "The client is maximized horizontally or not." },
			{ "maximized_vertical", "boolean", "The client is maximized vertically or not." },
			{ "transient_for", "client or nil", "The client the window is transient for. 	Read only" },
			{ "group_window", "integer", "Window identification unique to a group of windows. 	Read only" },
			{ "leader_window", "integer", "Identification unique to windows spawned by the same command. 	Read only" },
			{ "size_hints", "table or nil", "A table with size hints of the client. 	Read only" },
			{ "motif_wm_hints", "table", "The motif WM hints of the client. 	Read only" },
			{ "sticky", "boolean", "Set the client sticky (Available on all tags)." },
			{ "modal", "boolean", "Indicate if the client is modal." },
			{ "focusable", "boolean", "True if the client can receive the input focus." },
			{ "shape_bounding", "image", "The client's bounding shape as set by awesome as a (native) cairo surface." },
			{ "shape_clip", "image", "The client's clip shape as set by awesome as a (native) cairo surface." },
			{ "shape_input", "image", "The client's input shape as set by awesome as a (native) cairo surface." },
			{ "client_shape_bounding", "image", "The client's bounding shape as set by the program as a (native) cairo surface. 	Read only" },
			{ "client_shape_clip", "image", "The client's clip shape as set by the program as a (native) cairo surface. 	Read only" },
			{ "startup_id", "string", "The FreeDesktop StartId." },
			{ "valid", "boolean", "If the client that this object refers to is still managed by awesome. 	Read only" },
			{ "first_tag", "tag or nil", "The first tag of the client. 	Read only" },
			{ "buttons", "table", "Get or set mouse buttons bindings for a client." },
			{ "keys", "table", "Get or set keys bindings for a client." },
			{ "marked", "boolean", "If a client is marked or not." },
			{ "is_fixed", "boolean", "Return if a client has a fixed size or not. 	Read only" },
			{ "immobilized_horizontal", "boolean", "Is the client immobilized horizontally? 	Read only" },
			{ "immobilized_vertical", "boolean", "Is the client immobilized vertically? 	Read only" },
			{ "floating", "boolean", "The client floating state." },
			{ "x", "integer", "The x coordinates." },
			{ "y", "integer", "The y coordinates." },
			{ "width", "integer", "The width of the client." },
			{ "height", "integer", "The height of the client." },
			{ "dockable", "boolean", "If the client is dockable." },
			{ "requests_no_titlebar", "boolean", "If the client requests not to be decorated with a titlebar." },
			{ "shape", "shape", "Set the client shape." },
			{ "active", "boolean", "Return true if the client is active (has focus). 	Read only" },
		}

		for _, prop in ipairs(props_list) do
			local tb = wibox.widget.textbox()
			tb:set_text(prop[1] .. " = " .. tostring(c[prop[1]]) .. " (" .. (prop[3] or "n/a") .. ")")
			table.insert(children, tb)
		end

		hood.hud:get_children_by_id("section_bottom")[1].children = children

		--[[
window 	integer 	The X window id. 	Read only
name 	string 	The client title.
skip_taskbar 	boolean 	True if the client does not want to be in taskbar.
type 	string 	The window type. 	Read only
class 	string 	The client class. 	Read only
instance 	string 	The client instance. 	Read only
pid 	integer 	The client PID, if available. 	Read only
role 	string 	The window role, if available. 	Read only
machine 	string 	The machine the client is running on. 	Read only
icon_name 	string 	The client name when iconified. 	Read only
icon 	image 	The client icon as a surface.
icon_sizes 	table 	The available sizes of client icons. 	Read only
screen 	screen 	Client screen.
hidden 	boolean 	Define if the client must be hidden (Never mapped, invisible in taskbar).
minimized 	boolean 	Define if the client must be iconified (Only visible in taskbar).
size_hints_honor 	boolean 	Honor size hints, e.g.
border_width 	integer or nil 	The client border width.
border_color 	color or nil 	The client border color.
urgent 	boolean 	Set to true when the client ask for attention.
content 	raw_curface 	A cairo surface for the client window content. 	Read only
opacity 	number 	The client opacity.
ontop 	boolean 	The client is on top of every other windows.
above 	boolean 	The client is above normal windows.
below 	boolean 	The client is below normal windows.
fullscreen 	boolean 	The client is fullscreen or not.
maximized 	boolean 	The client is maximized (horizontally and vertically) or not.
maximized_horizontal 	boolean 	The client is maximized horizontally or not.
maximized_vertical 	boolean 	The client is maximized vertically or not.
transient_for 	client or nil 	The client the window is transient for. 	Read only
group_window 	integer 	Window identification unique to a group of windows. 	Read only
leader_window 	integer 	Identification unique to windows spawned by the same command. 	Read only
size_hints 	table or nil 	A table with size hints of the client. 	Read only
motif_wm_hints 	table 	The motif WM hints of the client. 	Read only
sticky 	boolean 	Set the client sticky (Available on all tags).
modal 	boolean 	Indicate if the client is modal.
focusable 	boolean 	True if the client can receive the input focus.
shape_bounding 	image 	The client's bounding shape as set by awesome as a (native) cairo surface.
shape_clip 	image 	The client's clip shape as set by awesome as a (native) cairo surface.
shape_input 	image 	The client's input shape as set by awesome as a (native) cairo surface.
client_shape_bounding 	image 	The client's bounding shape as set by the program as a (native) cairo surface. 	Read only
client_shape_clip 	image 	The client's clip shape as set by the program as a (native) cairo surface. 	Read only
startup_id 	string 	The FreeDesktop StartId.
valid 	boolean 	If the client that this object refers to is still managed by awesome. 	Read only
first_tag 	tag or nil 	The first tag of the client. 	Read only
buttons 	table 	Get or set mouse buttons bindings for a client.
keys 	table 	Get or set keys bindings for a client.
marked 	boolean 	If a client is marked or not.
is_fixed 	boolean 	Return if a client has a fixed size or not. 	Read only
immobilized_horizontal 	boolean 	Is the client immobilized horizontally? 	Read only
immobilized_vertical 	boolean 	Is the client immobilized vertically? 	Read only
floating 	boolean 	The client floating state.
x 	integer 	The x coordinates.
y 	integer 	The y coordinates.
width 	integer 	The width of the client.
height 	integer 	The height of the client.
dockable 	boolean 	If the client is dockable.
requests_no_titlebar 	boolean 	If the client requests not to be decorated with a titlebar.
shape 	shape 	Set the client shape.
active 	boolean 	Return true if the client is active (has focus). 	Read only
		--]]


		return
	end

	if mouse.current_widget then
		local dump = g_debug.dump_return(mouse.current_widget, "mouse.current_widget", nil)
		print(dump)

		local dumped = wibox.widget.textbox()
		w:set_text(dump)
		hood.hud:get_children_by_id("section_bottom")[1].children = {
			dumped,
		}

		return
	end
end

local inspector_mouse_leave = function()
	hood.hud:get_children_by_id("section_bottom")[1].children = {}
end

local function hood_hud_inspector_start()
	client.connect_signal("mouse::enter", inspector_mouse_enter)
	client.connect_signal("mouse::leave", inspector_mouse_leave)
end

local function hood_hud_inspector_stop()
	client.disconnect_signal("mouse::enter", inspector_mouse_enter)
	client.disconnect_signal("mouse::leave", inspector_mouse_leave)
end

hood.show   = function()
	hood.hud.hidden  = false
	hood.hud.visible = true
	hood_hud_inspector_start()

	-- FIXME
	--do
	-- hood_hud_tail_logs()
	--end
end

hood.hide   = function()
	hood.hud.hidden  = true
	hood.hud.visible = false
	hood_hud_inspector_stop()
end

hood.toggle = function()
	if not hood.hud.visible then
		hood.show()
	else
		hood.hide()
	end
end

hood.init   = function(s)
	hood.hud.screen         = s
	hood.hud.x              = s.workarea.x
	hood.hud.y              = s.workarea.y
	hood.hud.width          = s.workarea.width / 2
	hood.hud.height         = s.workarea.height
	hood.hud.honor_workarea = true
	hood.hud:setup {
		layout = wibox.container.background,
		bg     = "#430B12" .. "dd",
		{
			layout  = wibox.container.margin,
			margins = 20,
			{
				--[[
				wibox.layout.align.vertical.expand="inside"
					The widgets in slot one and three are set to their minimal required size.
					The widget in slot two is then given the remaining space.
					This is the default behaviour.

				wibox.layout.align.vertical.expand="outside"
					The widget in slot two is set to its minimal required size
					and placed in the center of the space available to the layout.
					The other widgets are then given the remaining space on either side.
					If the center widget requires all available space,
					the outer widgets are not drawn at all.

				wibox.layout.align.vertical.expand="none"
					All widgets are given their minimal required size or the remaining space,
					whichever is smaller.
					The center widget gets priority.
				--]]
				layout = wibox.layout.fixed.vertical,
				id     = "container",
				expand = "none",
				{
					layout = wibox.layout.fixed.vertical,
					id     = "section_top",
					--{
					--	widget = wibox.widget.textbox,
					--	text   = "AWESOME PROPS",
					--},
				},
				{
					layout   = wibox.container.background,
					max_size = 100,
					id       = "section_middle",
					children = { wibox.widget.textbox("Tailing awesome logs..."), },
				},
				{
					layout = wibox.layout.fixed.vertical,
					id     = "section_bottom",
					--{
					--	widget = wibox.widget.textbox,
					--	text   = "Client/Widget inspector",
					--},
				},
			},
		},
	}
	hood_hud_awesome_props()
end

return setmetatable(hood, { __call = function(_, ...)
	return hood.init(...)
end })