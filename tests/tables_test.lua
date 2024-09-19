local describe = require("describe")
local expect = require("expect")
local it = require("it")

describe("tables", function()
	it("tables refs should be equal", function()
		local t1 = { a = 1 }
		expect(t1).toEqual(t1)
	end)

	it("tables refs not should be equal", function()
		local t1 = { a = 1 }
		local t2 = { a = 1 }
		expect(t1).notToEqual(t2)
	end)

	it("should be deeply equal", function()
		local t1 = {
			["0"] = 0,
			p = "r",
			a = 11,
			b = "boo",
			z = "x",
			c = { a = 42, d = "D" },
			y = {},
			w = { u = "X" },
			zz = nil,
		}
		local t2 = {
			["0"] = 0,
			p = "r",
			a = 11,
			b = "boo",
			z = "x",
			c = { a = 42, d = "D" },
			y = {},
			w = { u = "X" },
			zz = nil,
		}
		expect(t1).toDeepEqual(t2)
	end)

	it("should not be deeply equal", function()
		expect({
			["0"] = 0,
			p = "r",
			a = 11,
			b = "boo",
			z = "x",
			c = { a = 42, d = "D" },
			y = {},
			w = { u = "X" },
			zz = nil,
		}).notToDeepEqual({
			["0"] = 0,
			p = "r",
			a = 11,
			b = "zoo",
			c = {
				d = "E",
				f = "F",
				g = "H",
			},
			y = {
				name = "dima",
				last = "smirnov",
				mid = {
					[0] = 23,
					[1] = 44,
				},
			},
		})
	end)

	describe("toContain", function()
		it("should contain element in array", function()
			expect({ "hello", "world" }).toContain("world")
		end)

		it("should not to contain element in array", function()
			expect({ "hello", "world" }).notToContain("moon")
		end)
	end)
end)
