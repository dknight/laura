local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it

local errorFn = function()
	error("something went wrong")
end
local successFn = function()
	return true
end

describe("errors", function()
	describe("toFail", function()
		it("should fail", function()
			expect(errorFn).toFail()
		end)

		it("should not fail", function()
			expect(successFn).notToFail()
		end)

		it("should fail and match error pattern", function()
			expect(errorFn).toFail("wrong")
		end)

		it("should not fail and do not match error", function()
			expect(errorFn).notToFail("hello")
		end)
	end)
end)
