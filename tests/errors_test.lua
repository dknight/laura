local describe = require("describe")
local expect = require("expect")
local it = require("it")

--- FIXME if no errors then all test are running??
describe("errors", function()
	describe("toFail", function()
		local errorFn = function()
			error("something went wrong")
		end
		local successFn = function()
			return true
		end

		it("should fail", function()
			expect(errorFn).toFail()
		end)

		it("should not fail", function()
			expect(successFn).notToFail()
		end)

		it("should fail and match error", function()
			expect(errorFn).toFail("wrong")
		end)

		it("should fail and not match error", function()
			expect(errorFn).toFail("wrong")
		end)

		it("should not fail and not match error", function()
			expect(errorFn).notToFail("hello")
		end)
	end)
end)
