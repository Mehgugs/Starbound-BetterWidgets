require"/better-widgets/widget.lua"

ScrollArea = Widget:extend()
Scrollarea = ScrollArea
function ScrollArea:initial ()
    self.nonce = ("%s.%%s"):format(self.name)
end

local idx = ScrollArea.__index
function ScrollArea:__index(key)
    return self:child(key) or idx(key)
end

function ScrollArea:getSize ()
    if not self._size then 
        local sz = self:config"rect"
        self._size = {sz[3] - sz[1], sz[4]- sz[2]}
    end
    return self._size
end

function ScrollArea:setSize()
    return sb.logError("ScrollArea:setSize doesn't work as expected; ask the devs !!")
end

function ScrollArea:child (name)
    return self:config"children"[name]
end