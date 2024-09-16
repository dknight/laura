local Context = require("lib.Context")
local Runnable = require("lib.Runnable")
local Labels = require("lib.Labels")
local Status = require("lib.Status")

---@type Context
local ctx = Context.global()

---@class Suite : Runnable
local Suite = Runnable:new()

function Suite:prepare()
	Suite.createRootSuiteMaybe()
	if type(self.func) ~= "function" then
		error(
			string.format("Runnable.Suite: %s", Labels.ErrorCallbackNotFunction),
			ctx.config._suiteLevel
		)
	end

	self.level = ctx.level
	self._suite = true

	ctx.suites[ctx.level] = self
	ctx.current = self

	self.parent = ctx.suites[ctx.level - 1]
	table.insert(self.parent.children, self)

	ctx.level = ctx.level + 1
	local ok, err = pcall(self.func)
	if not ok then
		-- TODO better error reporting
		error(err.message, ctx.config._suiteLevel)
		self.err = err
		self.status = Status.failed
	end
	ctx.level = ctx.level - 1
end

return Suite.new(Suite)
