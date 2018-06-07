local unpack,insert,remove = table.unpack, table.insert, table.remove
local pop = function(t) return remove(t,1) end
local containerPath = {
  scrollArea = "children.%s",
  list = "schema.listTemplate.%s",
  layout = "children.%s"
}

local _didNotExist = {}
local didNotExist = tostring(_didNotExist)
local fetchConfig = function(n) local value = config.getParameter(("gui.%s"):format(n), didNotExist)
    if value == didNotExist then 
        return nil, true
    else
        return value 
    end
end

local function split(str, patt)
	local out = {}
  for match in str:gmatch(patt) do
    insert(out,match)
  end
  return out
end


local function widgetType(path)
    return fetchConfig(("%s.type"):format(path))
end

local containerInserts = {
    scrollArea = ".children",
    list = ".schema.listTemplate",
    layout = ".children"
}

local concat = table.concat

local dontFix = {
    size = true,
    rect = true,
    fontSize = true,
    value = true,
}

local function doFixPath(path, i)
    i = i or 1
    
    local parent = concat(path, ".", 1, i)
    local parentType = widgetType(parent)
    local next = path[i+1]
    if parentType and next and not dontFix[next] then 
        local nextWidgetPath = ("%s%s.%s"):format(parent,containerInserts[parentType] or '', next)
        local nextType = widgetType(nextWidgetPath)
        if nextType then 
            path[i] = parent .. containerInserts[parentType] or ''
            return doFixPath(path, i+1)
        end
    end

    return path
end

local fixedPaths = setmetatable({}, {
    __mode = "k",
    __index = function(self, path)
        sb.logInfo("path %s needs expansion", path)
        local fixed = split(path, "[^.]+")
        doFixPath(fixed)
        self[path] = concat(fixed, ".") 
        return self[path]
    end
})

function fixPath(path)
    return fixedPaths[path]
end

function widgetParameter(path, ...) 
    path = path:format(...)
    local try = fetchConfig(path)
    if try then 
        return try, path
    else
        local fixed = fixPath(path)
        return fetchConfig(fixed), fixed
    end
end

function rawparam(path, ...)
    return fetchConfig(path:format(...))
end

local function findNestedWidgetConfig(parts)
    local parent = pop(parts)
    local parentType = widgetType(parent)
    if not parentType then return nil end
    local child = pop(parts)
    
    if parentType ~= 'radioGroup' then
        local query = containerPath[parentType]:format(child)
        local noop = ("%s.%s"):format(parent,query)
        if next(parts) == nil then
            return fetchConfig(noop),noop
        else
            return findNestedWidgetConfig{noop,unpack(parts)}
        end
    else
        local parentConfig = fetchConfig(parent)
        for _,button in ipairs(parentConfig.buttons) do
            if button.id == child then
                return button, ("%s.buttons.%s"):format(parent,id)
            end
        end
    end
end

function widgetConfig(path)
    local try = fetchConfig(path)
    return try or findNestedWidgetConfig(split(path, "[^.]+"))
end

function loadWidgetScript(widtype)
    return require(("/better-widgets/widgets/%s.lua"):format(widtype))
end

function loadCustomWidgetScript(manifest, name)
    if manifest[name] then 
        return require(util.absolutePath("/better-widgets/custom/", manifest[name]))
    end
end

local function path(t, keys)
    for _, child in ipairs(keys) do 
        if t[child] == nil then return nil end
        t = t[child]
    end
    return t
end

function access(t, pathString)
    return path(t, split(pathString, "[^.]+"))
end

local get = rawget
local upper = string.upper
local function noun(s) return s:lower():gsub("^.",upper,1) end

function loadWidget(name, ref, cache, master)
    if not (cache and ref) then 
        master.fatal("No cache provided please use bw(path) to load widgets instead.")
    end
    if get(cache, ref) then 
        master.fatal("Cannot create a widget with the reference '%s'; it already exists.", ref)
    end
    local widPath = fixPath(name)
    local widType = rawparam("%s.type",widPath)
    if widType == nil then 
        master.fatal("Widget '%s' does not exist.", name) 
    end
    
    local custom = rawparam("%s.typeOverride", widPath)
    local class = noun(custom or widType)

    if custom then
        loadCustomWidgetScript(master.manifest, custom)
    else
        loadWidgetScript(widType)
    end

    if custom and _ENV[class] == nil then
        loadWidgetScript(widType)
        master.warn("Could not find custom widget object %s (aka %s) using '%s' instead.",custom,class,widType)
        class = noun(widType)
    end
    cache[ref] = _ENV[class]:new(name, widType, widPath, master)
    return cache[ref]
end