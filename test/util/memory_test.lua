local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local memory = require("laura.util.memory")

describe("memory module", function()
	it("should import memory as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "util", "memory" }, "."))
		end).notToFail()
	end)

	describe("format", function()
		it("should be 700.00KB", function()
			expect(memory.format(700)).toEqual("700.00KB")
		end)

		it("should be 1.00MB", function()
			expect(memory.format(1024)).toEqual("1.00MB")
		end)

		it("should be 1.50GB", function()
			expect(memory.format(1572864)).toEqual("1.50GB")
		end)

		it("should be 2TB", function()
			expect(memory.format(1073741824 * 2)).toEqual("2.00TB")
		end)
	end)
end)
