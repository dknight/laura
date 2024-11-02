local helpers = require("laura.util.helpers")
local Reporter = require("laura.Reporter")
local Terminal = require("laura.Terminal")
local time = require("laura.util.time")

---@class TextReporter : Reporter
---@field printSuiteTitle fun(reporter: Reporter, suite: Runnable)
local TextReporter = {}

---@param results RunResults
---@return RunResults
function TextReporter:new(results)
	setmetatable(results, { __index = TextReporter })
	setmetatable(TextReporter, { __index = Reporter })
	return results
end

---@param suite Runnable
function TextReporter:printSuiteTitle(suite)
	Terminal.printStyle(
		helpers.tab(suite.level - 1) .. suite.description,
		Terminal.Style.Bold
	)
end

---@param test Runnable
function TextReporter:printFailed(test)
	local timeFmt = time.toString(test.execTime, " (%s)")
	Terminal.printActual(test.description, timeFmt, test.level - 1)
end

---@param test Runnable
function TextReporter:printPassed(test)
	local timeFmt = time.toString(test.execTime, " (%s)")
	Terminal.printExpected(test.description, timeFmt, test.level - 1)
end

---@param test Runnable
function TextReporter:printSkipped(test)
	local timeFmt = time.toString(test.execTime, " (%s)")
	Terminal.printSkipped(test.description, timeFmt, test.level - 1)
end

---@param test Runnable
function TextReporter:reportTest(test)
	local lvl = test.level - 1
	if test:isSuite() then
		Terminal.printStyle(
			helpers.tab(lvl) .. test.description,
			Terminal.Style.Bold
		)
	else
		local tmStr = time.toString(test.execTime, " (%s)")
		if test:isSkipped() then
			Terminal.printSkipped(test.description, nil, lvl)
		elseif test:isFailed() then
			Terminal.printActual(test.description, tmStr, lvl)
		elseif test:isPassed() then
			Terminal.printExpected(test.description, tmStr, lvl)
		end
	end
end

return TextReporter
