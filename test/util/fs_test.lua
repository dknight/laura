local laura = require("laura")
local Spy = laura.Spy
local Context = laura.Context
local Stub = laura.Stub
local hooks = laura.hooks
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local fs = require("laura.util.fs")

describe("fs module", function()
	it("should import fs as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "util", "fs" }, "."))
		end).notToFail()
	end)

	describe("exists", function()
		it("should not exists", function()
			expect(fs.exists("boo")).toBe(false)
		end)

		it("should have existing directory", function()
			expect(fs.exists(".laurarc")).toBe(true)
		end)

		it("should have existing directory", function()
			expect(fs.exists("./src")).toBe(true)
		end)

		it("should have not existing directory", function()
			expect(fs.exists("./boobooboo")).toBe(false)
		end)
	end)

	describe("isdir", function()
		it("should be a directory", function()
			expect(fs.exists("src")).toBe(true)
		end)
	end)

	describe("mergeFromConfigFile", function()
		local spy
		local stub
		hooks.beforeEach(function()
			spy = Spy:new(function(a)
				return fs.mergeFromConfigFile(a)
			end)
			stub = Stub:new(Context, "global", function()
				return {
					config = {
						Hello = "w",
						Color = false,
					},
				}
			end)
		end)

		hooks.afterEach(function()
			stub:require()
		end)

		it("should merge config from config file", function()
			spy("./test/config_mock_test.lua")
			expect(spy).toHaveReturnedWith(true)
		end)

		it("should fail if config file do not exists", function()
			spy("./test/none.lua")
			expect(spy).toHaveReturnedWith(false)
		end)
	end)
end)
