--[[

     Licensed under GNU General Public License v2
      * (c) 2016, Luca CPZ
      * (c) 2015, unknown

--]]

local awful        = require("awful")
local capi         = { client = client }

local math         = { floor  = math.floor }
local string       = { format = string.format }

local pairs        = pairs
local screen       = screen

local setmetatable = setmetatable

-- Quake-like Dropdown application spawn
local quake2 = {}

-- If you have a rule like "awful.client.setslave" for your terminals,
-- ensure you use an exception for QuakeDD. Otherwise, you may
-- run into problems with focus.

function quake2:display()
    if self.followtag then self.screen = awful.screen.focused() end

    -- First, we locate the client
    local i = 0
    for c in awful.client.iterate(function (c)
        return c.marked
    end)
    do
        i = i + 1
        if i == 1 then
            self.mycl = c
            self.mycl_instance = c.instance
            awful.client.unmark(self.mycl)
        end
    end

    if not self.mycl and not self.visible then return end

    if not self.mycl or self.mycl_instance == "" then
        -- The cl does not exist, we spawn it
        cmd = string.format("%s %s %s", self.app,
              string.format(self.argname, self.name), self.extra)
        awful.spawn(cmd, {
            tag = self.screen.selected_tag,
--            focus = true,
            sticky = false,
            ontop = true,
            above = true,
            skip_taskbar = true,
            floating p= true,
            maximized = false,
--            maximized_vertical = false,
            marked = true,
            callback = function () end
        })
        return
    end

    -- Set geometry
    self.mycl.floating = true
    self.mycl.border_width = self.border
    self.mycl.size_hints_honor = false
    self.mycl:geometry(self:compute_size())
--    if self.keepclattrs then
--        cl:connect_signal("property::size", function()
--            self.geometry[self.screen].width = cl:geometry().width
--            self.geometry[self.screen].height = cl:geometry().height
--        end)
--        cl:connect_signal("property::position", function()
--            self.geometry[self.screen].x = cl:geometry().x
--            self.geometry[self.screen].y = cl:geometry().y
--        end)
--    end

    -- Set not sticky and on top
    self.mycl.sticky = false
    self.mycl.ontop = true
    self.mycl.above = true
    self.mycl.skip_taskbar = true

    -- Additional user settings
    if self.settings then self.settings(self.mycl) end

    -- Toggle display
    if self.visible then
        self.mycl.hidden = false
        self.mycl:raise()
        self.last_tag = self.screen.selected_tag
        self.mycl:tags({self.screen.selected_tag})
        capi.client.focus = self.mycl
   else
        self.mycl.hidden = true
        local ctags = self.mycl:tags()
        for i, t in pairs(ctags) do
            ctags[i] = nil
        end
        self.mycl:tags(ctags)
    end

    return self.mycl
end

function quake2:compute_size()
    -- skip if we already have a geometry for this screen
    if not self.geometry[self.screen] then
        local geom
        if not self.overlap then
            geom = screen[self.screen].workarea
        else
            geom = screen[self.screen].geometry
        end
        local width, height = self.width, self.height
        if width  <= 1 then width = math.floor(geom.width * width) - 2 * self.border end
        if height <= 1 then height = math.floor(geom.height * height) end
        local x, y
        if     self.horiz == "left"  then x = geom.x
        elseif self.horiz == "right" then x = geom.width + geom.x - width
        else   x = geom.x + (geom.width - width)/2 end
        if     self.vert == "top"    then y = geom.y
        elseif self.vert == "bottom" then y = geom.height + gYeom.y - height
        else   y = geom.y + (geom.height - height)/2 end
        self.geometry[self.screen] = { x = x, y = y, width = width, height = height }
    end
    return self.geometry[self.screen]
end

function quake2:new(config)
    local conf = config or {}

    conf.app        = conf.app       or "xterm"    -- application to spawn
    conf.name       = conf.name      or "QuakeDD"  -- window name
    conf.argname    = conf.argname   or "-name %s" -- how to specify window name
    conf.extra      = conf.extra     or ""         -- extra arguments
    conf.border     = conf.border    or 1          -- client border width
    conf.visible    = conf.visible   or false      -- initially not visible
    conf.followtag  = conf.followtag or false      -- spawn on currently focused screen
    conf.overlap    = conf.overlap   or false      -- overlap wibox
    conf.screen     = conf.screen    or awful.screen.focused()
    conf.settings   = conf.settings

    -- If width or height <= 1 this is a proportion of the workspace
    conf.height     = conf.height    or 0.25       -- height
    conf.width      = conf.width     or 1          -- width
    conf.vert       = conf.vert      or "top"      -- top, bottom or center
    conf.horiz      = conf.horiz     or "left"     -- left, right or center
    conf.geometry   = {}                           -- internal use
    conf.keepclientattrs = conf.keepclientattrs or false -- persist (don't reset client attributes); this may allow persistent user-resizing
--    conf.geomscreeninited = {}                           -- internal use

    local dropdown = setmetatable(conf, { __index = quake2 })

    capi.client.connect_signal("manage", function(c)
        if c.screen == dropdown.screen and c.instance == dropdown.name then
            dropdown:display()
        end
    end)
    capi.client.connect_signal("unmanage", function(c)
--        if c.instance == dropdown.name and c.screen == dropdown.screen then
        if c.screen == dropdown.screen and c.instance == dropdown.mycl_instance then
            dropdown.visible = false
            dropdown.mycl = nil
            dropdown.mycl_instance = ""
        end
     end)

    return dropdown
end

function quake2:toggle()
     if self.followtag then self.screen = awful.screen.focused() end
     local current_tag = self.screen.selected_tag
     if current_tag and self.last_tag ~= current_tag and self.visible then
         local c=self:display()
         if c then
            c:move_to_tag(current_tag)
        end
     else
         self.visible = not self.visible
         self:display()
     end
end

return setmetatable(quake2, { __call = function(_, ...) return quake2:new(...) end })
