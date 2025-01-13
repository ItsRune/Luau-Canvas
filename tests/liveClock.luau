local clock = require("baseClock")
local task = require("@lune/task")
local Canvas = require("../init")

-- Horrible way of doing this, I'm aware.
while task.wait(1) do
	local context = Canvas.new(320, 320)
	clock(context)
end
