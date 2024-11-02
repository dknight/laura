local laura = require("laura")
local describe = laura.describe
local Stub = laura.Stub
local expect = laura.expect
local it = laura.it
local osx = require("laura.ext.osx")

describe("osx module", function()
	it("should import stringx as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "ext", "osx" }, "."))
		end).notToFail()
	end)

	describe("isWindows", function()
		it("should be a windows os stubbed", function()
			local stub = Stub:new(osx, "isWindows", function()
				return true
			end)
			expect(osx.isWindows()).toBe(true)
			stub:restore()
		end)

		it("should be a windows os", function()
			local stub = Stub:new(package, "config", "\\")
			expect(osx.isWindows()).toBe(true)
			stub:restore()
		end)
	end)
end)
