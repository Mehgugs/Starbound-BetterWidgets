require"/better-widgets/widget.lua"

ButtonGroup = Widget:extend()
Buttongroup = ButtonGroup

function ButtonGroup:getSelectedOption()
  return widget.getSelectedOption(self.name)
end

function ButtonGroup:getSelectedData()
  return widget.getSelectedData(self.name)
end

function ButtonGroup:setSelectedOption (index)
  widget.setSelectedOption(self.name,index)
  return self
end

function ButtonGroup:setOptionEnabled (index,enb)
  widget.setOptionEnabled(self.name,index,enb)
  return self
end

function ButtonGroup:setOptionVisible (index,enb)
  widget.setOptionVisible(self.name,index,enb)
  return self
end