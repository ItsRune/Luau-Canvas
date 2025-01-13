local clock = require("baseClock")
local Canvas = require("../init")

local context = Canvas.new(320, 320)
clock(context)
