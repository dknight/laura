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
---@return Runnable
function Runnable:new(description, fn)
	local t = {
		skipped = false,
		description = description,
		fn = fn,
	}
	return setmetatable(t, {
		__index = self,
		__call = function(klass, d, f)
			local instance = klass:new(d, f)
			instance:run()
		end,
	})
end

---Running the test.
function Runnable:run()
	local startTime = os.clock()
	ctx.total = ctx.total + 1

	if type(self.fn) ~= "function" and not self.skipped then
		ctx.failed = ctx.failed + 1
		local err = {
			message = "Runnable.it: callback is not a function",
			expected = "function",
			actual = type(self.fn),
			debuginfo = debug.getinfo(1),
			traceback = debug.traceback(),
		}
		table.insert(ctx.errors, err)
		printer.printActual(self.description)
		return
	end

	-- if self.skipped then
	--
	-- end
	-- TODO TEST BETTER	print("OK")

	local itInfo = debug.getinfo(2, "n")
	local describeInfo = debug.getinfo(5, "n")

	if itInfo.name == "skip" or describeInfo.name == "skip" then
		ctx.skipped = ctx.skipped + 1
		printer.printSkipped(self.description)
		return
	end

	local ok, err = pcall(self.fn)
	if not ok then
		ctx.failed = ctx.failed + 1
		err.description = self.description
		err.debuginfo = debug.getinfo(self.fn, "S")
		err.traceback = debug.traceback()
		table.insert(ctx.errors, err)
		printer.printActual(self.description)
	else
		ctx.passed = ctx.passed + 1
		local formatedTime =
			string.format(" (%s)", time.format(os.clock() - startTime))
		printer.printExpected(self.description, formatedTime)
	end
end

---Skipping the task.
---@param description string
---@param fn function
function Runnable:skip(description, fn)
	self.skipped = true
	self.description = description
	self.fn = fn
	self:run()
end

---Running only marked tasks.
---@param description string
---@param fn function
function Runnable:only(description, fn)
	--print("ONLY", description)
	-- IMPLEMENT
end

return Runnable
