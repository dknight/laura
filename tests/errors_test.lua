local describe = require("describe")
local expect = require("expect")
local it = require("it")

local errorFn = function()
	error("something went wrong")
end
local successFn = function()
	return true
end

--- FIXME if no errors then all test are running??
describe("errors", function()
	describe("toFail", function()
		it("should fail", function()
			expect(errorFn).toFail()
		end)

		it("should not fail", function()
			expect(successFn).notToFail()
		end)

		it("should fail and do not match error", function()
			expect(errorFn).toFail("wrong")
		end)

		it("should fail and do not match error", function()
			expect(errorFn).toFail("wrong")
		end)

		it("should not fail and do not match error", function()
			expect(errorFn).notToFail("hello")
		end)
	end)
end)
