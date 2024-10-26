--
-- File used for random tests and experiments
-- TODO remove after testing is done
--
local describe = require("laura.Suite")
local it = require("laura.Test")
local expect = require("laura.expect")
local Spy = require("laura.Spy")

local Tim = {
	name = "Tim",
	age = 13,
	boy = true,
}

describe("toEqual", function()
	it("should be 13 years old", function()
		expect(Tim.age).toEqual(13)
	end)

	it("should be Tim", function()
		expect(Tim.name).toEqual("Tim")
	end)

	it("should be boy", function()
		expect(Tim.boy).toEqual(true)
	end)

	it("should have been play Doom 1", function()
		expect(Tim.playedDoom1).toEqual(nil)
	end)
end)

local function beepBoop()
	-- nil
end

local function redIsNotBlue()
	return "red" == "blue"
end
describe("tests", function()
	it("bloop returns null", function()
		expect(beepBoop()).toBeNil()
	end)

	it("bloop returns null", function()
		expect(redIsNotBlue()).toBeFalsy()
	end)

	it("beepBoop returns nil", function()
		expect(beepBoop()).toBeFalsy()
	end)

	local function isDarkAtNight()
		return true
	end

	it("beepBoop returns nil", function()
		expect(isDarkAtNight()).toBeTruthy()
	end)

	it("should be a number", function()
		expect(123).toHaveTypeOf("number")
	end)

	it("should be a string", function()
		expect("hello").toHaveTypeOf("string")
	end)

	it("should be a nil", function()
		expect(nil).toHaveTypeOf("nil")
	end)

	it("should be a table", function()
		expect({ a = 12, b = 13 }).toHaveTypeOf("table")
	end)

	it("should be same tables", function()
		local fruits1 = {
			apples = {
				count = 12,
				color = "green",
			},
			oranges = {
				count = 5,
				color = "orange",
			},
			bananas = {
				count = 3,
				color = "yellow",
			},
		}

		local fruits2 = {
			apples = {
				count = 12,
				color = "green",
			},
			oranges = {
				count = 5,
				color = "orange",
			},
			bananas = {
				count = 3,
				color = "yellow",
			},
		}
		expect(fruits1).notToEqual(fruits2)
		expect(fruits1).toDeepEqual(fruits2)
	end)

	local fibonacci = { 1, 2, 3, 5, 8, 13 }

	it("should have 6 first fibonacci numbers", function()
		expect(fibonacci).toHaveLength(6)
	end)

	local pets = {
		["cat"] = "barsik",
		["dog"] = "woofey",
		["hamster"] = "cookie",
		["rat"] = "Lara",
	}
	it("should have 4 animals", function()
		expect(pets).toHaveKeysLength(4)
	end)

	pets = {
		["cat"] = "Barsik",
		["dog"] = "Woofey",
		["hamster"] = "Cookie",
		["rat"] = "Lara",
	}

	it("should have a cat", function()
		expect(pets).toHaveKey("cat")
	end)

	it("should not to have a panda", function()
		expect(pets).notToHaveKey("panda")
	end)

	it("should be infinite", function()
		expect(math.huge).notToBeFinite()
	end)

	it("should infinite if divide by zero", function()
		expect(42 / 0).notToBeFinite()
	end)

	it("should be finite", function()
		expect(555).toBeFinite()
	end)

	it("should be great thn 40", function()
		expect(42).toBeGreaterThan(40)
	end)

	it("should be great equal than 42", function()
		expect(42).toBeGreaterThanOrEqual(42)
	end)

	it("should be less than 44", function()
		expect(42).toBeLessThan(44)
	end)

	it("should be less or equal than 42", function()
		expect(42).toBeLessThanOrEqual(42)
	end)

	it("should match substring", function()
		expect("Hello world").toMatch("world")
	end)

	it("should match float number", function()
		expect("-12.43256").toMatch("^-?%d+%.%d+$")
	end)

	it("should have a cat in a table", function()
		expect({ "cat", "dog", "panda" }).toContain("cat")
	end)

	it("should have a cat in a string", function()
		expect("Grey cat jumped out of window").toContain("cat")
	end)

	local errorFn = function()
		error("something went wrong")
	end

	it("should fail", function()
		expect(errorFn).toFail()
	end)

	it("should fail and match error pattern", function()
		expect(errorFn).toFail("wrong")
	end)

	local function eatCandy(callback)
		print("eat a candy")
		callback()
	end

	local spy = Spy:new()
	local retSpy = Spy:new(function(a)
		return a
	end)
	local meals = { "soup", "meat", "dessert" }

	local eat = function(meal, callback)
		print("Eating" .. " " .. meal)
		callback()
	end

	it("should be called with arguments", function()
		for _, v in ipairs(meals) do
			spy(v)
		end
		expect(spy).toHaveBeenCalledWith("meat")
		expect(spy).toHaveBeenFirstCalledWith("soup")
		expect(spy).toHaveBeenLastCalledWith("dessert")
		expect(spy).toHaveBeenNthCalledWith({ 2, "meat" })
	end)

	it("should return 'meat'", function()
		-- spy(function()
		-- return meals[2]
		-- end)
		-- expect(spy).toHaveReturned()
	end)

	it("should be return with argument", function()
		for _, meal in ipairs(meals) do
			retSpy(meal)
		end
		expect(retSpy).toHaveReturnedWith("meat")
	end)

	local getMeal = function(i)
		return function()
			return meals[i]
		end
	end

	it("should return all meals", function()
		local spy = Spy:new(getMeal)
		for i in ipairs(meals) do
			spy(i)
		end
		expect(spy).toHaveReturnedTimes(3)
	end)

	it("should be called", function()
		local spy = Spy:new(function(a)
			return a
		end)
		for _, meal in ipairs(meals) do
			spy(meal)
		end
		expect(spy).toHaveNthReturnedWith({ 2, "meat" })
	end)

	it("should be called", function()
		local spy = Spy:new(function(a)
			return a
		end)
		for _, meal in ipairs(meals) do
			spy(meal)
		end
		expect(spy).toHaveFirstReturnedWith("soup")
	end)

	it("should be return with argument", function()
		for _, meal in ipairs(meals) do
			retSpy(meal)
		end
		expect(retSpy).toHaveFirstReturnedWith("soup")
	end)

	it("should be return with argument", function()
		for _, meal in ipairs(meals) do
			retSpy(meal)
		end
		expect(retSpy).toHaveLastReturnedWith("dessert")
	end)

	it("should be return with argument", function()
		for _, meal in ipairs(meals) do
			retSpy(meal)
		end
		expect(retSpy).toHaveNthReturnedWith({ 2, "meat" })
	end)

	it("should be 'hello'", function()
		expect("hello").toEqual("hello")
	end)

	it("should not be 'hello'", function()
		expect("hello").notToEqual("hi")
	end)
end)
