require"/better-widgets/widget.lua"

Progress = Widget:extend()

function Progress:initial ()
  self._progress = 0
end

function Progress:setProgress (v)
  util.clamp(v,0,1)
  self._progress = v
  widget.setProgress(self.name,v)
  return self
end

function Progress:getProgress ()
  return self._progress
end