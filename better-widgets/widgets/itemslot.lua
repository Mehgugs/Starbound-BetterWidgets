require"/better-widgets/widget.lua"

Itemslot = Widget:extend()
ItemSlot = Itemslot

function ItemSlot:initial ()
  self._progress = 0
end

function ItemSlot:getItem ()
  return widget.itemSlotItem(self.name)
end

function ItemSlot:setItem (desc)
  if type(desc) ~= 'table' then
    desc = {name = desc, count = 1, parameters = {}}
  end
  widget.setItemSlotItem(self.name,desc)
  return self
end

function ItemSlot:setProgress (prog)
  self._progress = prog
  widget.setItemSlotProgress(self.name,prog)
end

function ItemSlot:getProgress ()
  return self._progress or 0
end