local constants = require("lib.util.constants")
local Context = require("lib.classes.Context")
local Runnable = require("lib.classes.Runnable")

---@type Context
local ctx = Context.global()

---@class Suite : Runnable
local Suite = Runnable.new(Runnable)

function Suite:prepare()
	Suite.createRootSuiteMaybe()
	if type(self.func) ~= "function" then
		error(
			"Runnable : Suite: callback is not a function",
			constants.SuiteLevel
		)
	end

	self.level = ctx.level
	self._suite = true

	ctx.suites[#ctx.suites + 1] = self
	ctx.suitesLevels[ctx.level] = self
	ctx.current = self

	self.parent = ctx.suitesLevels[ctx.level - 1]
	table.insert(self.parent.children, self)

	ctx.level = ctx.level + 1
	local ok, err = pcall(self.func)
	if not ok then
		error(err, constants.SuiteLevel)
	end
	ctx.level = ctx.level - 1
end

return Suite.new(Suite)