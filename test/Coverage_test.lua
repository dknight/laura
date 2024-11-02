local laura = require("laura")
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Coverage = laura.Coverage
local Stub = laura.Stub
local hooks = laura.hooks

describe("Coverage", function()
	it("should import Coverage as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "Coverage" }, "."))
		end).notToFail()
	end)

	describe("new", function()
		it("should create Coverage instance with coverage disabled", function()
			local cov = Coverage:new()
			expect(cov).toHaveTypeOf("table")
		end)

		it("should create Coverage instance with coverage enabled", function()
			local stub = Stub:new(Coverage, "ctx", {
				config = {
					TestPattern = "*_test.lua",
					Coverage = {
						Enabled = true,
						Threshold = 50,
						ThresholdPoints = { 1, 2, 3 },
						IncludePattern = ".*%.lua",
						Reporters = { "terminal" },
					},
				},
			})
			local cov = Coverage:new()
			expect(cov).toHaveTypeOf("table")
			stub:restore()
		end)
	end)

	describe("createHookFunction", function()
		it("should create a hook function", function()
			local stub = Stub:new(debug, "getinfo", function()
				return {
					source = "@./src/laura/Coverage.lua",
					src_short = "/src/laura/Coverage.lua",
				}
			end)
			local cov = Coverage:new()
			local hook = cov:createHookFunction(2)
			expect(hook).toHaveTypeOf("function")
			stub:restore()
		end)
	end)

	-- TODO TESTS
end)
