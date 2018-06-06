require"/better-widgets/widgets/canvas.lua"
require"/better-widgets/deque.lua"
local create,resume,status = coroutine.create, coroutine.resume, coroutine.status
local insert,remove,unpack = table.insert,table.remove,table.unpack

Graph = Canvas:extend()

function Graph:initial()
    Canvas.initial(self)
    self._q = Deque:new()
    self._args = Deque:new()
end 

function Graph:update()
    if self._thread then 
        if status(self._thread) == 'dead' then
            self._thread = nil
            return
        end
        assert(resume(self._thread))
    elseif not self._q:is_empty() then 
        local args = self._args:popleft()
        local nextt = self._q:popleft()
        self._thread = nextt
        assert(resume(nextt,unpack(args)))
    end
end

function Graph:addThread(f, ...)
    self._q:pushright(create(f))
    self._args:pushright{self,...}
end

function Graph:drawPixelsAsync( r,pix )
    return self:addThread(function(canvas,r,pix) 
        canvas:drawPixels(r,pix,true)
    end,r,pix)
end

function Canvas:drawPixelRow(r,pix,async)
    if self._locked then
      if coroutine.isyieldable() then coroutine.yield(); 
      else return;
      end
    end
    self.canvas:clear()
    local poly = {{0,0},{0,0}}
    for j = r[2],r[4] do
        for i = r[1],r[3] do
            poly[1][1] = i
            poly[1][2] = j
            poly[2][1] = i+0.5
            poly[2][2] = j+0.5
            self.canvas:drawPoly(poly,pix[i][j],1.5)   
        end  
        if async then coroutine.yield() end 
    end
end
function Canvas:drawPixelColumn(r,pix,async)
    if self._locked then
      if coroutine.isyieldable() then coroutine.yield(); 
      else return;
      end
    end
    self.canvas:clear()
    local poly = {{0,0},{0,0}}
    for i = r[1],r[3] do
        for j = r[2],r[4] do
            poly[1][1] = i
            poly[1][2] = j
            poly[2][1] = i+0.5
            poly[2][2] = j+0.5
            self.canvas:drawPoly(poly,pix[i][j],1.5)   
        end  
        if async then coroutine.yield() end 
    end
end
local function drawColumnThread(canvas,r,pix) 
    canvas:drawPixelColumn(r,pix,true)
end
local function drawRowThread(canvas,r,pix) 
    canvas:drawPixelRow(r,pix,true)
end
function Graph:drawPixelLinesAsync( r, pix )
    local dx,dy =
        r[3] - r[1],
        r[4] - r[2]
    if math.min(dy,dx) == dy then
        self:addThread(drawColumnThread,r,pix)
    else
        self:addThread(drawRowThread,r,pix)
    end
end

local function mapn(n, start1, stop1, start2, stop2)
    return ((n - start1)/(stop1 - start1)) * (stop2 - start2) + start2
end

