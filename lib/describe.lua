local Runnable = require("lib.runnable")
local printer = require("lib.printer")
local contex = require("lib.context")
local helpers = require("lib.util.helpers")

---@type Context
local ctx = contex.global()

---@type Runnable
local describe = Runnable.new(Runnable)

---@diagnostic disable-next-line: duplicate-set-field
describe.run = function(self)
	io.write(helpers.tab(ctx.aura.level))
	printer.printCustom(self.description, 1)
	if type(self.fn) ~= "function" then
		error("callback is not a function")
	end
	ctx.aura.level = ctx.aura.level + 1
	self.fn()
	ctx.aura.level = ctx.aura.level - 1
end

return describe
