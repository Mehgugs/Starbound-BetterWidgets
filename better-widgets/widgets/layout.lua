require"/better-widgets/widget.lua"
local get = rawget

Layout = Widget:extend{sized = false}
function Layout:initial (bw)
    self.nonce = ("%s.%%s"):format(self.name)
    self._load = self.master.loadScriptedWidget
    
end

local idx = Layout.__index
function Layout:__index(key)
    local value = idx(self, key)
    if value == nil and get(self, "initialized") then 
        value = self:child(key) 
    end
    return value
end

function Layout:getSize ()
    if not self.sized then 
        local sz = self:config"rect"
        self._size = {sz[3] - sz[1], sz[4]- sz[2]}
        self.sized = true
    end
    return self._size
end

function Layout:setSize()
    return self.master.error("ScrollArea:setSize doesn't work as expected; ask the devs !!")
end

function Layout:child (name)
    return self._load(self.nonce:format(name))
end