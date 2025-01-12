local clock = require("clock")
local task = require("@lune/task")
local Canvas = require("../init")

while task.wait(1) do
	local context = Canvas.new(320, 320)
	clock(context)
end
