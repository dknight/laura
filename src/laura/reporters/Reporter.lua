---@alias ReporterType
---| '"text"'  # Reports as text in the terminal (default).
---| '"dots"'  # Prints a dot for every test (very compact).
---| '"blank"' # Do not report any test information, doesnt affect on summary.
---| '"count"' # Prints tests counters.

local Context = require("laura.Context")
local errorx = require("laura.ext.errorx")
local Labels = require("laura.Labels")
local memory = require("laura.util.memory")
local Terminal = require("laura.Terminal")
local time = require("laura.util.time")
local fs = require("laura.util.fs")

local ctx = Context.global()
local EOL = fs.EOL

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
---@return Reporter|RunResults
function Reporter:new(results)
	return setmetatable(results, self)
end

function Reporter:reportSummary()
	Terminal.printStyle(
		EOL .. Labels.Summary.Title,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	local successMsg = string.format(
		Labels.Summary.Passing .. EOL,
		#self.passing,
		self.total - #self.skipping
	)
	io.write(successMsg)

	local failedMessage =
		string.format(Labels.Summary.Failing .. EOL, #self.failing)
	io.write(failedMessage)

	local skippedMessage =
		string.format(Labels.Summary.Skipping .. EOL, #self.skipping)
	io.write(skippedMessage)
end

---Print the approximate execution time of the runner.
---@param dt? number
function Reporter:reportPerformance(dt)
	local duration = self.duration + (dt or 0)
	local formatedTime = time.format(duration)
	local formattedMemory = memory.format(collectgarbage("count"))
	io.write(
		string.format(
			EOL .. Labels.Performance .. EOL,
			formatedTime,
			formattedMemory,
			os.date(ctx.config.DateFormat)
		)
	)
end

function Reporter:reportErrors()
	if #self.failing <= 0 then
		return
	end
	io.write(EOL)
	Terminal.printStyle(
		Labels.FailedTests,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	for i in ipairs(self.failing) do
		io.write(string.format("%d. ", i))
		errorx.printError(self.failing[i].error, ctx.config.Color)
	end
end

---@param _? Runnable
function Reporter:reportTest(_) end

---@param _? Runnable
function Reporter:printSuiteTitle(_)
	-- to implement
end

---@param _? Runnable
function Reporter:printFailed(_)
	-- to implement
end

---@param _? Runnable
function Reporter:printPassed(_)
	-- to implement
end

---@param _? Runnable
function Reporter:printSkipped(_) end

---Reports all summary of the tests
---@param duration? number
function Reporter:finalSummary(duration)
	if ctx.config.ReportSummary then
		self:reportSummary()
		self:reportPerformance(duration)
	end
end

return Reporter
