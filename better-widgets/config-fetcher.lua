local unpack,insert,remove = table.unpack, table.insert, table.remove
local pop = function(t) return remove(t,1) end
local containerPath = {
  scrollArea = "children.%s",
  list = "schema.listTemplate.%s",
  layout = "children.%s"
}

local fetchConfig = function(n) return config.getParameter(("gui.%s"):format(n)) end

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

function doFixPath(path, i)
    i = i or 1
    
    local parent, rest = concat(path, ".", 1, i)
    local parentType = widgetType(parent)
    if parentType and path[i+1] then 
        local nextWidgetPath = ("%s%s.%s"):format(parent,containerInserts[parentType] or '', path[i+1])
        local nextType = widgetType(nextWidgetPath)
        if nextType then 
            path[i] = parent .. containerInserts[parentType] or ''
            return doFixPath(path, i+1)
        end
    end

    return concat(path, ".")
end

local fixedPaths = setmetatable({}, {
    __mode = "k",
    __index = function(self, path)
        sb.logInfo("path %s needs expansion", path)
        local fixed = doFixPath(split(path, "[^.]+"))
        self[path] = fixed
        return fixed 
    end
})

function fixPath(path)
    return fixedPaths[path]
end

function widgetParameter(path, ...) 
    path = path:format(...)
    return fetchConfig(path) or fetchConfig(fixPath(path))
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
            return widgetConfig{noop,unpack(parts)}
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