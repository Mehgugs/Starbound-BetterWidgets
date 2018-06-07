--- Button widget class.
--  @classmod Button 
require"/better-widgets/widget.lua"

Button = Widget:extend()

-- constructor function called by Button:new()
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

--- Sets the button's caption text
--  @tparam string txt the text to set
--  @return self
function Button:setText (txt)
    self.caption = txt
    widget.setText(self.name,txt)
    return self
end

--- Gets the size of the caption text in pixels
--  @treturn Vec2 the width, height of the text
function Button:getTextSize ()
    local fontSize = self:config"fontSize" or 8
    return {hobo.getLength(self.caption:gsub('%^.-;',''),fontSize), fontSize}
end

--- Gets the button's caption text
--  @treturn string the text or '' if none is set
function Button:getText ()
  return self.caption or ''
end

--- Sets the color of the button's caption text
--  @tparam Color c the font color
--  @return self
function Button:setFontColor (c)
    widget.setFontColor(self.name,c)
    return self
end

--- Sets the button's enabled state
--  @tparam boolean en the state
--  @return self
function Button:setEnabled (en)
  widget.setButtonEnabled(self.name,en)
  return self
end

--- Sets the button's base image
--  @tparam string base the asset path to the base image
--  @return self
function Button:setImage (base)
    self._images.base = base
    widget.setButtonImage(self.name,base)
    return self
end

--- Gets the button's base image
--  @treturn string the image's asset path
function Button:getImage ()
  return self._images.base
end

--- Sets the current image(s) used by the button
--  @tparam table set the set of images to override
--  @return self
function Button:setImages (set)
  for k,v in pairs(set) do
    self._images[k] = v
  end
  widget.setButtonImages(self.name,set)
  return self
end

--- Gets the complete set of images the button uses
--  @treturn table 
function Button:getImages ()
  return copy(self._images)
end

--- Sets the current checked image(s) used by the button
--  @tparam table set the set of images to override ex:
--  @return self
function Button:setCheckedImages (set)
  if self:config"checkable" then
    for k,v in pairs(set) do
      self._checked_images[k] = v
    end
    widget.setButtonCheckedImages(self.name,set)
  end
  return self
end

--- Gets the complete set of checked images the button uses
--  @treturn table 
function Button:getCheckedImages()
  return copy(self._checked_images)
end

--- Sets the button's overlay image 
--  @tparam string over the asset path to the overlay image
--  @return self 
function Button:setOverlayImage (over)
  self._overlay = over
  widget.setButtonOverlayImage(self.name,over)
  return self
end

--- Gets the button's overlay image if it exists
--  @treturn ?string the overlay image
function Button:getOverlayImage ()
  return self._overlay
end

--- Gets the checked state of the button
--  @treturn boolean
function Button:getChecked ()
  return widget.getChecked(self.name)
end

--- Sets the checked state of a checkable button
--  @tparam boolean chk the check state
--  @return self
function Button:setChecked (chk)
  widget.setChecked(self.name,chk)
  return self
end