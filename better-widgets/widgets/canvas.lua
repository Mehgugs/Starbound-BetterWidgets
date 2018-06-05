require"/better-widgets/widget.lua"

Canvas = Widget:extend()

function Canvas:initial ()
    self.canvas = widget.bindCanvas(self.name)
    self._locked = false
    local sz = self:config"rect"
        self._size = {sz[3] - sz[1], sz[4]- sz[2]}
end
function Canvas:getSize()
    return self._size
end
function Canvas:setLocked( b )
    self._locked = b
    return self
end

function Canvas:__index(k)
    local getKey = 'get'..k:gsub("^.",string.upper)
    if Canvas[getKey] then
        return Canvas[getKey](self)
    elseif rawget(self,"canvas") and self.canvas[k] then
        local cMethod = function(self,...) if not self._locked then return self.canvas[k](self.canvas,...) end end
        rawset(self,k,cMethod)
        return cMethod
    else
        return Canvas[k]
    end
end
--[[
  These functions draw pixels by using small / shaped lines
  hopefully CF add get/set pixel functions some time in the future 
]]
function Canvas:drawPixels(r,pix,async)
  if self._locked then
    return;
  end
  self.canvas:clear()
  local poly = {{0,0},{0,0}}
  for i = r[1],r[3] do
      for j = r[2],r[4] do
          poly[1][1] = i
          poly[1][2] = j
          poly[2][1] = i+0.25
          poly[2][2] = j
          self.canvas:drawPoly(poly,pix[i][j],1.5)   
          if async then coroutine.yield() end
      end   
  end
end
local spoly = {{0,0}, {0, 0}}
function Canvas:drawPixel(x,y,value)
  if self._locked then
    return;
  end 
  spoly[1][1] = x
  spoly[1][2] = y
  spoly[2][1] = x
  spoly[2][2] = y+0.2
  self.canvas:drawPoly(spoly,value,1.5)  
  return self
end

function Canvas:fill( color )
  self:clear()
  local sz = self.Size
  self:drawRect({0,0,sz[1], sz[2]}, color)
end