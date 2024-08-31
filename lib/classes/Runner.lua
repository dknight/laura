local constants = require("lib.util.constants")
local Context = require("lib.classes.Context")
local errorx = require("lib.ext.errorx")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local Runnable = require("lib.classes.Runnable")
local Status = require("lib.classes.Status")
local Terminal = require("lib.classes.Terminal")
local time = require("lib.util.time")

local ctx = Context.global()

---@class Runner
---@field private totalCount number
---@field private passed Runnable[]
---@field private failed Runnable[]
---@field private skipped Runnable[]
local Runner = {}

---@return Runner
function Runner:new()
	local t = {
		totalCount = 0,
		passed = {},
		failed = {},
		skipped = {},
	}
	return setmetatable(t, {
		__index = self,
	})
end

---Runs all test cases.
function Runner:runTests()
	if ctx.root:hasOnly() then
		Runnable.filterOnly(ctx.root)
	end
	if #ctx.onlyTests > 0 then
		ctx.tests = Runnable.filter(ctx.onlyTests, { isSuite = false })
	end

	Runnable.traverse(ctx.tests, function(test)
		test:run()
	end)

	self.totalCount = #ctx.tests
	self.failed = Runnable.filter(ctx.tests, { status = Status.Failed })
	self.passed = Runnable.filter(ctx.tests, { status = Status.Passed })
	self.skipped = Runnable.filter(ctx.tests, { status = Status.Skipped })
end

---Reports the tests
function Runner:reportTests(suite)
	suite = suite or ctx.root
	for _, test in ipairs(suite.children) do
		local lvl = test.level - 1
		if test.isSuite then
			Terminal.printStyle(helpers.tab(lvl) .. test.description, 1)
		else
			local tmStr = time.toString(test.execTime, " (%s)")
			if test.status == Status.Skipped then
				Terminal.printSkipped(test.description, nil, lvl)
			elseif test.status == Status.Failed then
				Terminal.printActual(test.description, tmStr, lvl)
			elseif test.status == Status.Passed then
				Terminal.printExpected(test.description, tmStr, lvl)
			end
		end
		Runner:reportTests(test)
	end
end

---Prints the errors if exist.
function Runner:reportErrors()
	if #self.failed <= 0 then
		return
	end
	io.write("\n")
	Terminal.printStyle(
		labels.failedTests,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)
	local n = 1
	Runnable.traverse(self.failed, function(test)
		io.write(string.format("%d. ", n))
		errorx.print(test.err)
		n = n + 1
	end)
end

---Reports summary.
function Runner:reportSummary()
	Terminal.printStyle(
		labels.summary,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	local successMsg = string.format(
		"%d of %d passing\n",
		#self.passed,
		self.totalCount - #self.skipped
	)
	io.write(successMsg)

	local failedMessage = string.format(
		"%d failing\n",
		#self.failed,
		self.totalCount - #self.skipped
	)
	io.write(failedMessage)

	local skippedMessage = string.format("%d skipping\n", #self.skipped)
	io.write(skippedMessage)
end

---Prints the approximate execution time of the runner.
---@param startTime number
function Runner:reportTime(startTime)
	local formatedTime = time.format(os.clock() - startTime)
	io.write(string.format(labels.timeSummary, formatedTime, os.date()))
end

---Finishes runner. Should be called last. Exists the program with codes:
--- * constants.exitFailed (1) There are the failures.
--- * constants.exitOk (0) All tests are passed.
function Runner:done()
	if #self.failed > 0 then
		print(labels.failed)
		os.exit(constants.exitFailed)
	else
		print(labels.pass)
		os.exit(constants.exitOk)
	end
end

return Runner
