local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it

describe:skip("skip describe", function()
	it("skip 1-1", function()
		expect(1 == 1).toBeTruthy()
	end)
	it("skip 1-2", function()
		expect(1 == 2).toBeFalsy()
	end)
	describe:skip("skip nested 1 suite", function()
		it("skip nested 1-1", function()
			expect(1 == 2).toBeFalsy()
		end)
		describe:skip("skip nested 2 suite", function()
			it("skip nested 1-2", function()
				expect(1 == 2).toBeFalsy()
			end)
		end)
	end)
end)

describe("skip it", function()
	it("skip it 1", function()
		expect(1 == 1).toBeTruthy()
	end)
	it:skip("skip it 2", function()
		expect(1 == 2).toBeFalsy()
	end)
end)

describe:skip("both skip it and describe", function()
	it("skip 5th", function()
		expect(1 == 1).toBskippedeTruthy()
	end)
	it:skip("skip 6th", function()
		expect(1 == 2).toBeFalsy()
	end)
end)