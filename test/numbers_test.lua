local describe = require("laura.Suite")
local expect = require("laura.expect")
local it = require("laura.Test")
local mathx = require("laura.ext.mathx")

---Dirty rounding to integer
---@param x number
---@return number
local function round(x)
	local c = mathx.pow(2, 52) + mathx.pow(2, 51)
	return ((x + c) - c)
end

describe("numbers", function()
	describe("floats", function()
		it("should be rounded to lower", function()
			expect(round(4.442)).toEqual(4)
		end)

		it("should not to be rounded to lower", function()
			expect(round(4.442)).notToEqual(5)
		end)

		it("should be rounded to upper", function()
			expect(round(4.772)).toEqual(5)
		end)

		it("should not to be rounded to upper", function()
			expect(round(4.772)).notToEqual(4)
		end)

		it("should be floored", function()
			expect(math.floor(4.772)).toEqual(4)
		end)

		it("should not to be floored", function()
			expect(math.floor(4.772)).notToEqual(5)
		end)

		it("should be ceiled", function()
			expect(math.ceil(4.772)).toEqual(5)
		end)

		it("should not to be ceiled", function()
			expect(math.ceil(4.772)).notToEqual(4)
		end)
	end)

	describe("notToBeCloseTo", function()
		it("should be close with default precision 2", function()
			expect(4.715).toBeCloseTo(4.72)
		end)

		it("should notbe close with default precision 2", function()
			expect(4.715).notToBeCloseTo(4.4)
		end)

		it("should be close with precision 4", function()
			expect(4.7777).toBeCloseTo({ 4.77765, 4 })
		end)

		it("should not to be close with precision 4", function()
			expect(4.7777).notToBeCloseTo({ 4.7778, 4 })
		end)

		it("should be close with precision 1", function()
			expect(4.1).toBeCloseTo({ 4.14999, 1 })
		end)

		it("should not to be close with precision 1", function()
			expect(4.1).notToBeCloseTo({ 4.15, 1 })
		end)

		it("should be close with precision 0", function()
			expect(4.1).toBeCloseTo({ 4.5, 0 })
		end)

		it("should not to be close with precision 0", function()
			expect(4.1).notToBeCloseTo({ 5, 0 })
		end)
	end)

	describe("toBeGreaterThan", function()
		it("should be greater than 5", function()
			expect(8).toBeGreaterThan(5)
		end)

		it("should not to be greater than 10", function()
			expect(8).notToBeGreaterThan(10)
		end)
	end)

	describe("toBeGreaterThanOrEquall", function()
		it("should be greater than or equal to 8", function()
			expect(8).toBeGreaterThanOrEqual(8)
		end)

		it("should be greater than or equal to 5", function()
			expect(8).toBeGreaterThanOrEqual(5)
		end)

		it("should not to be greater than or equal to 9", function()
			expect(8).notToBeGreaterThanOrEqual(9)
		end)

		it("should not to be greater than or equal to 5", function()
			expect(8).notToBeGreaterThanOrEqual(10)
		end)
	end)

	describe("toBeLessThan", function()
		it("should be less than 10", function()
			expect(8).toBeLessThan(10)
		end)

		it("should not to be greater than 5", function()
			expect(8).notToBeLessThan(5)
		end)
	end)

	describe("toBeLessThanOrEqual", function()
		it("should be less than or equal to 8", function()
			expect(8).toBeLessThanOrEqual(8)
		end)

		it("should be less than or equal to 10", function()
			expect(8).toBeLessThanOrEqual(10)
		end)

		it("should not to be less than or equal to 5", function()
			expect(8).notToBeLessThanOrEqual(5)
		end)

		it("should not to be less than or equal to 7", function()
			expect(8).notToBeLessThanOrEqual(7)
		end)
	end)
end)
