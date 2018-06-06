require"/better-widgets/widget.lua"

List = Widget:extend()

function List:initial ()
  widget.clearListItems(self.name)
  self.list = { }
  self.widgets = { }
  self._components = { }
  self.length = 0
  self.nonce = ("%s.%%s"):format(self.name)
  self.full_nonce = ("%s.%%s.%%s"):format(self.name)
end

function List:clear ()
  self.list = { }
  self.widgets = { }
  self._components = { }
  self.length = 0
  widget.clearListItems(self.name)
  return self
end

function List:addItems(n)
  for i=1,n do
    local index = widget.addListItem(self.name)
    self.length = self.length + 1
    self.widgets[index] = self.length
    insert(self.list,index)
    self._components[self.length] = self:makeComponent(index)
  end
  return self
end

function List:addItem ()
  local index = widget.addListItem(self.name)
  self.length = self.length + 1
  self.widgets[index] = self.length
  insert(self.list,index)
  self._components[self.length] = self:makeComponent(index)
  return self.nonce:format(index),index
end

function List:add(n)
  if n then return self:addItems(n) else return self:addItem() end
end

local function listiter(self)
  util.each(self.list,coroutine.yield)
end
function List:items ()
  return coroutine.wrap(listiter),self
end

function List:removeListItem (n)
  if type(n) == 'string' then
    n = self.widgets[n]
  end
  local id = table.remove(self.list,n)
  self.widgets[id] = nil
  widget.removeListItem(self.name,n)
  self.length = self.length -1
  self._components[n] = nil
  return self
end

function List:getSelected ()
  return widget.getListSelected(self.name)
end

function List:indexOf(idx)

  return self.widgets[idx]
end

function List:idOf(idx)

  return self.list[idx]
end

function List:setSelected (name)
  if type(name) == 'number' then
    name = self.list[name]
  end
  widget.setListSelected(self.name,name)
end

function List:registerMemberCallback (fname,func)
  widget.registerMemberCallback(self.name,fname,func)
  return self
end

function List:componentPath (idx,name)
  if type(idx) == 'number' then
    idx = self.list[idx]
  end
  local fullName = self.full_nonce:format(idx,name)
  return fullName, ("%s.%s"):format(self.name,name)
end

function List:itemName(idx)
    if type(idx) == 'number' then
      idx = self.list[idx]
    end
  return self.nonce:format(idx)
end

function List:makeComponent (idx)
  local out = {_listIndex = idx}
  local wids = self:config"schema".listTemplate
  for widName,conf in pairs(wids) do
    local widType = conf.type
    local fullName = self:componentPath(idx,widName)
    local class = widType:lower():gsub("^.",string.upper,1)
    out[widName] = _ENV[class]:newFrom(fullName,conf)
  end
  return out
end

function List:component (idx)
  if type(idx) == 'string' then
    idx = self.widgets[idx]
  end
  return self._components[idx]
end

function List:componentWidgetName(idx,widgetName)
  if type(idx) == 'number' then
    idx = self.list[idx]
  end
  return self.full_nonce:format(idx,widgetName)
end

function List:components ()
  return ipairs(self._components)
end