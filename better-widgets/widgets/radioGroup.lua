require"/better-widgets/widget.lua"

RadioGroup = Widget:extend()
Radiogroup = RadioGroup

function RadioGroup:getSelectedOption()
  return widget.getSelectedOption(self.name)
end

function RadioGroup:getSelectedData()
  return widget.getSelectedData(self.name)
end

function RadioGroup:setSelectedOption (index)
  widget.setSelectedOption(self.name,index)
  return self
end

function RadioGroup:setOptionEnabled (index,enb)
  widget.setOptionEnabled(self.name,index,enb)
  return self
end

function RadioGroup:setOptionVisible (index,enb)
  widget.setOptionVisible(self.name,index,enb)
  return self
end