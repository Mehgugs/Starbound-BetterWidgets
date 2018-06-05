require"/better-widgets/widget.lua"

Itemgrid = Widget:extend()
ItemGrid = Itemgrid

function ItemGrid:items ()
  return widget.itemGridItems(self.name)
end