function Graph:plot(f,r,zoom,c,axis)
    local s = self:config"rect"
    local sx,sy = s[3] - s[1], s[4] - s[2]
    if axis == nil or axis == true then
        self.canvas:drawLine({0,sy//2},{sx,sy//2},"#ffffff",1.5)
        self.canvas:drawLine({sx//2,0},{sx//2,sy},"#ffffff",1.5)
    end
    for x = r[1],r[3] do
        local x2 = mapn(x,r[1],r[3],zoom[1],zoom[3])
        local val = f(x2)
        if zoom[2] <= val and val <= zoom[4] then
            local y = mapn(val,zoom[2],zoom[4],r[2],r[4])
            self:drawPixel(x,y,c or "#ff5151")
        end
    end
    if axis == nil or axis == true then
        self.canvas:drawText(("%.3f"):format(zoom[1]),{position = {7,(sy//2)+7}},7)
        self.canvas:drawText(("^yellow;x ^reset;%.3f"):format(zoom[3]),{position = {sx,(sy//2)+7}, horizontalAnchor = 'right'},7)
        self.canvas:drawText(("%.3f"):format(zoom[2]),{position = {7 + sx//2,7}},7)
        self.canvas:drawText(("^yellow;y ^reset;%.3f"):format(zoom[4]),{position = {7+ sx//2,sy}, verticalAnchor = 'top'},7)
    end
end

function Graph:plotdetail(f,r,zoom,precision,c,axis)
    local async = precision <= 0.001 --for very precise plots we must render async
    local s = self:config"rect"
    local sx,sy = s[3] - s[1], s[4] - s[2]
    if axis == nil or axis == true then
        self.canvas:drawLine({0,sy//2},{sx,sy//2},"#ffffff",1.5)
        self.canvas:drawLine({sx//2,0},{sx//2,sy},"#ffffff",1.5)
    end

    local n =0
    local prev,p
    for x = r[1],r[3]/precision do
        n=n+1
        x = x*precision
        local x2 = mapn(x,r[1]*precision,r[3],zoom[1],zoom[3])
        local val = f(x2)
        if zoom[2] <= val and val <= zoom[4] then
            local y = mapn(val,zoom[2],zoom[4],r[2],r[4])
            p = {x,y}
            if prev then self.canvas:drawLine(prev,p,c or "#ff5151",1.8) else self:drawPixel(x,y,c or "#ff5151") end
            prev = p 
        end
        if async and n % 1000 == 0 then coroutine.yield() end
    end
    if axis == nil or axis == true then
        self.canvas:drawText(("%.3f"):format(zoom[1]),{position = {7,(sy//2)+7}},7)
        self.canvas:drawText(("^yellow;x ^reset;%.3f"):format(zoom[3]),{position = {sx,(sy//2)+7}, horizontalAnchor = 'right'},7)
        self.canvas:drawText(("%.3f"):format(zoom[2]),{position = {7 + sx//2,7}},7)
        self.canvas:drawText(("^yellow;y ^reset;%.3f"):format(zoom[4]),{position = {7+ sx//2,sy}, verticalAnchor = 'top'},7)
    end
end

function Graph:plotImplicit( f,r,zoom,precision,t,c, axis)
    local s = self:config"rect"
    local sx,sy = s[3] - s[1], s[4] - s[2]
    t = t or 2
    if axis == nil or axis == true then
        self.canvas:drawLine({0,sy//2},{sx,sy//2},"#ffffff",1.5)
        self.canvas:drawLine({sx//2,0},{sx//2,sy},"#ffffff",1.5)
    end
    local n =0
    local p,prev;
    for x = r[1],r[3]/precision do
        x = x*precision
        for y = r[2], r[4]/precision do
            n=n+1
            y = y*precision
            local x2,y2 = 
                mapn(x,r[1],r[3],zoom[1],zoom[3]),
                mapn(y,r[2],r[4],zoom[2],zoom[4])
            local val = f(x2,y2)
            if val == 0 or math.abs(val) <= precision^t then
                p = {x,y}
                if prev then self.canvas:drawLine(prev,p,c or "#51ff51",1.8) else self:drawPixel(x,y,c or "#51ff51") end
                prev = p 
            end
            sb.setLogMap("^;val", val)
            if n % 2000 == 0 then coroutine.yield() end
        end
    end
    if axis == nil or axis == true then
        self.canvas:drawText(("%.3f"):format(zoom[1]),{position = {7,(sy//2)+7}},7)
        self.canvas:drawText(("^yellow;x ^reset;%.3f"):format(zoom[3]),{position = {sx,(sy//2)+7}, horizontalAnchor = 'right'},7)
        self.canvas:drawText(("%.3f"):format(zoom[2]),{position = {7 + sx//2,7}},7)
        self.canvas:drawText(("^yellow;y ^reset;%.3f"):format(zoom[4]),{position = {7+ sx//2,sy}, verticalAnchor = 'top'},7)
    end
end

function Graph:plotParametric( fx,fy,r,l,zoom,precision,c, axis)
    local s = self:config"rect"
    local sx,sy = s[3] - s[1], s[4] - s[2]
    self.canvas:drawLine({0,sy//2},{sx,sy//2},"#ffffff",1.5)
    self.canvas:drawLine({sx//2,0},{sx//2,sy},"#ffffff",1.5)
    local n=0
    local mxp,mxn = 0,math.huge
    local myp,myn = 0,math.huge
    local t= l[1]
    local prev;
    while t <= l[2] do
        t = t+precision
        n=n+1
        local x2,y2 = fx(t), fy(t)
        local x,y = 
            mapn(x2,zoom[1],zoom[3],r[1],r[3]),
            mapn(y2,zoom[2],zoom[4],r[2],r[4]);
        local p = {x,y}
        self:drawPixel(x,y,c or "#5151ff") 
        if prev then self.canvas:drawLine(prev,p,c or "#5151ff",2) end
        prev = p 
        if n%2000 == 0 then coroutine.yield() end
    end
    if axis == nil or axis == true then
        self.canvas:drawText(("%.3f"):format(zoom[1]),{position = {7,(sy//2)+7}},7)
        self.canvas:drawText(("^yellow;x ^reset;%.3f"):format(zoom[3]),{position = {sx,(sy//2)+7}, horizontalAnchor = 'right'},7)
        self.canvas:drawText(("%.3f"):format(zoom[2]),{position = {7 + sx//2,7}},7)
        self.canvas:drawText(("^yellow;y ^reset;%.3f"):format(zoom[4]),{position = {7+ sx//2,sy}, verticalAnchor = 'top'},7)
    end
end

local twopi = math.pi*2
function Graph:plotPolar(fr,r,zoom,revolutions,precision,c, axis)
    local s = self:config"rect"
    local sx,sy = s[3] - s[1], s[4] - s[2]
    if axis == nil or axis == true then
        self.canvas:drawLine({0,sy//2},{sx,sy//2},"#ffffff",1.5)
        self.canvas:drawLine({sx//2,0},{sx//2,sy},"#ffffff",1.5)
    end
    local n=0
    local t= 0
    local prev;
    while t <= twopi*revolutions do
        n=n+1
        local x2,y2 = fr(t)*math.cos(t), fr(t)*math.sin(t)
        local x,y = 
            mapn(x2,zoom[1],zoom[3],r[1],r[3]),
            mapn(y2,zoom[2],zoom[4],r[2],r[4]);
        local p = {x,y}
        self:drawPixel(x,y,c or "#5151ff") 
        if prev then self.canvas:drawLine(prev,p,c or "#5151ff",2) end
        prev = p 
        if n%2000 == 0 then coroutine.yield() end
        t = t+precision
    end
    if axis == nil or axis == true then
        self.canvas:drawText(("%.3f"):format(zoom[1]),{position = {7,(sy//2)+7}},7)
        self.canvas:drawText(("^yellow;x ^reset;%.3f"):format(zoom[3]),{position = {sx,(sy//2)+7}, horizontalAnchor = 'right'},7)
        self.canvas:drawText(("%.3f"):format(zoom[2]),{position = {7 + sx//2,7}},7)
        self.canvas:drawText(("^yellow;y ^reset;%.3f"):format(zoom[4]),{position = {7+ sx//2,sy}, verticalAnchor = 'top'},7)
    end
end