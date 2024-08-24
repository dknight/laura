local expect = require("lib.expect")
local it = require("lib.it")
local describe = require("lib.describe")

it("should be standalone 1", function()
	expect(true).toEqual(true)
end)

it("should be standalone 2", function()
	expect(true).toEqual(true)
end)

it("should be standalone 3", function()
	expect(true).toEqual(true)
end)

it("should be standalone 4 parent", function()
	expect(true).toEqual(true)

	-- FIXME? Not allowed these
	it("should be child 4-1", function()
		print("ignores this")
		expect(true).toEqual(false)
	end)
end)
