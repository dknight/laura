-- toBeCloseTo

local describe = require("describe")
local expect = require("expect")
local it = require("it")

--- dirty rounding tp integerr
local function round(number)
	local c = 2 ^ 52 + 2 ^ 51 -- TODO math.pow() compatible
	return ((number + c) - c)
end

describe("floats", function()
	it("shoulbd be rounded to lower", function()
		expect(round(4.442)).toEqual(4)
	end)

	it("shoulbd be rounded to upper", function()
		expect(round(4.772)).toEqual(5)
	end)

	it("shoulbd be floored", function()
		expect(math.floor(4.772)).toEqual(4)
	end)

	it("shoulbd be ceiled", function()
		expect(math.ceil(4.772)).toEqual(5)
	end)
end)

describe("close to", function()
	it("shoulbd be close with default precision 2", function()
		expect(4.715).toBeCloseTo(4.72)
	end)

	it("shoulbd be close with precision 4", function()
		expect(4.7777).toBeCloseTo({ 4.77765, 4 })
	end)

	it("shoulbd be close with precision 1", function()
		expect(4.1).toBeCloseTo({ 4.14999, 1 })
	end)

	it("shoulbd be close with precision 0", function()
		expect(4.1).toBeCloseTo({ 4.5, 0 })
	end)
end)
