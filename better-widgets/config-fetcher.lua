local unpack,insert,remove = table.unpack, table.insert, table.remove
local pop = function(t) return remove(t,1) end
local containerPath = {
  scrollArea = "children.%s",
  list = "schema.listTemplate.%s",
  layout = "children.%s"
}

local fetchConfig = function(n,...) return config.getParameter(("gui.%s"):format(n)) end

local function split(str, patt)
	local out = {}
  for match in str:gmatch(patt) do
    insert(out,match)
  end
  return out
end

local widTypes = setmetatable({}, {__mode = "k"})
function widgetType(path)
    if widTypes[path] then return widTypes[path]
    else local typ = fetchConfig(("%s.type"):format(path))
        widTypes[path] = typ
        return typ 
    end
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

local containerInserts = {
    scrollArea = ".children",
    list = ".schema.listTemplate",
    layout = ".children"
}

local function fixPath(path)
    local parent, rest = path:match("([^.]+)%.(.+)")
    local parentType= widgetType(parent)
    if parentType then 
        local parentPath = containerInserts[parentType] and parent .. containerInserts[parentType] or parent
        return ("%s.%s"):format(parentPath, fixPath(rest))
    end
    return path
end

function widgetParameter(path, ...)
    return fetchConfig(fixPath(path:format(...)))
end

function widgetConfig(path)
    local try = fetchConfig(path)
    return try or findNestedWidgetConfig(split(path, "[^.]+"))
end