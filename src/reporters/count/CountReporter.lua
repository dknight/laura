local Labels = require("src.Labels")
local Reporter = require("src.reporters.Reporter")
local Status = require("src.Status")
local Terminal = require("src.Terminal")

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
	if not test:isSkipped() then
		total = total + 1
	end
	if test:isSkipped() then
		skipped = skipped + 1
	elseif test:isFailed() then
		failed = failed + 1
	elseif test:isPassed() then
		passed = passed + 1
	end

	local out = {}
	out[#out + 1] = Terminal.toggleCursor(true)
	out[#out + 1] = Labels.total
	out[#out + 1] = total
	out[#out + 1] = Terminal.setColor(Status.Passed)
	out[#out + 1] = Labels.Statuses[Status.Passed]
	out[#out + 1] = passed
	out[#out + 1] = Terminal.reset()
	out[#out + 1] = Terminal.setColor(Status.Failed)
	out[#out + 1] = Labels.Statuses[Status.Failed]
	out[#out + 1] = failed
	out[#out + 1] = Terminal.setColor(Status.Skipped)
	out[#out + 1] = Labels.Statuses[Status.Skipped]
	out[#out + 1] = skipped
	out[#out + 1] = Terminal.reset()
	io.write(table.concat(out, " ") .. "\r")
end

return CountReporter
