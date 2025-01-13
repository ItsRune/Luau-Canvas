local Canvas = require("../init")
local context = Canvas.new(200, 200)

context:setFillStyle("red")
context:fillRect(0, 0, context.width, context.height)

context:setOutputLocation("../output")
context:setOutputName("text_output")

context:createImage()
