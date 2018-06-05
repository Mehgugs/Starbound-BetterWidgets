require"/better-widgets/widget.lua"

Layout = Widget:extend()

function Layout:initial ()
    local sz = self:config"rect"
    self._size = {sz[3] - sz[1], sz[4]- sz[2]}
    self.nonce = ("%s.%%s"):format(self.name)
end

function Layout:setSize()
    return sb.logError("Layout:setSize doesn't work as expected; ask the devs !!")
end

function Layout:getSize ()
    return self._size
end

function Layout:child (name)
    return self:config"children"[name]
end

function Layout:path (child)
    return self.nonce:format(child)
end