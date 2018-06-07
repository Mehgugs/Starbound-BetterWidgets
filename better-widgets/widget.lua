--- Abstract base-class for widgets.
--  @classmod Widget
require"/scripts/vec2.lua"
require"/scripts/rect.lua"
require"/scripts/util.lua"

require"/better-widgets/hobolite.lua"
require"/better-widgets/oo.lua"
require"/better-widgets/config-fetcher.lua"

Widget = newObject()

local ignoresCallback = {
    layout = true,
    scrollArea = true,
    canvas = true,
}
local get = rawget
local set = rawset
local newidx = Widget.__newindex

function Widget:__newindex(k, v)
    if k == "callback" and self.initialized and self.bwCallback then 
        local cbwidname = self.name:match('[^.]+$')
        if v then 
            self.master.registered[cbwidname] = self.name
            local old = v
            v = function(_,...) return old(...) end
        else
            self.master.registered[cbwidname] = nil 
        end
        k = "_callback"
    elseif k == "callback" and not (self.initialized or self.bwCallback) then
        return
    end
    return newidx(self, k, v)
end

--- constructor.
-- @tparam string name the widget's name
-- @tparam string path the path to it's configuration
-- @param[opt] ... extra parameters passed to the sub classes. 
function Widget:new (name, type, path, master)
    local new = setmetatable({}, self)
    new.master = master
    if self.__base and self.initial ~= Widget.initial then
      Widget.initial(new,name,type,path)
    end
    new:initial()
    return new
end

-- old
function Widget:newFrom (name, path, master)
    master.warn("Widget:newFrom is deprecated?")
    return self:new(name, path, master)
end

local null = {}
local undefined = {}
local function normalize(value)
    if value ~= null or value ~= undefined then return value 
    elseif value == undefined then return nil, true
    elseif value == null then return nil end
end

local function cacherize(value, didnotexist)
    if value == nil and didnotexist then return undefined 
    elseif value == nil and not didnotexist then return null
    else return value end
end

local widnewidx = function(self, k, v) if k == "callback" then k = "_callback" end return set(self, k, v) end

--- Creates a subclass, used to create widget classes.
--  @tparam[opt] table t a table used as the subclass' initial value
--  @return A subclass of Widget
function Widget:extend (t)
    local sub = newObject(t or {})
    sub.__base = self
    sub.__newindex = self.__newindex
    return setmetatable(sub, {__index = self, __newindex = widnewidx})
end

-- initializes the class instance.
function Widget:initial(name,type,path)
    self.configpath = path or fixPath(name)
    self._config = {}
    self.name = name
    self.type = type

    self.initialSize = self:config"size" or widget.getSize(self.name)
    self.anchorPosition = {0,0}

    self.initialPosition = copy(self.position)


    self.parent = self.name:gsub("%.[^.]+$","")
    if not ignoresCallback[self.type] then
        local callback, didnotexist = self:config"callback"
        if callback == "betterwidget" and not self._callback then 
            self.master.warn("Widget '%s' has no callback?", self.name)
        elseif callback == nil and didnotexist then
            local cbname = self.name:match("[^.]+$")
            local cb = _ENV[cbname] 
            if cb == nil then 
                return self.master.warn("Widget '%s' has no callback?", self.name)
            end
            self._callback = cb
        elseif callback == "betterwidget" and self._callback then 
            local cbwidname = self.name:match('[^.]+$')
            self.master.registered[cbwidname] = self.name
        elseif callback ~= nil and callback ~= "null" then 
            local cb = access(_ENV, callback) 
            if cb == nil then 
                return self.master.warn("Widget '%s' has no callback?", self.name)
            end
            self._callback = cb
        end
        self.bwCallback = not not callback == "betterwidget"
    end
    self.initialized = true -- MUST be last
end

--- Gets the callback assigned to the widget.
--  @treturn function
function Widget:getCallback()
    return self._callback
end

function Widget:__tostring()
    return "Widget"
end

function Widget:cast(obj)
    local name, type, path, master = obj.name, obj.type, obj.configpath, obj.master
    local ref = master.refs[name]
    if not ref then 
        master.fatal("Cannot cast with untracked widget object!")
    end
    local newobj = self:new(name, type, path, master)
    master.widgets[ref] = newobj
    return newobj
end

