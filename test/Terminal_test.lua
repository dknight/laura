local laura = require("laura")
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Terminal = laura.Terminal

describe("Terminal", function()
	it("should import Terminal as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "Terminal" }, "."))
		end).notToFail()
	end)

	-- TODO TESTS
end)
