--- public interface for using the widget objects
--  @module bw
--  @field widgets the table of widgets from "scriptedWidgets" config parameter
require"/better-widgets/widget.lua"
local get = rawget
local upper = string.upper
local function noun(s) return s:lower():gsub("^.",upper,1) end

bw = { widgets = {} }

setmetatable(bw, bw)

--- loads the script for the corresponding widget type
--  @within bw
--  @tparam string widtype the widget type
function bw.load(widtype)
    return require(("/better-widgets/widgets/%s.lua"):format(widtype))
end

--- loads the script for the corresponding custom widget type
--  @within bw
--  @tparam string name the name of the custom widget type
function bw.loadCustom(name)
    bw.init()
    if bw.manifest[name] then 
        return require(util.absolutePath("/better-widgets/custom/", bw.manifest[name]))
    end
end

local function loadWid(name, ref)
    if get(bw.widgets, ref) then 
        return error(("Cannot create a widget with the reference '%s'; it already exists."):format(ref), 2)
    end
    local widType = widgetParameter("%s.type", name)
    if widType == nil then 
        return error(("Widget '%s' does not exist."):format(name), 2) 
    end
    
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
--- loads a widget object
--  @within bw
--  @tparam string name the name/path of the widget
--  @param[opt] ref internal parameter, do not use
--  @return the widget object
function bw.loadScriptedWidget(name, ref)
    ref = ref or name:match("[^.]+$")
    return get(bw.widgets,ref) or loadWid(name, ref) 
end

local function loadScriptedWidgets()
    for name,ref in pairs(config.getParameter("scriptedWidgets",{})) do 
        loadWid(name, ref)
    end
end

--- internally called by the module to initialize widgets and load the custom widget manifest
--  @within bw
function bw.init()
    if not bw.ready and root then 
        bw.ready = true
        bw.manifest = root.assetJson("/custom-widgets.json")
        loadScriptedWidgets()
    end
end

--- alias for loading a widget
--  @within bw metamethods
--  @function bw
--  @see bw.loadScriptedWidget
---

bw.__call = function(_,...) return bw.loadScriptedWidget(...) end

setmetatable(bw.widgets, {__index = function(self, k) 
    bw.init()
    return get(self, k)
end})

--- table of widgets available
--  @table widgets
--  @within bw
widgets = bw.widgets