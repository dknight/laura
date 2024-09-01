local constants = require("lib.util.constants")
local Context = require("lib.classes.Context")
local Runnable = require("lib.classes.Runnable")

---@type Context
local ctx = Context.global()

---@class Describe : Runnable
local Describe = Runnable.new(Runnable)

function Describe:prepare()
	Describe.createRootSuite()
	if type(self.fn) ~= "function" then
		error(
			"Runnable.describe: callback is not a function",
			constants.SuiteLevel
		)
	end

	self.level = ctx.level
	self.isSuite = true

	ctx.suites[#ctx.suites + 1] = self
	ctx.suitesLevels[ctx.level] = self

	self.parent = ctx.suitesLevels[ctx.level - 1]
	table.insert(self.parent.children, self)
	ctx.level = ctx.level + 1
	local ok, err = pcall(self.fn)
	if not ok then
		error(err, constants.SuiteLevel)
	end

	ctx.level = ctx.level - 1
end

return Describe.new(Describe)
