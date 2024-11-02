local laura = require("laura")
local bind = require("laura.util.bind")
local describe = laura.describe
local expect = laura.expect
local it = laura.it

describe("bind module", function()
	it("should import bind as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "util", "bind" }, "."))
		end).notToFail()
	end)

	it("should bind boolean as arguments", function()
		local f = function(a)
			return a
		end
		local g = bind(f, true)
		expect(g()).toBe(true)
	end)

	it("should bind table as arguments", function()
		local f = function(firstname, lastname)
			return {
				firstname = firstname,
				lastname = lastname,
			}
		end
		local g = bind(f, "Laura")
		expect(g("X")).toBe({
			firstname = "Laura",
			lastname = "X",
		})
	end)
end)
