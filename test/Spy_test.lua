local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local hooks = laura.hooks
local Spy = laura.Spy

describe("Spy", function()
	local spy
	local retSpy
	hooks.beforeEach(function()
		spy = Spy:new()
		retSpy = Spy:new(function(a)
			return a
		end)
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
		spy = Spy:new(function()
			return true
		end)
		spy()
		expect(spy).toHaveReturned()
	end)

	it("should not be returned", function()
		spy = Spy:new(function()
			return nil
		end)
		spy()
		expect(spy).notToHaveReturned()
	end)

	it("should be returned 4 times", function()
		for _ = 1, 4 do
			retSpy(math.random(4))
		end
		expect(retSpy).toHaveReturnedTimes(4)
	end)

	it("should not be returned 4 times", function()
		for _ = 1, 2 do
			retSpy(math.random(4))
		end
		expect(retSpy).notToHaveReturnedTimes(4)
	end)

	it("should be return with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).toHaveReturnedWith("middle")
	end)

	it("should not be returned with argument", function()
		retSpy("first")
		expect(retSpy).notToHaveReturnedWith("second")
	end)

	it("should be first returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).toHaveFirstReturnedWith("first")
	end)

	it("should not be first returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).notToHaveFirstReturnedWith("middle")
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).toHaveLastReturnedWith("last")
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).notToHaveLastReturnedWith("middle")
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).toHaveNthReturnedWith({ 2, "middle" })
	end)

	it("should be last returned with argument", function()
		for _, v in ipairs({ "first", "middle", "last" }) do
			retSpy(v)
		end
		expect(retSpy).notToHaveNthReturnedWith({ 1, "middle" })
	end)
end)
