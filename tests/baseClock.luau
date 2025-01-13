-- Original: https://github.com/Automattic/node-canvas/blob/master/examples/clock.js
local DateTime = require("@lune/datetime")

local function clock(context)
	context:setFillStyle("red")
	context:setStrokeStyle("blue")

	local function getX(angle)
		return -math.sin(angle + math.pi)
	end

	local function getY(angle)
		return math.cos(angle + math.pi)
	end

	local x, y
	local now = DateTime.now():toLocalTime()

	context:clearRect(0, 0, 320, 320)

	context:save()

	context:translate(160, 160)
	context:beginPath()
	context:setLineWidth(14)
	context:setStrokeStyle("#325FA2")
	context:setFillStyle("#eeeeee")
	context:arc(0, 0, 142, 0, math.pi * 2, true)
	context:stroke()
	context:fill()

	context:setLineWidth(8)
	context:setStrokeStyle("#000000")
	for i = 0, 12 do
		x = getX(math.pi / 6 * i)
		y = getY(math.pi / 6 * i)
		context:beginPath()
		context:moveTo(x * 100, y * 100)
		context:lineTo(x * 125, y * 125)
		context:stroke()
	end

	context:setLineWidth(5)
	context:setStrokeStyle("#000000")

	for i = 0, 60 do
		if i % 5 ~= 0 then
			x = getX(math.pi / 30 * i)
			y = getY(math.pi / 30 * i)
			context:beginPath()
			context:moveTo(x * 117, y * 117)
			context:lineTo(x * 125, y * 125)
			context:stroke()
		end
	end

	local sec = now.second
	local min = now.minute
	local hr = now.hour % 12

	context:fillStyle("black")

	x = getX(hr * (math.pi / 6) + (math.pi / 360) * min + (math.pi / 21600) * sec)
	y = getY(hr * (math.pi / 6) + (math.pi / 360) * min + (math.pi / 21600) * sec)
	context:setLineWidth(14)
	context:beginPath()
	context:moveTo(x * -20, y * -20)
	context:lineTo(x * 80, y * 80)
	context:stroke()

	x = getX((math.pi / 30) * min + (math.pi / 1800) * sec)
	y = getY((math.pi / 30) * min + (math.pi / 1800) * sec)

	context:setLineWidth(10)
	context:beginPath()
	context:moveTo(x * -28, y * -28)
	context:lineTo(x * 112, y * 112)
	context:stroke()

	x = getX(sec * math.pi / 30)
	y = getY(sec * math.pi / 30)
	context:setStrokeStyle("#D40000")
	context:setFillStyle("#D40000")
	context:setLineWidth(6)
	context:beginPath()
	context:moveTo(x * -30, y * -30)
	context:lineTo(x * 83, y * 83)
	context:stroke()
	context:beginPath()
	context:arc(0, 0, 10, 0, math.pi * 2, true)
	context:fill()
	context:beginPath()
	context:arc(x * 95, y * 95, 10, 0, math.pi * 2, true)
	context:stroke()
	context:setFillStyle("#555")
	context:arc(0, 0, 3, 0, math.pi * 2, true)
	context:fill()

	context:restore()

	context:createImage()
end

return clock
