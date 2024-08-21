local it = require("lib.it")
local describe = require("lib.describe")
local expect = require("lib.expect")

-- describe("foo", "bar")
describe:skip("skipped tests", function()
	it("should be true", function()
		expect(1 == 1).toBeTruthy()
	end)
	it("should be false", function()
		expect(1 == 2).toBeFalsy()
	end)
end)

describe("basic tests", function()
	it:skip("hello", "world")
	it("numbers should be equal", function()
		expect(1).toEqual(2)
	end)

	it:only("strings should be equal", function()
		expect("foo").toEqual("foo")
	end)

	it:skip("booleans should be equal", function()
		expect(true).toEqual(false)
	end)

	it("tables refs should be equal", function()
		local t1 = { a = 1 }
		expect(t1).toEqual(t1)
	end)

	it("nils should be equal", function()
		expect(nil).toEqual(nil)
	end)

	it("should be truly", function()
		expect(1 == 1).toBeTruthy()
	end)

	it("should be falsy", function()
		expect(1 == 2).toBeFalsy()
	end)

	it("should be nil", function()
		expect(nil).toBeNil()
	end)

	it("tables should be deeply equal", function()
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
		}).toDeepEqual({
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

	describe("level 1", function()
		it("to equal level 1", function()
			expect(1).toEqual(1)
		end)
		describe("Level 2", function()
			it("to equal level 2", function()
				expect(1).toEqual(1)
			end)
			describe("Level 3", function()
				it("to equal level 3", function()
					expect(1).toEqual(1)
				end)
				it("to equal level 3", function()
					expect(1).toEqual(1)
				end)
			end)
		end)
	end)
	it("to equal level 0-1", function()
		expect(1).toEqual(1)
	end)
	it("to equal level 0-2", function()
		expect(1).toEqual(1)
	end)
end)
