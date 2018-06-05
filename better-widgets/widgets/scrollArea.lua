require"/better-widgets/widget.lua"

ScrollArea = Widget:extend()
Scrollarea = ScrollArea
function ScrollArea:initial ()
    local sz = self:config"rect"
    self._size = {sz[3] - sz[1], sz[4]- sz[2]}
end

function ScrollArea:getSize ()
    return self._size
end

function ScrollArea:setSize()
    return sb.logError("ScrollArea:setSize doesn't work as expected; ask the devs !!")
end

function ScrollArea:child (name)
    return self:config"children"[name]
end