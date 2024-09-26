local describe = require("laura.describe")
local expect = require("laura.expect")
local it = require("laura.it")

describe("length", function()
	it("should return length of the table", function()
		expect({}).toHaveLength(0)
	end)

	it("should return length of the table", function()
		expect({ "a", "b", "c" }).toHaveLength(3)
	end)

	it("should return length of the table", function()
		expect({ "a", false, "c" }).notToHaveLength(4)
	end)

	it("should return length of the table", function()
		expect({ "a", "b", nil, "d" }).toHaveLength(4)
	end)

	it("should return length of the table", function()
		expect({
			[1] = "a",
			[2] = "b",
			[5] = nil,
			[6] = "d",
		}).toHaveLength(2)
	end)

	it("should return length of the table", function()
		expect({
			[1] = "a",
			[2] = "b",
			[5] = nil,
			[6] = "d",
		}).notToHaveLength(4)
	end)
end)

describe("length keys", function()
	it("should return length of the table 1", function()
		expect({}).toHaveKeysLength(0)
	end)

	it("should return length of the table 2", function()
		expect({ "a", "b", "c" }).toHaveKeysLength(3)
	end)

	it("should return length of the table 3", function()
		expect({ "a", nil, "c" }).toHaveKeysLength(2)
	end)

	it("should return length of the table 4", function()
		expect({ "a", nil, "c", nil, "e" }).toHaveKeysLength(3)
	end)

	it("should return length of the table 5", function()
		expect({ nil, "a", false }).toHaveKeysLength(2)
	end)

	it("should return length of the table 6", function()
		expect({ nil, nil, nil }).toHaveKeysLength(0)
	end)

	it("should return length of the table 7", function()
		expect({ true, false }).toHaveKeysLength(2)
	end)
end)
