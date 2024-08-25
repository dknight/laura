local Context = require("lib.classes.Context")
local Runnable = require("lib.classes.Runnable")

---@type Context
local ctx = Context.global()

---@class Describe : Runnable
local Describe = Runnable.new(Runnable)

---@diagnostic disable-next-line: duplicate-set-field
function Describe:prepare()
	if type(self.fn) ~= "function" then
		local err = {
			message = "Runnable.describe: callback is not a function",
			actual = type(self.fn),
			expected = "function",
		}
		error(err, 3)
		return
	end
	self.isSuite = true

	ctx.level = ctx.level + 1
	self.level = ctx.level
	self:appendToContext()
	self.fn()
	ctx.level = ctx.level - 1
end

return Describe.new(Describe)
