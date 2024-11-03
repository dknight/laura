local laura = require("laura")
local errorx = require("laura.ext.errorx")
local hooks = laura.hooks
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Suite = laura.Suite
local Stub = laura.Stub

describe("Suite", function()
	local stub
	hooks.beforeAll(function()
		stub = Stub:new(errorx, "print", function() end)
	end)
	hooks.afterAll(function()
		stub:retore()
	end)

	it("should create suite", function()
		local suite = Suite:new("test suite", function() end)
		expect(suite).toHaveTypeOf("table")
	end)

	it(
		"should prepare a suite, if second argument is not a\z
		function and have an error",
		function()
			local suite = Suite:new("test suite", nil)
			suite:prepare()
			expect(suite.error).notToBeNil()
		end
	)

	it("should prepare a suite", function()
		local suite = Suite:new("test suite", function() end)
		suite:prepare()
		expect(suite).toHaveTypeOf("table")
	end)

	it("should prepare a suite, there is an error", function()
		local suite = Suite:new("test suite", function()
			error("failed")
		end)
		suite:prepare()
		expect(suite.error).notToBeNil()
	end)

	it("should prepare a suite, there is an error as Error", function()
		local suite = Suite:new("test suite", function()
			error({ title = "something went wrong" })
		end)
		suite:prepare()
		expect(suite.error).notToBeNil()
	end)
end)
