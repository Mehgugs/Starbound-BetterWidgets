require"/better-widgets/widget.lua"

TextBox = Widget:extend()
Textbox = TextBox

function TextBox:initial ()
    self._color = self:config"fontColor"
    self.fontSize = self:config"fontSize" or 8
end
function TextBox:getSize ()
    return {hobo.getLength(self.text,self.fontSize),self.fontSize}
end

function TextBox:getText ()
    return widget.getText(self.name)
end

function TextBox:setText (txt)
    widget.setText(self.name,txt)
    return self
end

function TextBox:setFontColor (c)
    self._color = c
    widget.setFontColor(self.name,c)
    return self
end

function TextBox:getFontColor ()
  return self._color or {255,255,255}
end