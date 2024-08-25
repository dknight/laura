local it = require("lib.classes.It")
local describe = require("lib.classes.Describe")
local expect = require("lib.expect")

describe:skip("skip describe", function()
	it("skip 1st", function()
		expect(1 == 1).toBeTruthy()
	end)
	it("skip 2nd", function()
		expect(1 == 2).toBeFalsy()
	end)
end)

describe("skip it", function()
	it("skip 3rd", function()
		expect(1 == 1).toBeTruthy()
	end)
	it:skip("skip 4th", function()
		expect(1 == 2).toBeFalsy()
	end)
end)

describe:skip("both skip it and describe", function()
	it("skip 5th", function()
		expect(1 == 1).toBeTruthy()
	end)
	it:skip("skip 6th", function()
		expect(1 == 2).toBeFalsy()
	end)
end)
