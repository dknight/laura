local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it

describe("basic tests", function()
	it("numbers should be equal", function()
		expect(1).toEqual(1)
	end)

	it("strings not should be equal", function()
		expect("foo").notToEqual("bar")
	end)

	it("strings should be equal", function()
		expect("foo").toEqual("foo")
	end)

	it("booleans should be equal", function()
		expect(true).toEqual(true)
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

describe("should pass random not", function()
	it("is not a number", function()
		expect(1).notToBe(2)
	end)

	it("is not a boolean", function()
		expect(true).notToBe(false)
	end)

	it("is not nil", function()
		expect(nil).notToBe(1)
	end)

	it("is not a string", function()
		expect("foo").notToBe("bar")
	end)

	it("is not a table", function()
		expect({}).notToBe("bar")
	end)
end)
