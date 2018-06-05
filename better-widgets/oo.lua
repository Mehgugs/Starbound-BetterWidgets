require"/scripts/common/utils.lua"
local unpack,insert,static = table.unpack,table.insert,{}

local function indexer(class)
  return function(self,k)
    local getKey = 'get'..tostring(k):gsub("^.",string.upper)
    if class[getKey] then
      return class[getKey](self)
    elseif class[k] and not static[class][k] then
      return class[k]
    end
  end
end

local function newindexer (class)
  return function(self,k,v)
    local setKey = 'set'..tostring(k):gsub("^.",string.upper)
    if class[setKey] then
      return class[setKey](self,v)
    else
      return rawset(self,k,v)
    end
  end
end

function newObject (t)
  t = t or {}
  t.__newindex = newindexer(t)
  t.__index = indexer(t)
  static[t] = {}
  return t
end

function extender(base,t)
  local sub = t or {}
  sub.__base = base
  return setmetatable(newObject(sub), {__index = base})
end

local Object = newObject{__info = "object"}; function Object:initial()end
function Object:new (...)
  -- constructor
  local new = setmetatable({}, self)
  new:initial(...)
  return new
end

function Object:extend (t)
  return extender(self,t)
end

function Object:static( name )
  static[self][name] = true
  return self
end

local function mix( self, cls )
  if type(cls) == 'string' then cls = import(cls) end
  for k,v in pairs(cls) do 
    if k:sub(1,2) ~= '__' then self[k] = v end
  end
end
function Object:mix( ... )
  for _, obj in ipairs{...} do mix(self, obj) end
  return self
end
