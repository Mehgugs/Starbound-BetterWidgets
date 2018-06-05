require"/better-widgets/widgets/canvas.lua"
require"/better-widgets/custom/colorpicker/color_data.lua"
local img_path = '/interface/easel/spectrumchart.png'
local img_size = {158,55}

Colorpicker = Canvas:extend()

function Colorpicker:initial( ... )
    Canvas.initial(self,...)
    self.canvas:clear()
    self.canvas:drawImage(img_path,self.position)
    self._size = self.canvas:size()
    self.Locked = true
    self._selected = 0
    self._x = 0
    self._y = 0
    self._imgx, self._imgy = img_size[1], img_size[2]
end

local function getByte(value, byte)
    return (value >> (8*byte)) & 0xFF
end
local cfmt = "%06X"

function Colorpicker:clickEvent( position, button, isDown )
    if button == 0 and isDown then
        local x,y = position[1], position[2]
        x,y = util.clamp(x,0,self._imgx), util.clamp(y,0,self._imgy)
        self._selected = spectrum_data[x][y]
        self._x = x
        self._y = y
    end
end

function Colorpicker:getColor(  )
    return cfmt:format(self._selected)
end

function Colorpicker:getRed(  )
    return getByte(self._selected, 2)
end

function Colorpicker:getGreen(  )
    return getByte(self._selected, 1)
end

function Colorpicker:getBlue(  )
    return getByte(self._selected, 0)
end

Colorpicker.getR, Colorpicker.getG, Colorpicker.getB = 
    Colorpicker.getRed,
    Colorpicker.getGreen,
    Colorpicker.getBlue;

function Colorpicker:getHue(  )
    return (self._x / img_size[1])*360
end

function Colorpicker:getLightness(  )
    return 1 - (self._y / img_size[2])
end
local tcfmt = "^#%s;"
function Colorpicker:getTextColor( )
    return tcfmt:format(self.Color)
end