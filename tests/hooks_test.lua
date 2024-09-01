local it = require("lib.classes.It")
local expect = require("lib.expect")
local describe = require("lib.classes.Describe")
local hooks = require("lib.hooks")

describe("hooks", function()
	hooks.beforeAll(function()
		print("beforeAll hook")
	end)
	hooks.afterAll(function()
		print("afterAll hook")
	end)
	hooks.beforeEach(function()
		print("beforeEach hook")
	end)
	hooks.afterEach(function()
		print("afterEach hook")
	end)

	it("hooks 1", function()
		expect(1).toEqual(1)
	end)
	it("hooks 2", function()
		expect(1).toEqual(1)
	end)
end)
