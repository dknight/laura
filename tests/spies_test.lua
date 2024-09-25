local describe = require("describe")
local expect = require("expect")
local it = require("it")
local hooks = require("hooks")
local Spy = require("src.Spy")

describe("spies", function()
	local spy
	hooks.beforeEach(function()
		spy = Spy:new()
	end)

	it("should be called", function()
		spy()
		expect(spy).toHaveBeenCalled()
	end)

	it("should not be called", function()
		expect(spy).notToHaveBeenCalled()
	end)

	it("should be called once", function()
		spy()
		expect(spy).toHaveBeenCalledOnce()
	end)

	it("should not have been called", function()
		for _ = 1, 2 do
			spy()
		end
		expect(spy).notToHaveBeenCalledOnce()
	end)

	it("should be called zero times", function()
		expect(spy).toHaveBeenCalledTimes(0)
	end)

	it("should be called trice", function()
		for _ = 1, 3 do
			spy()
		end
		expect(spy).toHaveBeenCalledTimes(3)
	end)

	it("should be called trice", function()
		expect(spy).notToHaveBeenCalledTimes(3)
	end)

	it("should not be called trice", function()
		for _ = 1, 2 do
			spy()
		end
		expect(spy).notToHaveBeenCalledTimes(3)
	end)

	it("should be called with argument", function()
		spy("foo")
		expect(spy).toHaveBeenCalledWith("foo")
	end)

	it("should not be called with argument", function()
		expect(spy).notToHaveBeenCalledWith("foo")
	end)

	it("should be called with arguments", function()
		for i in ipairs({ 1, 2, 3 }) do
			spy(i)
		end
		expect(spy).toHaveBeenCalledWith(3)
	end)

	it("should be called with arguments", function()
		for _, v in ipairs({ "foo", "bar", "cow" }) do
			spy(v)
		end
		expect(spy).toHaveBeenCalledWith("bar")
	end)

	it("should not be called with arguments", function()
		for i in ipairs({ 1, 2, 3 }) do
			spy(i)
		end
		expect(spy).notToHaveBeenCalledWith(4)
	end)

	it("should be called with table arguments", function()
		local t1 = { a = 1 }
		local t2 = { b = 2 }
		for _, t in ipairs({ t1, t2 }) do
			spy(t)
		end
		expect(spy).toHaveBeenCalledWith(t2)
	end)

	it("should be last called with argument", function()
		for _, t in ipairs({ "first", "middle", "last" }) do
			spy(t)
		end
		expect(spy).toHaveBeenLastCalledWith("last")
	end)

	it("should be last called with argument", function()
		for _, t in ipairs({ "first", "middle", "last" }) do
			spy(t)
		end
		expect(spy).notToHaveBeenLastCalledWith("middle")
	end)

	it("should be first called with argument", function()
		for _, t in ipairs({ "first", "middle", "last" }) do
			spy(t)
		end
		expect(spy).toHaveBeenFirstCalledWith("first")
	end)

	it("should be first called with argument", function()
		for _, t in ipairs({ "first", "middle", "last" }) do
			spy(t)
		end
		expect(spy).notToHaveBeenFirstCalledWith("middle")
	end)

	it("should be 2nd called with argument", function()
		for _, t in ipairs({ "first", "middle", "last" }) do
			spy(t)
		end
		expect(spy).toHaveBeenNthCalledWith({ 2, "middle" })
	end)

	it("should be 2nd called with argument", function()
		for _, t in ipairs({ "first", "middle", "last" }) do
			spy(t)
		end
		expect(spy).notToHaveBeenNthCalledWith({ 1, "middle" })
	end)

	it("should be returned", function()
		spy(function()
			return true
		end)
		expect(spy).toHaveReturned()
	end)

	it("should not be returned", function()
		spy(function()
			return nil
		end)
		expect(spy).notToHaveReturned()
	end)

	it("should be returned 4 times", function()
		for _ = 1, 4 do
			spy(function()
				return math.random(4)
			end)
		end
		expect(spy).toHaveReturnedTimes(4)
	end)

	it("should not be returned 4 times", function()
		for _ = 1, 2 do
			spy(function()
				return math.random(4)
			end)
		end
		expect(spy).notToHaveReturnedTimes(4)
	end)

	it("should be return with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).toHaveReturnedWith("middle")
	end)

	it("should not be returned with argument", function()
		spy(function()
			return "first"
		end)
		expect(spy).notToHaveReturnedWith("second")
	end)

	it("should be first returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).toHaveFirstReturnedWith("first")
	end)

	it("should not be first returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).notToHaveFirstReturnedWith("middle")
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).toHaveLastReturnedWith("last")
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).notToHaveLastReturnedWith("middle")
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).toHaveNthReturnedWith({ 2, "middle" })
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			spy(function()
				return v
			end)
		end
		expect(spy).notToHaveNthReturnedWith({ 1, "middle" })
	end)
end)
