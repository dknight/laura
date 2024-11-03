local errorx = require("laura.ext.errorx")
local Runnable = require("laura.Runnable")
local Labels = require("laura.Labels")

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
		errorx.print(self.error, self.ctx.config.Color)
		return
	end

	self.level = self.ctx.level
	self._suite = true

	self.ctx.suites[self.ctx.level] = self
	self.ctx.current = self

	self.parent = self.ctx.suites[self.ctx.level - 1]
	table.insert(self.parent.children, self)

	self.ctx.level = self.ctx.level + 1
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
		errorx.print(self.error, self.ctx.config.Color)
		return
	end
	self.ctx.level = self.ctx.level - 1
end

return Suite.new(Suite)
