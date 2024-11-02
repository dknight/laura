local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local time = require("laura.util.time")

describe("time module", function()
	it("should import time as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "util", "time" }, "."))
		end).notToFail()
	end)

	describe("format", function()
		it("should be 42μs", function()
			expect(time.format(0.000042)).toEqual("42μs")
		end)

		it("should be 2ms", function()
			expect(time.format(0.002)).toEqual("2ms")
		end)

		it("should be 1s", function()
			expect(time.format(1)).toEqual("1s")
		end)

		it("should be 5m33s", function()
			expect(time.format(333)).toEqual("5m33s")
		end)

		it("should be 1h10m50s", function()
			expect(time.format(4250)).toEqual("1h10m50s")
		end)

		it("should retur nil if time is negative", function()
			expect(time.format(-1)).toBeNil()
		end)

		it("should retur nil if time is infinite", function()
			expect(time.format(-1)).toBeNil()
		end)
	end)
end)
