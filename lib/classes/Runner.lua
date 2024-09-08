---@alias RunResults {memory: any, datetime: string|osdate, duration: number, total: number, passing: Runnable[], failing: Runnable[], skipping: Runnable[]}

local Context = require("lib.classes.Context")
local labels = require("lib.labels")
local Runnable = require("lib.classes.Runnable")

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
---@return RunResults
function Runner:runTests()
	local tstart = os.clock()
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

	return {
		datetime = os.date(),
		duration = os.clock() - tstart,
		failing = self.failing,
		memory = collectgarbage("count"),
		passing = self.passing,
		skipping = self.skipping,
		total = self.totalCount,
	}
end

---Finishes runner. Should be called last. Exists the program with codes:
--- * ctx.config._exitFailed (1) There are the failures.
--- * ctx.config._exitOK (0) All tests are passed.
function Runner:done()
	if #self.failing > 0 then
		print(labels.ResultFailed)
		os.exit(ctx.config._exitFailed)
	else
		print(labels.ResultPass)
		os.exit(ctx.config._exitOK)
	end
end

return Runner
