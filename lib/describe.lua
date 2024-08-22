local Runnable = require("lib.runnable")
local context = require("lib.context")

---@type Context
local ctx = context.global()

---@class Describe : Runnable
local Describe = Runnable.new(Runnable)

---@diagnostic disable-next-line: duplicate-set-field
function Describe:run()
	if type(self.fn) ~= "function" then
		error("Runnable.describe: callback is not a function", 3)
		return
	end
	self.isSuite = true

	ctx.level = ctx.level + 1
	self:appendToContext()

	self.fn()
	ctx.level = ctx.level - 1
end

return Describe.new(Describe)
