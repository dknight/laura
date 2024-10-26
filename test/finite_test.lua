local describe = require("laura.Suite")
local expect = require("laura.expect")
local it = require("laura.Test")

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
