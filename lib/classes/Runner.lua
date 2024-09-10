---@alias RunResults {memory: any, datetime: string|osdate, duration: number, total: number, passing: Runnable[], failing: Runnable[], skipping: Runnable[]}

local Context = require("lib.classes.Context")
local labels = require("lib.labels")
local Runnable = require("lib.classes.Runnable")
local Terminal = require("lib.classes.Terminal")

local ctx = Context.global()

---@class Runner
---@field private total number
---@field private passing Runnable[]
---@field private failing Runnable[]
---@field private skipping Runnable[]
---@field private reporters Reporter[]
local Runner = {}

---@return Runner
function Runner:new()
	local t = {
		total = 0,
		passing = {},
		failing = {},
		skipping = {},
		reporters = {},
	}

	-- load reporters
	for _, id in ipairs(ctx.config.reporters) do
		t.reporters[#t.reporters + 1] = require("lib.reporters." .. id):new({})
	end

	return setmetatable(t, {
		__index = self,
	})
end

---Runs all test cases.
---@return RunResults
function Runner:runTests()
	local tstart = os.clock()
	if ctx.root:hasOnly() then
		Runnable.filterOnly(ctx.root)
	end

	Runnable.traverse(ctx.root, function(test)
		if test:isSuite() then
			for _, reporter in ipairs(self.reporters) do
				reporter:printSuiteTitle(test)
			end
		else
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
			self.total = self.total + 1
			for _, reporter in ipairs(self.reporters) do
				reporter:reportTest(test)
			end
		end
	end)

	return {
		datetime = os.date(),
		duration = os.clock() - tstart,
		failing = self.failing,
		memory = collectgarbage("count"),
		passing = self.passing,
		skipping = self.skipping,
		total = self.total,
	}
end

---Finishes runner. Should be called last. Exists the program with codes:
--- * ctx.config._exitFailed (1) There are the failures.
--- * ctx.config._exitOK (0) All tests are passed.
function Runner:done()
	Terminal.restore()
	if #self.failing > 0 then
		print(labels.resultFailed)
		os.exit(ctx.config._exitFailed)
	else
		print(labels.resultPass)
		os.exit(ctx.config._exitOK)
	end
end

return Runner
