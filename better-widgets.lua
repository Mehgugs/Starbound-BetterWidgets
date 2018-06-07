--- public interface for using the widget objects.
--  @module bw
--  @field widgets the table of widgets from "scriptedWidgets" config parameter
require"/better-widgets/widget.lua"
local get = rawget

bw = { widgets = {}, registered = {}, refs = {} }

setmetatable(bw, bw)


--- loads a widget object.
--  @within bw
--  @tparam string name the name/path of the widget
--  @param[opt] ref internal parameter, do not use
--  @return the widget object
function bw.loadScriptedWidget(name,ref)
    bw.init()
    ref = ref or name:gsub("%.", "_")
    local wid = get(bw.widgets,ref) 
    if wid == nil then 
        bw.refs[name] = ref
        wid = loadWidget(name, ref, bw.widgets, bw)
    end 
    return wid
end

local function loadScriptedWidgets()
    for name,ref in pairs(config.getParameter("scriptedWidgets",{})) do 
        loadWidget(name, bw.widgets, ref, bw.widgets, bw)
        bw.refs[name] = ref
    end
end

--- internally called by the module to initialize widgets and load the custom widget manifest.
--  @within bw
function bw.init()
    if not bw.ready and root then 
        bw.ready = true
        bw.manifest = root.assetJson("/custom-widgets.json")
        for name, src in pairs(bw.manifest) do 
            bw.log("loaded plugin %s @ '%s'", name, src)
        end
    end
end

--- for logging information from bw.
--  @within bw
--  @tparam string content the content of the message
--  @tparam[opt] string ... format parameters to content:format
function bw.log(content, ...)
    local msg = content:format(...)
    return sb.logInfo("[Better-Widgets] %s", msg)
end

--- for logging warnings from bw.
--  @within bw
--  @tparam string content the content of the message
--  @tparam[opt] string ... format parameters to content:format
function bw.warn(content, ...)
    local msg = content:format(...)
    if bw._strict then return bw.fatal("[From warning] %s", msg) end
    return sb.logWarn("[Better-Widgets] %s", msg)
end

--- for logging errors from bw.
--  @within bw
--  @tparam string content the content of the message
--  @param[opt] ... format parameters to content:format
function bw.error(content, ...)
    local msg = content:format(...)
    if bw._strict then return bw.fatal("[From error] %s", msg) end
    return sb.logError("[Better-Widgets] %s", msg)
end

--- for throwing a lua error from bw.
--  @within bw 
--  @tparam string msg the message
--  @param[opt] ... format parameters to msg:format
function bw.fatal(msg,...)
    local content = msg:format(...)
    return error(("[Better-Widgets] [Fatal] %s"):format(content), 2)
end

function bw.debug(msg, ...)
    return bw._debug and bw.log("[Debug] %s", msg:format(...))
end 

function bw.debugging()
    bw._debug = true
end

function bw.prod()
    bw._debug = false
end 

function bw.strict()
    bw._strict = true
end

bw.normalizeNames = false

--- alias for loading a widget.
--  @within bw metamethods
--  @function bw
--  @see bw.loadScriptedWidget
---
function bw:__call(name)
    return bw.loadScriptedWidget(name)
end

local better_env_props = {}
function better_env_props.betterwidget(widgetName, widgetData)
    local name = bw.registered[widgetName]
    local ref = name and bw.refs[name]
    if name and ref then 
        local wid = get(bw.widgets, ref)
        if wid == nil then 
            bw.fatal("Could not find the widget for callback applied to '%s'? (reference='%s')", widgetName, ref)
        end
        return wid:callback(bw.normalizeNames and name or widgetName, widgetData)
    else
        bw.warn("Widget '%s' did not have it's callback configured?", widgetName)
    end
end

local set = rawset 

function rawset(tbl, key, value)
    if tbl == _ENV and better_env_props[key] ~= nil then
        bw.fatal("Cannot overwrite global property '%s'.", key)
    end
    return set(tbl, key, value)
end

local better_env = {
    __metatable = {},
    __index = better_env_props,
    __newindex = function(self, k, v)
        if better_env_props[k] ~= nil then
            bw.fatal("Cannot overwrite global property '%s'.", key)
        end
        return set(self, k, v) 
    end
}

setmetatable(_ENV, better_env)

setmetatable(bw.widgets, {__index = function(self, k) 
    bw.init()
    loadScriptedWidgets()
    return get(self, k)
end})

--- table of widgets available.
--  @table widgets
--  @within bw
widgets = bw.widgets