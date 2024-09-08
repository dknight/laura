local Reporter = require("lib.reporters.Reporter")

---@class TextReporter : Reporter
local TextReporter = {}

---@param execDuration number
---@param execTime string | number
---@param failing number
---@param passing number
---@param skipping number
---@param totalCount number
function TextReporter:new(
	execDuration,
	execTime,
	failing,
	passing,
	skipping,
	totalCount
)
	local t = {
		execDuration = execDuration or 0,
		execTime = execTime or 0,
		failing = failing or {},
		passing = passing or {},
		skipping = skipping or {},
		totalCount = totalCount or 0,
	}
	setmetatable(t, { __index = TextReporter })
	setmetatable(TextReporter, { __index = Reporter })
	return t
end

---Print suite title.
---@param suite Runnable
function TextReporter:printSuiteTitle(suite) end

---Print failed test message.
---@param test Runnable
function TextReporter:printFailed(test) end

---Print passed test message.
---@param test Runnable
function TextReporter:printPassed(test) end

---Print skipped test message.
---@param test Runnable
function TextReporter:printSkipped(test) end

---Print report summary.
function TextReporter:reportSummary() end

---Print the approximate execution time of the runner.
function TextReporter:reportPerformance() end

---Report the tests
---@param suite? Runnable
function TextReporter:reportTests(suite) end

---Prints the errors if exist.
function TextReporter:reportErrors() end

return TextReporter
