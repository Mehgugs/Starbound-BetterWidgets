require"/better-widgets/widget.lua"
local rawget = get

ScrollArea = Widget:extend{sized = false}
Scrollarea = ScrollArea

function ScrollArea:initial (bw)
    self.nonce = ("%s.%%s"):format(self.name)
    self._load = self.master.loadScriptedWidget
end

local idx = ScrollArea.__index
function ScrollArea:__index(key)
    local value = idx(self, key)
    if value == nil and get(self, "initialized") then 
        value = self:child(key) 
    end
    return value
end

function ScrollArea:getSize ()
    if not self.sized then 
        local sz = self:config"rect"
        self._size = {sz[3] - sz[1], sz[4]- sz[2]}
        self.sized = true
    end
    return self._size
end

function ScrollArea:setSize()
    return self.master.error("ScrollArea:setSize doesn't work as expected; ask the devs !!")
end

function ScrollArea:child (name)
    return self._load(self.nonce:format(name))
end