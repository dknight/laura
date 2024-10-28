local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local hooks = laura.hooks
local Spy = laura.Spy

describe("before", function()
	local beforeAllSpy = Spy:new()
	local beforeEachSpy = Spy:new()

	hooks.beforeAll(beforeAllSpy)
	hooks.beforeEach(beforeEachSpy)

	it("before all should be called once", function()
		expect(beforeAllSpy).toHaveBeenCalledOnce()
	end)

	it("before each should be called twice", function()
		expect(beforeEachSpy).toHaveBeenCalledTimes(2)
	end)

	it("before each should be called trice", function()
		expect(beforeEachSpy).toHaveBeenCalledTimes(3)
	end)
end)

describe("after hooks", function()
	local afterAllSpy = Spy:new()
	local afterEachSpy = Spy:new()
	hooks.afterAll(afterAllSpy)
	hooks.afterEach(afterEachSpy)

	it("before all should be called", function()
		expect(afterEachSpy).notToHaveBeenCalled()
	end)

	it("before each should be called once", function()
		expect(afterEachSpy).toHaveBeenCalledTimes(1)
	end)

	it("before each should be called twice", function()
		expect(afterEachSpy).toHaveBeenCalledTimes(2)
	end)
end)

local beforeAllSpy = Spy:new()
local beforeEachSpy = Spy:new()
local afterAllSpy = Spy:new()
local afterEachSpy = Spy:new()

describe("direct call hooks", function()
	hooks.beforeAll(beforeAllSpy)
	hooks.beforeEach(beforeEachSpy)
	hooks.afterAll(afterAllSpy)
	hooks.afterEach(afterEachSpy)

	it("should call hook", function()
		expect(true).toBe(true)
	end)
	it("should call hook", function()
		expect(1).notToEqual(2)
	end)
end)

describe("call hooks tests", function()
	it("should call beforeAll once", function()
		expect(beforeAllSpy).toHaveBeenCalledOnce()
	end)
	it("should call afterAll once", function()
		expect(afterAllSpy).toHaveBeenCalledOnce()
	end)
	it("should call beforeEach twice", function()
		expect(beforeEachSpy).toHaveBeenCalledTimes(2)
	end)
	it("should call afterEach twice", function()
		expect(afterEachSpy).toHaveBeenCalledTimes(2)
	end)
end)
