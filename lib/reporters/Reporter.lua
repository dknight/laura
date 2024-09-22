---@alias ReporterType
---| '"text"'  # Reports as text in the terminal (default).
---| '"dots"'  # Prints a dot for every test (very compact).
---| '"blank"' # Do not report any test information, doesnt affect on summary.
---| '"count"' # Prints tests counters.

local errorx = require("lib.ext.errorx")
local Labels = require("lib.Labels")
local memory = require("lib.util.memory")
local Terminal = require("lib.Terminal")
local time = require("lib.util.time")

---@class Reporter
---@field protected duration number
---@field protected datetime string|osdate
---@field protected memory any
---@field protected failing Runnable
---@field protected passing Runnable
---@field protected skipping Runnable
---@field protected total number
---@field public report function
local Reporter = {}
Reporter.__index = Reporter

---@param results RunResults
---@return Reporter
function Reporter:new(results)
	return setmetatable(results, self)
end

---Print report summary.
function Reporter:reportSummary()
	Terminal.printStyle(
		Labels.Summary.Title,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	local successMsg = string.format(
		Labels.Summary.Passing,
		#self.passing,
		self.total - #self.skipping
	)
	io.write(successMsg)

	local failedMessage = string.format(Labels.Summary.Failing, #self.failing)
	io.write(failedMessage)

	local skippedMessage =
		string.format(Labels.Summary.Skipping, #self.skipping)
	io.write(skippedMessage)
end

---Print the approximate execution time of the runner.
function Reporter:reportPerformance()
	local formatedTime = time.format(self.duration)
	local formattedMemory = memory.format(collectgarbage("count"))
	io.write(
		string.format(
			Labels.Performance,
			formatedTime,
			formattedMemory,
			os.date()
		)
	)
end

---Prints the errors if exist.
function Reporter:reportErrors()
	if #self.failing <= 0 then
		return
	end
	io.write("\n")
	Terminal.printStyle(
		Labels.FailedTests,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	for i in ipairs(self.failing) do
		io.write(string.format("%d. ", i))
		errorx.print(self.failing[i].error)
	end
end

---Report the single test
---@param test Runnable
function Reporter:reportTest(test) end

---Print suite title.
---@param suite Runnable
function Reporter:printSuiteTitle(suite)
	-- to implement
end

---Print failed test message.
---@param test Runnable
function Reporter:printFailed(test)
	-- to implement
end

---Print passed test message.
---@param test Runnable
function Reporter:printPassed(test)
	-- to implement
end

---Print skipped test message.
---@param test Runnable
function Reporter:printSkipped(test)
	-- to implement
end

---Reports all summary information.
function Reporter:report()
	self:reportErrors()
	self:reportSummary()
	self:reportPerformance()
end

return Reporter
