local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local Stub = laura.Stub
local errorx = require("laura.ext.errorx")

describe("errorx module", function()
	it("should import errorx as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "ext", "errorx" }, "."))
		end).notToFail()
	end)

	describe("new", function()
		it("should create an error instance", function()
			local err = errorx.new({
				actual = 200,
				actualOperator = "AOP",
				currentLine = -1,
				debuginfo = { "debugmock" },
				expected = 100,
				expectedOperator = "EOP",
				message = "Please learn the math",
				title = "100 not equal to 200",
				precision = 0,
				traceback = "traceback mock",
			})
			expect(err).toBe({
				actual = 200,
				actualOperator = "AOP",
				currentLine = -1,
				debuginfo = { "debugmock" },
				expected = 100,
				expectedOperator = "EOP",
				message = "Please learn the math",
				title = "100 not equal to 200",
				precision = 0,
				traceback = "traceback mock",
			})
		end)
	end)

	describe("toString", function()
		it("should convert error to string if error is number", function()
			local err = errorx.new({
				actual = 200,
				actualOperator = "AOP",
				currentLine = -1,
				debuginfo = debug.getinfo(1),
				expected = 100,
				expectedOperator = "EOP",
				message = "Please learn the math",
				title = "100 not equal to 200",
				precision = 0,
				traceback = "traceback mock",
			})
			local str = errorx.toString(err, false)
			expect(str).toHaveTypeOf("string")
		end)

		it("should convert error to string if error is table", function()
			local dbginfo = debug.getinfo(1)
			dbginfo.activelines = { 1, 2, 3 }
			local err = errorx.new({
				actual = { a = 1 },
				actualOperator = "AOP",
				currentLine = -1,
				debuginfo = dbginfo,
				expected = { b = 1 },
				expectedOperator = "EOP",
				message = "Please learn the math",
				title = "{a = 1} not equal to {b = 1}",
				precision = 0,
				traceback = "traceback mock",
			})
			local str = errorx.toString(err, false)
			expect(str).toHaveTypeOf("string")
		end)

		it("should convert error to string if error is string", function()
			local dbginfo = debug.getinfo(1)
			dbginfo.activelines = { 1, 2, 3 }
			local err = errorx.new({
				actual = "hello",
				actualOperator = "AOP",
				currentLine = -1,
				debuginfo = dbginfo,
				expected = "world",
				expectedOperator = "EOP",
				message = "Please learn the math",
				title = "'hello' not equal to 'world'}",
				precision = 0,
				traceback = "traceback mock",
			})
			local str = errorx.toString(err, false)
			expect(str).toHaveTypeOf("string")
		end)
	end)

	describe("printError", function()
		it("should print error", function()
			local err = errorx.new({
				actual = 200,
				actualOperator = "AOP",
				currentLine = -1,
				debuginfo = debug.getinfo(1),
				expected = 100,
				expectedOperator = "EOP",
				message = "Please learn the math",
				title = "100 not equal to 200",
				precision = 0,
				traceback = "traceback mock",
			})
			local stub = Stub:new(errorx, "printError", function()
				print("a")
			end)
			expect(errorx.printError(err, false)).toBeNil()
			stub:restore()
		end)
	end)
end)
