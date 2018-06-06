require"/better-widgets/oo.lua"
Deque =Object:extend
{
    __info = "object/deque",
    initial = function(self)
        self._queue = {}
        self._first = 0
        self._last = -1
        self._rng = sb and sb.makeRandomSource()
    end,
    is_empty = function(self) return self._first == 0 and self._last == -1 end,
    pushleft = function(self, v)
        local first = self._first - 1
        self._first = first
        self._queue[first] = v
    end,
    pushright = function(self, v)
        local last = self._last + 1
        self._last = last
        self._queue[last] = v
    end,
    popleft = function(self)
        local first = self._first
        if first > self._last then return end
        local value = self._queue[first]
        self._queue[first] = nil        -- to allow garbage collection
        self._first = first + 1
        return value
    end,
    popright = function(self)
        local last = self._last
        if self._first > last then return end
        local value = self._queue[last]
        self._queue[last] = nil        -- to allow garbage collection
        self._last = last - 1
        return value
    end,
    __deque_iter_left = function(state, i) 
        if i < state._last then 
            return i+1, state._queue[i+1]
        end
    end,
    __deque_iter_right = function(state, i) 
        if i > state._first then 
            return i-1, state._queue[i-1]
        end
    end,
    _rand = function(self, i,j)
        if sb then 
            if not self._rng then 
                self._rng = sb.makeRandomSource()
            end
            return self._rng:randInt(i,j)
        else
            math.randomseed(os.time())
            return math.random(i,j)
        end
    end,
    shuffle = function(self)
        local i = self._first-1
        while i < self._last do 
            i = i+1
            local j = self:_rand(self._first, i)
            self._queue[i], self._queue[j] = self._queue[j], self._queue[i]
        end
        return self
    end,
    fromleft = function(self) return self.__deque_iter_left, self, self._first-1 end,
    fromright = function(self) return self.__deque_iter_right, self, self._last+1 end,
    __consume_left = function(state) return state:popleft() end, 
    __consume_right = function(state) return state:popright() end,  
    drainleft = function(self) return self.__consume_left, self end,
    drainright = function(self) return self.__consume_right, self end,
    first = function (self) return self._queue[self._first] end,
    last = function (self) return self._queue[self._last] end  
}