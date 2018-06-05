require"/better-widgets/widget.lua"

local upper = string.upper
local function noun(s) return s:lower():gsub("^.",upper,1) end

bw = { widgets = {} }

setmetatable(bw, bw)

function bw.load(widtype)
    return require(("/better-widgets/widgets/%s.lua"):format(widtype))
end

function bw.loadCustom(name)
    bw.init()
    if bw.manifest[name] then 
        return require(util.absolutePath("/better-widgets/custom/", bw.manifest[name]))
    end
end

local function loadWid(name, ref)
    local widType = widgetType(name)
    if widType == nil then error(("widget '%s' does not exist."):format(name)) end
    
    local custom = widgetParameter("%s.typeOverride", name)
    local class = noun(custom or widType)

    if custom then
        bw.loadCustom(custom)
    else
        bw.load(widType)
    end

    if custom and _ENV[class] == nil then
        bw.load(widType)
        sb.logWarn("Could not find custom widget object %s (aka %s) using '%s' instead.",custom,class,widType)
        class = noun(widType)
    end
    bw.widgets[ref] = _ENV[class]:new(name)
    return bw.widgets[ref]
end

function bw.loadScriptedWidget(name, ref)
    ref = ref or name:match("[^.]+$")
    return bw.widgets[ref] or loadWid(name, ref) 
end

local function loadScriptedWidgets() --creates a global "widgets" table containing widget objects.
    for name,ref in pairs(config.getParameter("scriptedWidgets",{})) do 
        loadWid(name, ref)
    end
end

function bw.init()
    if not bw.ready and root then 
        bw.ready = true
        bw.manifest = root.assetJson("/custom-widgets.json")
        loadScriptedWidgets()
    end
end

bw.__call = bw.loadScriptedWidget

setmetatable(bw.widgets, {__index = function(self, k) 
    bw.init()
    return get(self, k)
end})

widgets = bw.widgets