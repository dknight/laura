local it = require("lib.classes.It")
local describe = require("lib.classes.Describe")
local expect = require("lib.expect")

describe("basic tests", function()
	it("hello", "world")
	it:skip("numbers should be equal", function()
		expect(1).toEqual(1)
	end)

	it("strings should be equal", function()
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

	-- it:skip("tables should be deeply equal", function()
	-- 	expect({
	-- 		["0"] = 0,
	-- 		p = "r",
	-- 		a = 11,
	-- 		b = "boo",
	-- 		z = "x",
	-- 		c = { a = 42, d = "D" },
	-- 		y = {},
	-- 		w = { u = "X" },
	-- 		zz = nil,
	-- 	}).toDeepEqual({
	-- 		["0"] = 0,
	-- 		p = "r",
	-- 		a = 11,
	-- 		b = "zoo",
	-- 		c = {
	-- 			d = "E",
	-- 			f = "F",
	-- 			g = "H",
	-- 		},
	-- 		y = {
	-- 			name = "dima",
	-- 			last = "smirnov",
	-- 			mid = {
	-- 				[0] = 23,
	-- 				[1] = 44,
	-- 			},
	-- 		},
	-- 	})
	-- end)

	describe("level 1 boo", function()
		it("to equal level 1", function()
			expect(1).toEqual(1)
		end)
		describe("Level 2", function()
			it("to equal level 2-1", function()
				expect(1).toEqual(1)
			end)
			it("to equal level 2-2", function()
				expect(1).toEqual(1)
			end)
			describe("Level 3", function()
				it("to equal level 3-1", function()
					expect(1).toEqual(1)
				end)
				it:skip("to equal level 3-2", function()
					expect(1).toEqual(1)
				end)
			end)
		end)
	end)
	it("to equal level 1-1", function()
		expect(1).toEqual(1)
	end)
	it("to equal level 1-2", function()
		expect(1).toEqual(1)
	end)
end)
