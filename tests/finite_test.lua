local describe = require("describe")
local expect = require("expect")
local it = require("it")

describe("finite numbers", function()
	it("should be finite", function()
		expect(1).toBeFinite()
	end)

	it("should be finite large number", function()
		expect(999999999999999999999999).toBeFinite()
	end)

	it("should be positive infinity", function()
		expect(math.huge).toBeInfinite()
	end)

	it("should be negative infinity", function()
		expect(-math.huge).toBeInfinite()
	end)
end)
