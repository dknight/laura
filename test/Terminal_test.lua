local laura = require("laura")
local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Terminal = laura.Terminal
local Spy = laura.Spy
local Stub = laura.Stub
local hooks = laura.hooks

describe("Terminal", function()
	local spy
	local stub
	hooks.beforeEach(function()
		stub = Stub:new(io, "write", function() end)
		spy = Spy:new()
	end)

	hooks.afterEach(function()
		stub:restore()
	end)

	it("should import Terminal as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "Terminal" }, "."))
		end).notToFail()
	end)

	it("should fail if non-existing color is set to Terminal", function()
		local fn = function()
			---@diagnostic disable-next-line: inject-field
			Terminal.Color.Magenta = "Magenta"
		end
		expect(fn()).toFail()
	end)

	it("should fail if non-existing style is set to Terminal", function()
		local fn = function()
			---@diagnostic disable-next-line: inject-field
			Terminal.Style.DarkMoon = "RED"
		end
		expect(fn()).toFail()
	end)

	describe("toggleCursor, restpre", function()
		it("should turn off cursor", function()
			spy(Terminal.toggleCursor(false))
			expect(spy).toHaveBeenCalled()
		end)

		it("should turn on cursor", function()
			spy(Terminal.toggleCursor(true))
			expect(spy).toHaveBeenCalled()
		end)

		it("should restore Terminal", function()
			local colorStub = Stub:new(Terminal, "isColorSupported", function()
				return true
			end)
			spy(Terminal.restore())
			expect(spy).toHaveBeenCalled()
			colorStub:restore()
		end)
	end)

	-- may fail on some systems
	describe("isColorSupported", function()
		it("should support the color", function()
			local envStub = Stub:new(os, "getnev", function()
				return "xterm"
			end)
			local isColor = Terminal.isColorSupported()
			expect(isColor).toBe(true)
			envStub:restore()
		end)
	end)

	describe("printExpected", function()
		it("should print expect value", function()
			spy(Terminal.printExpected("expected", "", 0))
			expect(spy).toHaveBeenCalled()
		end)
	end)

	describe("printActual", function()
		it("should print actual value", function()
			spy(Terminal.printActual("actual", "", 0))
			expect(spy).toHaveBeenCalled()
		end)
	end)

	describe("printSkipped", function()
		it("should print skipped value", function()
			spy(Terminal.printSkipped("skip", "", 0))
			expect(spy).toHaveBeenCalled()
		end)
	end)

	describe("printWarning", function()
		it("should print warning value", function()
			spy(Terminal.printWarning("warn", "", 0))
			expect(spy).toHaveBeenCalled()
		end)
	end)
end)
