local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local Stub = laura.Stub
local mathx = require("laura.ext.mathx")

describe("mathx module", function()
	it("should import mathx as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "ext", "mathx" }, "."))
		end).notToFail()
	end)

	describe("pow", function()
		it("shoud power a number", function()
			expect(mathx.pow(2, 10)).toEqual(1024)
		end)

		it("shoud power a number", function()
			expect(mathx.pow(2, 0)).toEqual(1)
		end)

		it("shoud have a negative power", function()
			expect(mathx.pow(10, -1)).toBeCloseTo(0.1)
		end)

		it("shoud power if not supported legacy math.pow", function()
			local stub = Stub:new(math, "pow", nil)
			expect(mathx.pow(2, 0)).toEqual(1)
			stub:restore()
		end)
	end)
end)
