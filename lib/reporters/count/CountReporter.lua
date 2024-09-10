local Reporter = require("lib.reporters.Reporter")
local Terminal = require("lib.classes.Terminal")
local Status = require("lib.classes.Status")

---@class CountReporter : Reporter
local CountReporter = {}

local passed = 0
local failed = 0
local skipped = 0
local total = 0

---@param results RunResults
---@return CountReporter
function CountReporter:new(results)
	setmetatable(results, { __index = CountReporter })
	setmetatable(CountReporter, { __index = Reporter })
	return results
end

---Prints a single test report.
---@param test Runnable
function CountReporter:reportTest(test)
	local out = {}
	out[#out + 1] = Terminal.toggleCursor(true)
	out[#out + 1] = total
	out[#out + 1] = "\t"
	out[#out + 1] = Terminal.setColor(Status.passed)
	out[#out + 1] = passed
	out[#out + 1] = "\t"
	out[#out + 1] = Terminal.setColor(Status.failed)
	out[#out + 1] = failed
	out[#out + 1] = "\t"
	out[#out + 1] = Terminal.setColor(Status.skipped)
	out[#out + 1] = skipped
	out[#out + 1] = Terminal.resetColor()

	io.write(table.concat(out, "") .. "\r")
	total = total + 1
	if test:isSkipped() then
		skipped = skipped + 1
	elseif test:isFailed() then
		failed = failed + 1
	elseif test:isPassed() then
		passed = passed + 1
	end
end

return CountReporter
