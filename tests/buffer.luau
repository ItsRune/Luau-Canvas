local Canvas = require("../init")
local context = Canvas.new(50, 50)
local fs = require("@lune/fs")

context:fillRect(0, 0, 10, 10)
context:toBuffer()

local fromContext = context:Generate()
print(buffer.tostring(fromContext), fromContext)

fs.writeFile("./tests/buffer_img.png", buffer.tostring(fromContext))
