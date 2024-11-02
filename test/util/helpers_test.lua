local laura = require("laura")
local Stub = laura.Stub
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local helpers = require("laura.util.helpers")

describe("helpers module", function()
	it("should import memory as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "util", "helpers" }, "."))
		end).notToFail()
	end)

	describe("hasFlag", function()
		it('should have a flag "-v"', function()
			local stub = Stub:new(_G, "arg", { "-v", "-j" })
			expect(helpers.hasFlag("-v")).toBe(true)
			stub:restore()
		end)

		it('should have a flag "-h"', function()
			local stub = Stub:new(_G, "arg", { "-h", "-j" })
			expect(helpers.hasFlag("-h")).toBe(true)
			stub:restore()
		end)
	end)

	describe("processFlags", function()
		local flags = {
			{
				[1] = "-h",
			},
			{
				[1] = "-v",
			},
			{
				[1] = "-r",
				[2] = "text",
			},
			{
				[1] = "-S",
			},
			{
				[1] = "-s",
			},
			{
				[1] = "--no-color",
			},
			{
				[1] = "--color",
			},
			{
				[1] = "--no-coverage",
			},
			{
				[1] = "--coverage",
			},
			{
				[1] = "-c",
				[2] = ".laurarc",
			},
		}

		for i in ipairs(flags) do
			it("should processFlags: " .. flags[i][1], function()
				local stub = Stub:new(_G, "arg", flags[i])
				local res = helpers.processFlags(flags[i])
				expect(res).notToBeNil()
				stub:restore()
			end)
		end
	end)

	describe("usage", function()
		it("should print usage", function()
			expect(helpers.usage()).toBe(nil)
		end)
	end)

	describe("version", function()
		it("should print version", function()
			expect(helpers.version()).toHaveTypeOf("string")
		end)
	end)

	describe("tab", function()
		it("should print 2 tabs", function()
			expect(helpers.tab(2)).toBe("\t\t")
		end)

		it("should print 0 tabs", function()
			expect(helpers.tab(0)).toBe("")
		end)

		it("should print empty string if number is negative", function()
			expect(helpers.tab(-1)).toBe("")
		end)
	end)

	describe("spairs", function()
		it("should sort keys", function()
			local t = {
				["A"] = 1,
				["C"] = 2,
				["B"] = 3,
			}
			local t2 = {
				["A"] = 1,
				["B"] = 3,
				["C"] = 2,
			}
			for k, v in helpers.spairs(t) do
				expect(v).toBe(t2[k])
			end
		end)
	end)

	it("should sort with custom function", function()
		local t = {
			["A"] = 1,
			["C"] = 2,
			["B"] = 3,
		}
		local t2 = {
			["C"] = 2,
			["B"] = 3,
			["A"] = 1,
		}
		for k, v in
			helpers.spairs(t, function(a, b)
				return a > b
			end)
		do
			expect(v).toBe(t2[k])
		end
	end)
end)
