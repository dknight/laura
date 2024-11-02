local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local stringx = require("laura.ext.stringx")

describe("stringx module", function()
	it("should import stringx as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "ext", "stringx" }, "."))
		end).notToFail()
	end)

	describe("split", function()
		it("should split a string", function()
			expect(stringx.split("abc def")).toDeepEqual({
				"abc",
				"def",
			})
		end)

		it("should split a empty string", function()
			expect(stringx.split("")).toDeepEqual({})
		end)

		it("should split a string by spaces", function()
			expect(stringx.split("1 2 3 4 5")).toDeepEqual({
				"1",
				"2",
				"3",
				"4",
				"5",
			})

			it("should split a string by separator", function()
				expect(stringx.split("a|b|c|d", "|")).toDeepEqual({
					"a",
					"b",
					"c",
					"d", -- FIXME try "e"
				})
			end)

			it("should split a string with empty multiple spaces", function()
				expect(stringx.split("a     b  c", "%s")).toDeepEqual({
					"a",
					"b",
					"c",
				})
			end)
		end)
	end)

	describe("trim", function()
		it("should trim an emoty string", function()
			expect(stringx.trim("")).toEqual("")
		end)

		it("should trim string from both end", function()
			expect(stringx.trim("  hello    ")).toEqual("hello")
		end)

		it("should trim string from right end", function()
			expect(stringx.trim("hello    ")).toEqual("hello")
		end)

		it("should trim string from left end", function()
			expect(stringx.trim("  hello")).toEqual("hello")
		end)

		it("should trim tabs", function()
			expect(stringx.trim("\t\thello\t")).toEqual("hello")
		end)
	end)

	describe("len", function()
		it("should be length of zero of an emtpy string", function()
			expect(stringx.len("")).toEqual(0)
		end)

		it("should be length of 5 of a string", function()
			expect(stringx.len("hello")).toEqual(5)
		end)

		it("should be length of 6 of the UTF8 string", function()
			expect(stringx.len("привет")).toEqual(6)
		end)
	end)
end)
