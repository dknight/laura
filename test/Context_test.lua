local laura = require("laura")
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Context = laura.Context

describe("Context", function()
	it("should import Context as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "Context" }, "."))
		end).notToFail()
	end)

	it("should create context", function()
		local ctx = Context.new()
		expect(ctx).toHaveTypeOf("table")
	end)

	it("should have root in context", function()
		local ctx = Context.global()
		expect(ctx).toHaveKey("root")
	end)
end)
