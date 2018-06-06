require"/scripts/vec2.lua"
require"/scripts/rect.lua"
require"/scripts/util.lua"

require"/better-widgets/hobolite.lua"
require"/better-widgets/oo.lua"
require"/better-widgets/config-fetcher.lua"

Widget = newObject()
function Widget:new (...)
    local new = setmetatable({}, self)
    if self.__base and self.initial ~= Widget.initial then
      Widget.initial(new,...)
    end
    new:initial(...)
    return new
end

function Widget:newFrom (...)
    sb.logWarn("Widget:newFrom is deprecated?")
    return self:new(...)
end

local null = {}
local function normalize(value)
    if value ~= null then return value else return nil end
end

local function cacherize(value)
    if value == nil then return null else return value end
end

function Widget:extend ()
    return extender(self)
end

function Widget:initial(name,path)
    self.configpath = fixPath(path or name)
    self._config = {}
    self.name = name

    self.initialSize = self:config"size" or widget.getSize(self.name)

    self.initialPosition = copy(self.position)


    self.parent = self.name:gsub("%.[^.]+$","")
    return self
end

function Widget:initialFrom(name,config)
    self.name = name
    self._config = config
 
    self:findInitialSize()

    self.initialPosition = copy(self.position)

    self.parent = self.name:gsub("%.[^.]+$","")
    return self
end

function Widget:config(path)
    if self._config[path] ~= nil then return normalize(self._config[path])
    else
        local value = widgetParameter("%s.%s", self.configpath, path)
        self._config[path] = cacherize(value) 
        return value
    end
end

function Widget:reset ()
    self.position = self.initialPosition
    self.size = self.initialSize
    return self
end

function Widget:getPosition ()
    return widget.getPosition(self.name)
end

function Widget:setPosition (pos)
    widget.setPosition(self.name,pos)
    return self
end

function Widget:findInitialSize()
    if not self.initialSize then self.initialSize = self.Size or self:config"size" end
end

function Widget:getSize ()
    return widget.getSize(self.name)
end

function Widget:setSize (pos)
    widget.setSize(self.name,pos)
    return self
end

function Widget:getMidpoint ()
    return vec2.floor(vec2.div(self.size,2))
end

function Widget:getVisible ()
    return widget.active(self.name)
end

Widget.getActive = Widget.getVisible

function Widget:setVisible (vis)
    widget.setVisible(self.name,vis)
    return self
end

function Widget:setFocus (vis)
  if vis then widget.focus(self.name);
  else widget.blur(self.name) end
  return self
end

function Widget:getFocus ()
  return widget.hasFocus(self.name)
end

function Widget:getData ()
  return widget.getData(self.name)
end

function Widget:setData (vis)
  widget.setData(self.name,vis)
  return self
end

function Widget:hovering (pos)
  return widget.inMember(self.name,pos)
end

function Widget:getCanvasRegion ()
  if not self._canvas then return error(("Widget %s is not on a canvas."):format(self.name)) end

  local cPos = vec2.sub(self.position,widget.getPosition(self._canvas))
  return rect.fromVec2(cPos,vec2.add(cPos,self.size))
end

function Widget:onCanvas (c)
  self._canvas = c
  return self
end

function Widget:within (canvasPosition,cname)
  if not self._canvas then
    return self:onCanvas(cname):within(canvasPosition)
  end
  return rect.contains(self.canvasRegion,canvasPosition)
end