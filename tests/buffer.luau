local Canvas = require("../init")
local context = Canvas.new(50, 50)
local fs = require("@lune/fs")

context:fillStyle("pink")
context:fillRect(0, 0, 10, 10)
local contextBuffer = context:toBuffer()

print(contextBuffer)
fs.writeFile("./tests/buffer_img.png", contextBuffer)
