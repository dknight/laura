local Runnable = require("lib.classes.Runnable")
local printer = require("lib.printer")
local Status = require("lib.classes.Status")
local labels = require("lib.labels")
local errorx = require("lib.ext.errorx")
local helpers = require("lib.util.helpers")
local time = require("lib.util.time")
local config = require("config")

---@class Runner
---@field private tests Runnable[]
---@field private all Runnable[]
---@field private onlyTests Runnable[]
---@field private totalCount number
---@field private passed Runnable[]
---@field private failed Runnable[]
---@field private skipped Runnable[]
local Runner = {}

---@param ctx Context
---@return Runner
function Runner:new(ctx)
	local t = {
		tests = ctx.tests,
		all = {},
		onlyTests = {},
		totalCount = 0,
		passed = {},
		failed = {},
		skipped = {},
	}
	return setmetatable(t, {
		__index = self,
	})
end

---Prepare and return prepared test caees.
---@private
---@return Runnable[]
function Runner:prepare()
	return Runnable.filter(self.tests, {})
end

---Runs all test caees.
function Runner:runTests()
	self.all = self:prepare()
	self.onlyTests = Runnable.getOnly(self.all)
	if #self.onlyTests > 0 then
		self.all = self.onlyTests
	end

	local parent = nil
	Runnable.traverse(self.tests, function(test)
		if test.isSuite then
			parent = test
		end
		test.parent = parent
		test:run()

		self.totalCount = #Runnable.filter(self.all, { isSuite = false })
		self.failed = Runnable.filter(
			self.all,
			{ status = Status.failed, isSuite = false }
		)
		self.passed = Runnable.filter(
			self.all,
			{ status = Status.passed, isSuite = false }
		)
		self.skipped = Runnable.filter(
			self.all,
			{ status = Status.skipped, isSuite = false }
		)
	end)
end

---Reports the tests
function Runner:reportTests()
	Runnable.traverse(self.all, function(test)
		if test.isSuite then
			printer.printStyle(
				helpers.tab(test.level - 1) .. test.description,
				1
			)
		else
			local tdiffstr = string.format(" (%s)", time.format(test.execTime))
			if test.status == Status.skipped then
				printer.printSkipped(test.description, nil, test.level)
			elseif test.status == Status.failed then
				printer.printActual(test.description, tdiffstr, test.level)
			elseif test.status == Status.passed then
				printer.printExpected(test.description, tdiffstr, test.level)
			end
		end
	end)
end

---Prints the errors if exist.
function Runner:reportErrors()
	if #self.failed <= 0 then
		return
	end
	io.write("\n")
	printer.printStyle(
		labels.failedTests,
		printer.termStyles.bold,
		printer.termStyles.underlined
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
	printer.printStyle(
		labels.summary,
		printer.termStyles.bold,
		printer.termStyles.underlined
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
--- config.exitFailed (1) There are the failures.
--- config.exitOk (0) All tests are passed.
function Runner:done()
	if #self.failed > 0 then
		print(labels.failed)
		os.exit(config.exitFailed)
	else
		print(labels.pass)
		os.exit(config.exitOk)
	end
end

return Runner
