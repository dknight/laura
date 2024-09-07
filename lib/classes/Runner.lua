local constants = require("lib.util.constants")
local Context = require("lib.classes.Context")
local errorx = require("lib.ext.errorx")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local memory = require("lib.util.memory")
local Runnable = require("lib.classes.Runnable")
local Terminal = require("lib.classes.Terminal")
local time = require("lib.util.time")
local tablex = require("lib.ext.tablex")

local ctx = Context.global()

---@class Runner
---@field private totalCount number
---@field private passing Runnable[]
---@field private failing Runnable[]
---@field private skipping Runnable[]
local Runner = {}

---@return Runner
function Runner:new()
	local t = {
		totalCount = 0,
		passing = {},
		failing = {},
		skipping = {},
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

	self.totalCount = 0
	Runnable.traverse(ctx.root, function(test)
		test:run()

		if test:isFailed() then
			self.failing[#self.failing + 1] = test
		end

		if test:isPassed() then
			self.passing[#self.passing + 1] = test
		end

		if test:isSkipped() then
			self.skipping[#self.skipping + 1] = test
		end
		self.totalCount = self.totalCount + 1
	end)
end

---Reports the tests
function Runner:reportTests(suite)
	if self.totalCount == 0 then
		Terminal.printStyle(labels.noTests)
		return
	end
	suite = suite or ctx.root
	for _, test in ipairs(suite.children) do
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
		Runner:reportTests(test)
	end
end

---Prints the errors if exist.
function Runner:reportErrors()
	if #self.failing <= 0 then
		return
	end
	io.write("\n")
	Terminal.printStyle(
		labels.failedTests,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	for i, test in ipairs(self.failing) do
		io.write(string.format("%d. ", i))
		errorx.print(test.err)
	end
end

---Reports summary.
function Runner:reportSummary()
	Terminal.printStyle(
		labels.summary.title,
		Terminal.Style.Bold,
		Terminal.Style.Underlined
	)

	local successMsg = string.format(
		labels.summary.passing,
		#self.passing,
		self.totalCount - #self.skipping
	)
	io.write(successMsg)

	local failedMessage = string.format(labels.summary.failing, #self.failing)
	io.write(failedMessage)

	local skippedMessage =
		string.format(labels.summary.skipping, #self.skipping)
	io.write(skippedMessage)
end

---Prints the approximate execution time of the runner.
---@param startTime number
function Runner:reportPerformance(startTime)
	local formatedTime = time.format(os.clock() - startTime)
	local formattedMemory = memory.format(collectgarbage("count"))
	io.write(
		string.format(
			labels.performance,
			formatedTime,
			formattedMemory,
			os.date()
		)
	)
end

---Finishes runner. Should be called last. Exists the program with codes:
--- * constants.exitFailed (1) There are the failures.
--- * constants.exitOk (0) All tests are passed.
function Runner:done()
	if #self.failing > 0 then
		print(labels.resultFailed)
		os.exit(constants.exitFailed)
	else
		print(labels.resultPass)
		os.exit(constants.exitOk)
	end
end

return Runner
