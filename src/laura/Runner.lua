---@class RunResults
---@field memory any
---@field datetime string|osdate
---@field duration number
---@field total number
---@field passing Runnable[]
---@field failing Runnable[]
---@field skipping Runnable[]

local Context = require("laura.Context")
local Labels = require("laura.Labels")
local Runnable = require("laura.Runnable")
local Terminal = require("laura.Terminal")

---@class Runner
---@field private total number
---@field private passing Runnable[]
---@field private failing Runnable[]
---@field private skipping Runnable[]
---@field private reporters Reporter[]
---@field protected _ctx Context
local Runner = {
	_ctx = Context.global(),
}

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
	for _, id in ipairs(self._ctx.config.Reporters) do
		t.reporters[#t.reporters + 1] =
			require("laura.reporters." .. id):new({})
	end

	return setmetatable(t, {
		__index = self,
	})
end

---@return RunResults
function Runner:runTests()
	if not self._ctx.root then
		print(Labels.NoTests)
		os.exit(self._ctx.config._exitOK)
	end
	local tstart = os.clock()
	if self._ctx.root:hasOnly() then
		Runnable.filterOnly(self._ctx.root)
	end

	Runnable.traverse(self._ctx.root, function(test)
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
		os.exit(self._ctx.config._exitFailed)
	else
		print(Labels.ResultPass)
		os.exit(self._ctx.config._exitOK)
	end
end

return Runner
