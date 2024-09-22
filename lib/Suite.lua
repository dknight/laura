local Context = require("lib.Context")
local errorx = require("lib.ext.errorx")
local Runnable = require("lib.Runnable")
local Labels = require("lib.Labels")

---@type Context
local ctx = Context.global()

---@class Suite : Runnable
local Suite = Runnable:new()

function Suite:prepare()
	Suite.createRootSuiteMaybe()
	if type(self.func) ~= "function" then
		self.error = errorx.new(
			string.format("Runnable.Suite: %s", Labels.ErrorCallbackNotFunction),
			self.func,
			"function"
		)
		errorx.print(self.error)
		return
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
		local errMsg = err
		if type(err) == "table" and err.message then
			errMsg = err.message
		end
		self.error = errorx.new(errMsg, self.func, "function")
		errorx.print(self.error)
		return
	end
	ctx.level = ctx.level - 1
end

return Suite.new(Suite)
