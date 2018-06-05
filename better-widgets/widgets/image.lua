require"/better-widgets/widget.lua"

Image = Widget:extend()

function Image:initial ()
  self._image = self:config"file" or ''
end
function Image:setImage (pth)
  self._image = pth
  widget.setImage(self.name,pth)
  return self
end

function Image:getImage ()
  return self._image
end

function Image:setScale (scale)
  self._scale = scale
  widget.setImageScale(self.name,scale)
  return self
end

function Image:getScale ()
  return self._scale or 1.0
end

function Image:setRotation (ang)
  self.angle = ang
  widget.setImageRotation(self.name,ang)
  return self
end

function Image:getRotaton ()
  return self.angle or 0
end

function Image:applyDirectives(d)
    return self:setImage(self.image .. d)
end