local describe = require("laura.describe")
local expect = require("laura.expect")
local it = require("laura.it")

describe("strings", function()
	describe("toMatch", function()
		it("should match substring", function()
			expect("Hello world").toMatch("world")
		end)

		it("should not to match substring", function()
			expect("Hello world").notToMatch("moon")
		end)

		it("should match numbers", function()
			expect("4324").toMatch("(%d+)")
		end)

		it("should not match number", function()
			expect("4324").notToMatch("(%a+)")
		end)
	end)

	describe("string length", function()
		it("should have length 0", function()
			expect("").toHaveLength(0)
		end)

		it("should have length 11", function()
			expect("hello world").toHaveLength(11)
		end)

		--- TODO mock utf8
		-- it("should have length 6 (utf8)", function()
		-- expect("Привет").toHaveLength(6)
		-- end)
	end)

	describe("toContain", function()
		it("should contain substing", function()
			expect("hello world").toContain("world")
		end)

		it("should not to contain substing", function()
			expect("hello world").notToContain("boo")
		end)

		it("should contain element in array", function()
			expect({ "hello", "world" }).toContain("world")
		end)

		it("should not to contain element in array", function()
			expect({ "hello", "world" }).notToContain("moon")
		end)
	end)
end)