--- Fetches config from the widget's JSON configuration
--  @tparam string path the path to the value within the widget config
--  @return JSON the value or nil if it does not exist
function Widget:config(path)
    if self._config[path] ~= nil then return normalize(self._config[path])
    else
        local value, didnotexist = rawparam("%s.%s", self.configpath, path)
        self._config[path] = cacherize(value, didnotexist) 
        return normalize(self._config[path])
    end
end

--- Resets a widget's position, custom anchor and size
--  @return self
function Widget:reset ()
    self:setAnchor()
    self.position = self.initialPosition
    self.size = self.initialSize
    return self
end

--- Sets the custom anchor type for the widget
--  @param[opt] x string The x anchor mode OR a table of both anchor modes {x,y}
--  @param[opt] y string The y anchor mode
function Widget:setAnchor(x,y)
    if type(x) == "table" then 
        x,y = x[1], x[2]
    end
    self._xAnchor = x
    self._yAnchor = y
    self.anchorPosition = self:newAnchorPosition()
end

-- Creates a new anchor position
function Widget:newAnchorPosition()
    local mid = self.Midpoint
    local max = self.Size
    local x,y
    if self._xAnchor == "mid" then 
        x = mid[1]
    elseif self._xAnchor == "right" then 
        x = max[1]
    else
        x = 0
    end

    if self._yAnchor == "mid" then 
        y = mid[2]
    elseif self._yAnchor == "top" then 
        y = max[2]
    else
        y = 0
    end
    return {x,y}
end

--- Gets the widget's current position
--  @treturn Vec2
function Widget:getPosition ()
    return widget.getPosition(self.name)
end

--- Sets the widget's position
--  @tparam Vec2 pos
--  @return self
function Widget:setPosition (pos)
    widget.setPosition(self.name,vec2.sub(pos,self.anchorPosition))
    return self
end

-- Used to set initial size
function Widget:findInitialSize()
    if not self.initialSize then self.initialSize = self.Size or self:config"size" end
end

--- Gets the widget's current size
--  @treturn Vec2
function Widget:getSize ()
    return widget.getSize(self.name)
end

--- Sets the widget's current size
--  @tparam Vec2 sz
--  @return self
function Widget:setSize (sz)
    widget.setSize(self.name,sz)
    return self
end

--- Gets the mid point of the widget
--  @treturn Vec2
function Widget:getMidpoint ()
    return vec2.floor(vec2.div(self.size,2))
end

--- Gets the visibility state of the widget
--  @treturn boolean
function Widget:getVisible ()
    return widget.active(self.name)
end

--- Alias for getVisible
Widget.getActive = Widget.getVisible

--- Sets the visibility state of the widget
--  @tparam boolean vis the visibility to set
-- @return self
function Widget:setVisible (vis)
    widget.setVisible(self.name,vis)
    return self
end

--- Sets the focus of the interface on a given widget or clears the focus from the widget
--  @tparam boolean vis
--  @return self
function Widget:setFocus (vis)
  if vis then widget.focus(self.name);
  else widget.blur(self.name) end
  return self
end

--- Gets the focus state of the widget
--  @treturn boolean
function Widget:getFocus ()
  return widget.hasFocus(self.name)
end

--- Gets the arbitrary data for a given widget
--  @treturn JSON
function Widget:getData ()
  return widget.getData(self.name)
end

--- Sets the arbitrary for the widget
--  @tparam JSON data
--  @return self
function Widget:setData (data)
  widget.setData(self.name, data)
  return self
end

--- Checks if the given screen position is inside the widget
--  @tparam Vec2 pos the screen position
--  @treturn bool
function Widget:hovering (pos)
  return widget.inMember(self.name,pos)
end

--- Gets the region a widget takes up on a canvas (if a widget is mounted to a canvas)
--  @treturn RectF
function Widget:getCanvasRegion ()
  if not self._canvas then return error(("Widget %s is not on a canvas."):format(self.name)) end

  local cPos = vec2.sub(self.position,widget.getPosition(self._canvas))
  return rect.fromVec2(cPos,vec2.add(cPos,self.size))
end

--- Mounts a widget to a canvas widget
--  @tparam string c the name of the canvas
function Widget:onCanvas (c)
  self._canvas = c
  return self
end

--- Checks if the given canvas position is inside the widget, assuming it is mounted on the same canvas
--  @tparam Vec2 canvasPosition
--  @tparam[opt] string cname the name of a canvas to check on
--  @treturn boolean
function Widget:within (canvasPosition,cname)
  if not self._canvas then
    return self:onCanvas(cname):within(canvasPosition)
  end
  return rect.contains(self.canvasRegion,canvasPosition)
end