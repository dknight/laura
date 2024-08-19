local printer = require("lib.printer")
local context = require("lib.context")
local time = require("lib.util.time")

local ctx = context.global()

---@class Runnable
---@field public skipped boolean
---@field public description string
---@field public fn function
local Runnable = {}

---New runnable instance.
---@param description? string
---@param fn? function
---@param skipped? boolean
---@return Runnable
function Runnable:new(description, fn, skipped)
	local t = {
		skipped = skipped or false,
		description = description,
		fn = fn,
	}
	return setmetatable(t, {
		__index = self,
		__call = function(klass, d, f)
			local r = klass:new(d, f)
			r:run()
		end,
	})
end

---Running the test.
function Runnable:run()
	local startTime = os.clock()
	if type(self.fn) ~= "function" then
		error("callback is not a function") -- FIXME crash???
	end
	if self.skipped then
		ctx.aura.skipped = ctx.aura.skipped + 1
		printer.printSkipped(self.description)
		return
	end

	local ok, err = pcall(self.fn)
	ctx.aura.total = ctx.aura.total + 1
	if not ok then
		for k, v in pairs(debug.getinfo(self.fn)) do
			print(k, v)
		end
		ctx.aura.failed = ctx.aura.failed + 1
		err.description = self.description
		err.debuginfo = debug.getinfo(self.fn)
		table.insert(ctx.aura.errors, err)
		printer.printActual(self.description)
	else
		ctx.aura.passed = ctx.aura.passed + 1
		local formatedTime =
			string.format(" (%s)", time.format(os.clock() - startTime))
		printer.printExpected(self.description, formatedTime)
	end
end

---Skipping the task.
---@param class Runnable
---@param description string
---@param fn function
function Runnable.skip(class, description, fn)
	class:new(description, fn, true):run()
end

return Runnable
