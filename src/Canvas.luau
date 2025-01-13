--!strict
local process = require("@lune/process")
local serde = require("@lune/serde")

local Canvas = {}
local Class = {}

Class.__index = Class

type CanvasResultType = "svg" | "pdf" | "image" | string
type CanvasTextMeasurement = {
	actualBoundingBoxAscent: number,
	actualBoundingBoxDescent: number,
	actualBoundingBoxLeft: number,
	actualBoundingBoxRight: number,
	alphabeticBaseline: number,
	emHeightAscent: number,
	emHeightDescent: number,
	width: number,
}

export type CanvasPublic = {
	__destroyed: boolean?,
	_dontCreateImage: boolean?,
	type: CanvasResultType,
	width: number,
	height: number,
	javascriptCommands: { { any }? },
}
export type CanvasPrivate = typeof(Class)
export type CanvasImpl = typeof(setmetatable({} :: CanvasPublic, {} :: CanvasPrivate))

local function cleanOutput(output: string): any
	-- local split = string.split(output, "")
	if string.sub(output, 1, 7) == "<Buffer" then
		output = output:gsub("<Buffer ", ""):gsub(">", "")
		local split = string.split(output, " ")
		local res = buffer.create(#split * 2)

		-- This is not in a PNG format, first time using buffers and I already hate them.
		for i in split do
			local byte = tonumber(`0x{tostring(split[i])}`) :: number
			buffer.writeu16(res, (i - 1), byte)
		end

		return res
	elseif string.sub(output, 1, 6) == "<Path " then
		output = output:gsub("<Path ", ""):gsub(">", "")
		return output
	elseif string.sub(output, 1, 7) == "<Debug " then
		output = output:gsub("<Debug ", ""):gsub(">", "")
		print(`Debug: {output}`)
		return ""
	elseif tonumber(output) ~= nil then
		return tonumber(output)
	end

	-- When all else fails, try json conversion... (This is stupid)
	return serde.decode("json", output)
end

local function forceProcess(commands: { commands: { { any }? }, height: number, width: number })
	local result = process.spawn("node", { "./lib/transfer.js", serde.encode("json", commands) })

	if not result.ok then
		error(result.stderr)
	elseif result.stdout ~= "" then
		return cleanOutput(result.stdout)
	end

	return result
end

function Canvas.new(w: number?, h: number?, t: CanvasResultType?): CanvasImpl
	local self = setmetatable({}, Class)
	local width, height, type = w or 100, h or 100, t or "svg"

	self.width = width
	self.height = height
	self.type = type
	self.javascriptCommands = {}

	return self
end

function Class._addCommand(self: CanvasImpl, command: string, scope: "Canvas" | "Context" | "Env", ...: any)
	table.insert(self.javascriptCommands, { command, scope, ... })
end

-- Context implementations
function Class.rotate(self: CanvasImpl, angle: number, usesDegrees: boolean?)
	self:_addCommand("rotate", "Context", math.clamp(usesDegrees and angle / 360 or angle, 0, 1))
end

function Class.lineTo(self: CanvasImpl, x: number, y: number)
	self:_addCommand("lineTo", "Context", x, y)
end

function Class.arc(
	self: CanvasImpl,
	x: number,
	y: number,
	startAngle: number,
	endAngle: number,
	counterClockwise: boolean?
)
	self:_addCommand("arc", "Context", x, y, startAngle, endAngle, counterClockwise)
end

function Class.measureText(self: CanvasImpl, str: string): CanvasTextMeasurement?
	local customInstr = {
		width = 0,
		height = 0,
		_dontCreateImage = true,
		commands = {
			{ "measureText", "Context", str },
		},
	}

	return forceProcess(customInstr)
end

function Class.translate(self: CanvasImpl, x: number, y: number)
	self:_addCommand("translate", "Context", x, y)
end

function Class.fill(self: CanvasImpl)
	self:_addCommand("fill", "Context")
end

function Class.restore(self: CanvasImpl)
	self:_addCommand("restore", "Context")
end

function Class.fillStyle(self: CanvasImpl, style: string)
	self:_addCommand("fillStyle", "Context", style)
end

function Class.arcTo(self: CanvasImpl, x1: number, y1: number, x2: number, y2: number, radius: number)
	self:_addCommand("arcTo", "Context", x1, y1, x2, y2, radius)
end

function Class.moveTo(self: CanvasImpl, x: number, y: number)
	self:_addCommand("moveTo", "Context", x, y)
end

function Class.clearRect(self: CanvasImpl, x: number, y: number, w: number, h: number)
	self:_addCommand("clearRect", "Context", x, y, w, h)
end

function Class.setLineWidth(self: CanvasImpl, width: number)
	self:_addCommand("lineWidth", "Context")
end

function Class.setFillStyle(self: CanvasImpl, style: string)
	self:_addCommand("fillStyle", "Context", style)
end

function Class.fillRect(self: CanvasImpl, x: number, y: number, w: number, h: number)
	self:_addCommand("fillRect", "Context", x, y, w, h)
end

function Class.fillText(self: CanvasImpl, str: string, x: number, y: number)
	self:_addCommand("fillText", "Context", str, x, y)
end

function Class.setFont(self: CanvasImpl, hex: string)
	self:_addCommand("font", "Context", hex)
end

function Class.beginPath(self: CanvasImpl)
	self:_addCommand("beginPath", "Context")
end

function Class.stroke(self: CanvasImpl)
	self:_addCommand("stroke", "Context")
end

function Class.addPage(self: CanvasImpl, w: number?, h: number?)
	self:_addCommand("addPage", "Context", w, h)
end

function Class.save(self: CanvasImpl)
	self:_addCommand("save", "Context")
end

function Class.setStrokeStyle(self: CanvasImpl, style: string)
	self:_addCommand("strokeStyle", "Context", style)
end

-- Canvas implementations
function Class.toBuffer(self: CanvasImpl)
	self:_addCommand("toBuffer", "Canvas")
	return self:Generate()
end

function Class.createImage(self: CanvasImpl)
	self:_addCommand("createImage", "Canvas")
	return self:Generate()
end

-- Env implementations
function Class.setOutputName(self: CanvasImpl, newName: string)
	self:_addCommand("fileName", "Env", newName)
end

function Class.setOutputLocation(self: CanvasImpl, newLocation: string)
	self:_addCommand("fileLocation", "Env", newLocation)
end

function Class.Generate(self: CanvasImpl): any
	local commands = {
		width = self.width,
		height = self.height,
		commands = self.javascriptCommands,
	}

	local result = forceProcess(commands)
	table.clear(self.javascriptCommands)

	return result
end

function Class.Destroy(self: CanvasImpl)
	table.clear(self :: any)
	setmetatable(self :: any, nil)
end

return Canvas :: typeof(Canvas)
