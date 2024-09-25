local Context = require("src.Context")
local errorx = require("src.ext.errorx")
local Runnable = require("src.Runnable")
local Labels = require("src.Labels")

---@type Context
local ctx = Context.global()

---@class Suite : Runnable
local Suite = Runnable:new()

function Suite:prepare()
	Suite.createRootSuiteMaybe()
	if type(self.func) ~= "function" then
		self.error = errorx.new({
			title = string.format(
				"Runnable.Suite: %s",
				Labels.ErrorCallbackNotFunction
			),
			actual = type(self.func),
			expected = "function",
		})
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
		if type(err) == "table" and err.title then
			errMsg = err.title
		end
		self.error = errorx.new({
			title = errMsg,
			actual = type(self.func),
			expected = "function",
		})
		errorx.print(self.error)
		return
	end
	ctx.level = ctx.level - 1
end

return Suite.new(Suite)
