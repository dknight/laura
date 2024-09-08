local errorx = require("lib.ext.errorx")
local labels = require("lib.labels")
local memory = require("lib.util.memory")
local Terminal = require("lib.classes.Terminal")
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

---Print suite title.
---@param suite Runnable
function Reporter:printSuiteTitle(suite) end

---Print failed test message.
---@param test Runnable
function Reporter:printFailed(test) end

---Print passed test message.
---@param test Runnable
function Reporter:printPassed(test) end

---Print skipped test message.
---@param test Runnable
function Reporter:printSkipped(test) end

---Print report summary.
function Reporter:reportSummary()
	Terminal.printStyle(
		labels.Summary.Title,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	local successMsg = string.format(
		labels.Summary.Passing,
		#self.passing,
		self.total - #self.skipping
	)
	io.write(successMsg)

	local failedMessage = string.format(labels.Summary.Failing, #self.failing)
	io.write(failedMessage)

	local skippedMessage =
		string.format(labels.Summary.Skipping, #self.skipping)
	io.write(skippedMessage)
end

---Print the approximate execution time of the runner.
function Reporter:reportPerformance()
	local formatedTime = time.format(self.duration)
	local formattedMemory = memory.format(collectgarbage("count"))
	io.write(
		string.format(
			labels.Performance,
			formatedTime,
			formattedMemory,
			os.date()
		)
	)
end

---Report the tests
---@param suite? Runnable
function Reporter:reportTests(suite) end

---Prints the errors if exist.
function Reporter:reportErrors()
	if #self.failing <= 0 then
		return
	end
	io.write("\n")
	Terminal.printStyle(
		labels.FailedTests,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	for i, test in ipairs(self.failing) do
		io.write(string.format("%d. ", i))
		errorx.print(test.err)
	end
end

---Reports everything
function Reporter:report()
	self:reportTests()
	self:reportErrors()
	self:reportSummary()
	self:reportPerformance()
end

return Reporter
