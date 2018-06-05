require"/better-widgets/widget.lua"

Button = Widget:extend()

function Button:initial ()
    self.caption = self:config"caption" or ''
    self._images = {
        base = self:config"base",
        hover = self:config"hover",
        pressed = self:config"pressed",
        disabled = self:config"disabled",
    }
    if self:config"checkable" then 
      self._checked_images = {
        base = self:config"baseImageChecked",
        hover = self:config"hoverImageChecked",
        pressed = self:config"pressedImageChecked",
        disabled = self:config"disabledImageChecked",
      }
    end
end

function Button:setText (txt)
    self.caption = txt
    widget.setText(self.name,txt)
    return self
end

function Button:getTextSize ()
    local fontSize = self:config"fontSize" or 8
    return {hobo.getLength(self.caption:gsub('%^.-;',''),fontSize), fontSize}
end

function Button:getText ()
  return self.caption or ''
end

function Button:setFontColor (c)
    widget.setFontColor(self.name,c)
    return self
end

function Button:setEnabled (en)
  widget.setButtonEnabled(self.name,en)
  return self
end

function Button:setImage (base)
    self._images.base = base
    widget.setButtonImage(self.name,base)
    return self
end

function Button:getImage ()
  return self._images.base
end

function Button:setImages (set)
  for k,v in pairs(set) do
    self._images[k] = v
  end
  widget.setButtonImages(self.name,set)
  return self
end

function Button:getImages ()
  return copy(self._images)
end

function Button:setCheckedImages (set)
  if self:config"checkable" then
    for k,v in pairs(set) do
      self._checked_images[k] = v
    end
    widget.setButtonCheckedImages(self.name,set)
  end
  return self
end

function Button:getCheckedImages()
  return copy(self._checked_images)
end

function Button:setOverlayImage (over)
  self._images.overlay = over
  widget.setButtonOverlayImage(self.name,over)
  return self
end

function Button:getOverlayImage ()
  return self._images.overlay
end

function Button:getChecked ()
  return widget.getChecked(self.name)
end

function Button:setChecked (chk)
  widget.setChecked(self.name,chk)
  return self
end