---@class Reporter
---@field protected execDuration number
---@field protected execTime string | number
---@field protected failing number
---@field protected passing number
---@field protected skipping number
---@field protected totalCount number
local Reporter = {}
Reporter.__index = Reporter

---@param execDuration number
---@param execTime string | number
---@param failing number
---@param passing number
---@param skipping number
---@param totalCount number
---@return Reporter
function Reporter:new(
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
	return setmetatable(t, self)
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
function Reporter:reportSummary() end

---Print the approximate execution time of the runner.
function Reporter:reportPerformance() end

---Report the tests
---@param suite? Runnable
function Reporter:reportTests(suite) end

---Prints the errors if exist.
function Reporter:reportErrors() end

---Reports everything
function Reporter:report()
	self:reportTests()
	self:reportErrors()
	self:reportSummary()
	self:reportPerformance()
end

return Reporter
