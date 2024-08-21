local Runnable = require("lib.runnable")
local printer = require("lib.printer")
local contex = require("lib.context")
local helpers = require("lib.util.helpers")

---@type Context
local ctx = contex.global()

---@type Runnable
local describe = Runnable.new(Runnable)

---@diagnostic disable-next-line: duplicate-set-field
function describe:run()
	io.write(helpers.tab(ctx.level))
	printer.printStyle(self.description, printer.termStyles.bold)
	if type(self.fn) ~= "function" then
		-- TODO descide what to do here, exit or failed +
		-- local err = {
		-- message = "Runnable.describe: callback is not a function",
		-- expected = "function",
		-- actual = type(self.fn),
		-- debuginfo = debug.getinfo(1),
		-- }
		-- table.insert(ctx.errors, err)
		ctx.failed = ctx.failed + 1
		error("Runnable.describe: callback is not a function", 3)
	end

	ctx.level = ctx.level + 1
	self.fn()
	ctx.level = ctx.level - 1
end

return describe
