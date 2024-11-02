local laura = require("laura")
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Test = laura.Test

-- Covered in Runnable.

describe("Test", function()
	it("should create test", function()
		local test = Test:new("test test", function() end)
		expect(test).toHaveTypeOf("table")
	end)
end)
