local describe = require("describe")
local expect = require("expect")
local it = require("it")

describe("tables", function()
	-- TODO move tables here
	describe("toContain", function()
		it("should contain element in array", function()
			expect({ "hello", "world" }).toContain("world")
		end)

		it("should not to contain element in array", function()
			expect({ "hello", "world" }).notToContain("moon")
		end)
	end)
end)
