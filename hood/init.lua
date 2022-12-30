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
local awesome         = awesome
local table, tostring = table, tostring
local wibox           = require("wibox")
local a_spawn         = require("awful.spawn")
local g_table         = require("gears.table")
local g_debug         = require("gears.debug")

---------------------------------------------------------------------------

-- hood is the return object.
local hood            = {}

hood.w                = wibox {
	type           = "toolbar",
	ontop          = true,
	visible        = true,
	honor_workarea = true,
	x              = 0,
	y              = 0,
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
		local container    = hood.w:get_children_by_id("section_top")[1]
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
	local container = hood.w:get_children_by_id("section_middle")[1]

	-- The rev-cut-rev command chain here gets the LAST pid from `pidof`.
	-- If there are more than one awesome procs running, we want the first (oldest)
	-- process, which I expect `pidof` to return as the last element (space separated).
	-- This chain should work with 1 or more procs.

	--[[
	# FIXME This is not currently used, but I would like to improve
	# how we get the pid of the (THIS) awesome process,
	# so I\'m leaving it here for reference.
	# https://stackoverflow.com/a/3588480/4401322
	function top_level_parent_pid {
		# Look up the parent of the given PID.
		pid=${1:-$$}
		stat=($(</proc/${pid}/stat))
		ppid=${stat[3]}

		# /sbin/init always has a PID of 1, so if you reach that, the current PID is
		# the top-level parent. Otherwise, keep looking.
		if \[\[ ${ppid} -eq 1 \]\] ; then
			echo ${pid}
		else
			top_level_parent_pid ${ppid}
		fi
	}
	--]]
	local noisy     = [[bash -c '
	AWESOME_PIDS=$(pidof awesome)
	echo "AWESOME_PIDS: ${AWESOME_PIDS}"

	AWESOME_PID=$(echo $AWESOME_PIDS | rev | cut -d" " -f1 | rev)
	echo "AWESOME_PID: $AWESOME_PID"

	tail -F -n 10 "/proc/${AWESOME_PID}/fd/2"
	']]
	a_spawn.with_line_callback(noisy, {
		stdout = function(line)
			local tb       = wibox.widget.textbox(line)
			local children = container.children
			table.insert(children, tb)
			if #children > 10 then
				table.remove(children, 1)
			end
			container.children = children
		end,
		stderr = function(line)
			-- nothing
		end,
	})

	a_spawn.easy_async_with_shell("sleep 2", function()
		print("[hood] started tailing awesome logs")
	end)
end

hood.init = function(s)
	hood.w.screen         = s
	hood.w.x              = s.workarea.x
	hood.w.y              = s.workarea.y
	hood.w.width          = s.workarea.width / 2
	hood.w.height         = s.workarea.height
	hood.w.honor_workarea = true
	hood.w:setup {
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
				layout = wibox.layout.align.vertical,
				id     = "container",
				expand = "none",
				{
					layout = wibox.layout.fixed.vertical,
					id     = "section_top",
					{
						widget = wibox.widget.textbox,
						text   = "AWESOME PROPS",
					},
					nil,
					nil,
				},
				{
					layout = wibox.layout.align.vertical,
					id     = "section_middle",
					{
						widget = wibox.widget.textbox,
						text   = "AWESOME LOGS",
					},
				},
				{
					layout = wibox.layout.align.vertical,
					id     = "section_bottom",
					{
						widget = wibox.widget.textbox,
						text   = "Bottom",
					},
				},
			},
		},
	}
	hood_hud_awesome_props()
	hood_hud_tail_logs()
end

return setmetatable(hood, { __call = function(_, ...)
	return hood.init(...)
end })