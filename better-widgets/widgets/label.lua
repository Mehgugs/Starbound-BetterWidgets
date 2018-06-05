require"/better-widgets/widget.lua"

Label = Widget:extend()

function Label:initial ()
    self.txt = self:config"value"
    self._color = self:config"fontColor"
    self.fontSize = self:config"fontSize" or 8 
end

function Label:setText(txt)
    self.txt = txt
    widget.setText(self.name, txt)
    return self
end

function Label:getText() return self.txt or '' end

function Label:getFontColor()
    return self._color or "#FFFFFF"
end

function Label:setFontColor(c)
    self._color = c
    widget.setFontColor(self.name, c)
    return self
end 