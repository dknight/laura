---@alias RunResults {memory: any, datetime: string|osdate, duration: number, total: number, passing: Runnable[], failing: Runnable[], skipping: Runnable[]}

local Context = require("lib.Context")
local Labels = require("lib.Labels")
local Runnable = require("lib.Runnable")
local Terminal = require("lib.Terminal")

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
	for _, id in ipairs(ctx.config.Reporters) do
		t.reporters[#t.reporters + 1] = require("lib.reporters." .. id):new({})
	end

	return setmetatable(t, {
		__index = self,
	})
end

---Runs all test cases.
---@return RunResults
function Runner:runTests()
	if not ctx.root then
		print(Labels.NoTests)
		os.exit(ctx.config._exitOK)
	end
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
		memory = collectgarbage("count"), -- TODO check "incremental?"
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
		print(Labels.ResultFailed)
		os.exit(ctx.config._exitFailed)
	else
		print(Labels.ResultPass)
		os.exit(ctx.config._exitOK)
	end
end

return Runner
