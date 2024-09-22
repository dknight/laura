local expect = require("expect")
local it = require("it")

it("should be standalone 1", function()
	expect(true).toEqual(true)
end)

it("should be standalone 2", function()
	expect(true).toEqual(true)
end)

it("should be standalone 3", function()
	expect(true).toEqual(true)
end)

it("should be standalone 4", function()
	expect(true).toEqual(true)

	it("should be child 4-1", function()
		expect(true).toEqual(true)
	end)
end)
