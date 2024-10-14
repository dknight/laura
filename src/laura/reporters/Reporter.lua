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

local ctx = Context.global()

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
		"\n" .. Labels.Summary.Title,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	local successMsg = string.format(
		Labels.Summary.Passing .. "\n",
		#self.passing,
		self.total - #self.skipping
	)
	io.write(successMsg)

	local failedMessage =
		string.format(Labels.Summary.Failing .. "\n", #self.failing)
	io.write(failedMessage)

	local skippedMessage =
		string.format(Labels.Summary.Skipping .. "\n", #self.skipping)
	io.write(skippedMessage)
end

---Print the approximate execution time of the runner.
function Reporter:reportPerformance()
	local formatedTime = time.format(self.duration)
	local formattedMemory = memory.format(collectgarbage("count"))
	io.write(
		string.format(
			"\n" .. Labels.Performance .. "\n",
			formatedTime,
			formattedMemory,
			os.date()
		)
	)
end

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

---Reports all summary information.
function Reporter:report()
	self:reportErrors()
	if ctx.config.ReportSummary then
		self:reportSummary()
		self:reportPerformance()
	end
end

function Reporter:reportCoverage()
	print(
		Terminal.setStyle(
			"\n" .. Labels.Summary.Coverage,
			Terminal.Style.Bold,
			Terminal.Style.Underlined
		)
	)
	ctx.coverage:printReport()
	local threshold = ctx.config.Coverage.Threshold
	local pct = ctx.coverage:calculateTotalAveragePercent()
	if threshold > 0 and pct < threshold then
		print(
			string.format(
				Labels.ErrorCoverageNotMet,
				pct,
				ctx.config.Coverage.Threshold
			)
		)
		print(Labels.ResultFailed)
		os.exit(ctx.config._exitCoverageFailed)
	end
end

return Reporter
