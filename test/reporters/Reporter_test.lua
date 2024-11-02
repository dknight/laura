local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local hooks = laura.hooks
local Reporter = laura.Reporter
local Stub = laura.Stub
local Spy = laura.Spy
local Runnable = laura.Runnable

describe("Reporter", function()
	local stub
	local reporter
	local spy

	hooks.beforeEach(function()
		stub = Stub:new(io, "write", function() end)
		reporter = Reporter:new({
			memory = 100,
			datetime = os.date("%z", 100000000),
			duration = 1,
			total = 10,
			passing = { Runnable:new("passed", function() end) },
			skipping = { Runnable:new("skipped", function() end) },
			failing = { Runnable:new("failed", function() end) },
		})
		spy = Spy:new()
	end)
	hooks.afterEach(function()
		stub:restore()
	end)

	it("should import Reporter as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "Reporter" }, "."))
		end).notToFail()
	end)

	describe("new", function()
		it("should be a reporter", function()
			expect(reporter).toHaveTypeOf("table")
		end)
	end)

	describe("reportSummary", function()
		it("should report summary", function()
			spy(reporter.reportSummary(reporter))
			expect(spy).toHaveBeenCalled()
		end)
	end)

	describe("reportPerformance", function()
		it("should report reportPerformance", function()
			spy(reporter.reportPerformance(reporter))
			expect(spy).toHaveBeenCalled()
		end)
	end)

	describe("finalSummary", function()
		it("should report finalSummary", function()
			spy(reporter.finalSummary(reporter))
			expect(spy).toHaveBeenCalled()
		end)
	end)

	describe("reportErrors", function()
		it("should report reportErrors", function()
			spy(reporter.reportErrors(reporter))
			expect(spy).toHaveBeenCalled()
		end)
	end)
end)
