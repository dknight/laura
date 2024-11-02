local laura = require("laura")
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Stub = laura.Stub

describe("Stub", function()
	it("should create stub", function()
		local t = {
			hello = "world",
		}
		local stub = Stub:new(t, "hello", "space")
		expect(t.hello).toEqual("space")
		stub:restore()
	end)

	it("should stub standard library", function()
		local stubFn = function(prog)
			return "external program `" .. prog .. "` is not permitted"
		end
		local stub = Stub:new(os, "execute", stubFn)
		expect(os.execute("dir")).toEqual(
			"external program `dir` is not permitted"
		)
		stub:restore()
		local result = os.execute("dir")
		-- COMPAT os.execute in Lua 5.1 returns the code (number)
		expect(result).toBeTruthy()
	end)
end)
