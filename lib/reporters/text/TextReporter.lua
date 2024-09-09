local Context = require("lib.classes.Context")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local Reporter = require("lib.reporters.Reporter")
local Terminal = require("lib.classes.Terminal")
local time = require("lib.util.time")

local ctx = Context.global()

---@class TextReporter: Reporter
local TextReporter = {}

---@param results RunResults
function TextReporter:new(results)
	setmetatable(results, { __index = TextReporter })
	setmetatable(TextReporter, { __index = Reporter })
	return results
end

---Print suite title.
---@param suite Runnable
function TextReporter:printSuiteTitle(suite)
	Terminal.printStyle(
		helpers.tab(suite.level - 1) .. suite.description .. "\n",
		Terminal.style.bold
	)
end

---Print failed test message.
---@param test Runnable
function TextReporter:printFailed(test)
	local timeFmt = time.toString(test.execTime, " (%s)")
	Terminal.printActual(test.description, timeFmt, test.level - 1)
end

---Print passed test message.
---@param test Runnable
function TextReporter:printPassed(test)
	local timeFmt = time.toString(test.execTime, " (%s)")
	Terminal.printExpected(test.description, timeFmt, test.level - 1)
end

---Print skipped test message.
---@param test Runnable
function TextReporter:printSkipped(test)
	local timeFmt = time.toString(test.execTime, " (%s)")
	Terminal.printSkipped(test.description, timeFmt, test.level - 1)
end

---Report the tests
---@param suite? Runnable
function TextReporter:reportTests(suite)
	if self.total == 0 then
		Terminal.printStyle(labels.noTests)
		return
	end
	suite = suite or ctx.root
	if suite == nil then
		error(labels.errorNoRoot)
	end
	for _, test in ipairs(suite.children) do
		local lvl = test.level - 1
		if test:isSuite() then
			Terminal.printStyle(
				helpers.tab(lvl) .. test.description,
				Terminal.style.bold
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
		self:reportTests(test)
	end
end

return TextReporter
