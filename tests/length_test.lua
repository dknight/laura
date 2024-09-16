local describe = require("describe")
local expect = require("expect")
local it = require("it")

describe("lengths", function()
	it("should return length of the table", function()
		expect({}).toHaveLength(0)
	end)

	it("should return length of the table", function()
		expect({ "a", "b", "c" }).toHaveLength(3)
	end)

	it("should return length of the table", function()
		expect({ "a", "b", "c" }).notToHaveLength(4)
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

describe("lengths keys", function()
	it("should return length of the table", function()
		expect({}).toHaveKeysLength(0)
	end)

	it("should return length of the table", function()
		expect({ "a", "b", "c" }).toHaveKeysLength(3)
	end)

	it("should return length of the table", function()
		expect({ "a", nil, "c" }).toHaveKeysLength(2)
	end)

	it("should return length of the table", function()
		expect({ "a", nil, "c", nil, "e" }).toHaveKeysLength(3)
	end)

	it("should return length of the table", function()
		expect({ nil, "a", false }).toHaveKeysLength(2)
	end)

	it("should return length of the table", function()
		expect({ nil, nil, nil }).toHaveKeysLength(0)
	end)

	it("should return length of the table", function()
		expect({ true, false }).toHaveKeysLength(2)
	end)
end)

describe("have key", function()
	it("should return length of the table", function()
		expect({ "a", "b" }).toHaveKey(1)
	end)

	it("should return length of the table", function()
		expect({ firstname = "John", lastname = "Doe" }).toHaveKey("firstname")
	end)

	it("should return length of the table", function()
		expect({ firstname = "John", lastname = "Doe" }).notToHaveKey(
			"middlename"
		)
	end)
end)
