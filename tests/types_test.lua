local describe = require("laura.describe")
local expect = require("laura.expect")
local it = require("laura.it")

describe("types", function()
	it("should have nil type", function()
		expect(nil).toHaveTypeOf("nil")
	end)

	it("should not have nil type", function()
		expect(nil).notToHaveTypeOf("number")
	end)

	it("should have table type", function()
		expect({}).toHaveTypeOf("table")
	end)

	it("should have string type", function()
		expect("laura").toHaveTypeOf("string")
	end)

	it("should have number type", function()
		expect(42).toHaveTypeOf("number")
	end)

	it("should have boolean type", function()
		expect(true).toHaveTypeOf("boolean")
	end)

	it("should have function type", function()
		expect(function() end).toHaveTypeOf("function")
	end)
end)
