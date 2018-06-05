require"/better-widgets/widget.lua"

Slider = Widget:extend()

function Slider:initial(  )
  self._offset = 0
  self._range = self:config"range"
end

function Slider:setEnabled (en)
  widget.setSliderEnabled(self.name,en)
  return self
end

function Slider:setOffset(v)
  self._offset = v or 0
  return self
end

function Slider:getValue ()
  return widget.getSliderValue(self.name) + self._offset
end

function Slider:setValue (v)
  widget.setSliderValue(self.name,v- self._offset)
end

function Slider:setMax(  )
  local r = self._range
  self.value = r[2]
  return self
end

function Slider:getRange ()
  return copy(self._range)
end

function Slider:setRange (min,max,delta)
  if type(min) == 'table' then
    min,max,delta = table.unpack(min,1,3)
  end
  self._range = {min, max, delta or self._range[3]}
  return widget.setSliderRange(self.name,min,max,delta or self._range[3])
end