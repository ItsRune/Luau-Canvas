local Canvas = require("../init")
local context = Canvas.new(200, 200)

context:setFillStyle("white")
context:fillRect(0, 0, 200, 200)

context:setFont("20px Impact")
context:setFillStyle("red")
context:fillText("Hello World!", 50, 50)

local textSize = context:measureText("Hello World!")
print(textSize)

context:Generate()
