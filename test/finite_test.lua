local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it

describe("finite numbers", function()
	it("should be finite", function()
		expect(1).toBeFinite()
	end)

	it("should not be finite", function()
		expect(1 / 0).notToBeFinite()
	end)

	it("should be finite large number", function()
		expect(999999999999999999999999).toBeFinite()
	end)
end)
