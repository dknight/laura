---@alias MatchResult {actual: any, expected: any, err: Error, ok: boolean, isNot: boolean, [string]: function}
---@alias Assertion fun(t: table, expected: any, cmp: fun(a: any, b?: any): boolean, Error?): boolean, Assertion

local errorx = require("lib.ext.errorx")
local helpers = require("lib.util.helpers")
local Labels = require("lib.Labels")
local tablex = require("lib.ext.tablex")

---@type Assertion
local function compare(t, expected, cmp)
	local err
	t.expected = expected
	-- not very elegant to return error extra error here
	t.ok, err = cmp(t.actual, t.expected)
	if not t.ok and not err then
		t.err = errorx.new(Labels.ErrorAssertion, t.actual, t.expected)
	end
	return t(expected)
end

---Checks the equality of actual and expected. This don't use deep comparison for tables.
---For tables use toDeepEqual method.
---@type Assertion
local function toEqual(t, expected)
	return compare(t, expected, function(a, b)
		return a == b
	end)
end

---Checks the deep equality of actual and expected.
---@type Assertion
local function toDeepEqual(t, expected)
	return compare(t, expected, function(a, b)
		local areBothTables = type(a) == "table" and type(b) == "table"
		t.ok = true
		if type(a) ~= type(b) then
			t.ok = false
		end

		if areBothTables then
			t.ok = tablex.equal(a, b)
		else
			t.ok = a == b
		end

		if not t.ok then
			if areBothTables then
				local diff, count = tablex.diff(a, b)
				t.err = errorx.new(
					Labels.ErrorAssertion,
					count.added,
					count.removed,
					"",
					tablex.diffToString(a, diff, 1)
				)
			else
				t.err = errorx.new(Labels.ErrorAssertion, a, b)
			end
		end
		return t.ok, t.err
	end)
end

---Checks if value is truthy, in Lua everything is true expect false and nil.
---@type Assertion
local function toBeTruthy(t, expected)
	return compare(t, expected, function(a)
		return a
	end)
end

---Checks if value is falsy, false and nil are false in Lua.
---@type Assertion
local function toBeFalsy(t, expected)
	return compare(t, expected, function(a)
		return a == false or a == nil
	end)
end

---Checks if value is nil.
---@type Assertion
local function toBeNil(t, expected)
	return compare(t, expected, function(a)
		return a == nil
	end)
end

---Checks if number is finite.
---@type Assertion
local function toBeFinite(t, expected)
	return compare(t, expected, function(a)
		return not (a == math.huge or a == -math.huge)
	end)
end

---Checks if number is infinite.
---@type Assertion
local function toBeInfinite(t, expected)
	return compare(t, expected, function(a)
		return a == math.huge or a == -math.huge
	end)
end

-- ---------------------------------------------------------------------------
-- Length and keys -----------------------------------------------------------
-- ---------------------------------------------------------------------------

---Checks length of a table. It uses # operator,
---so beware if table is not a sequence.
---@type Assertion
local function toHaveLength(t, expected)
	return compare(t, expected, function(a)
		local res = #a == expected
		if not res then
			t.err = errorx.new(Labels.ErrorAssertion, #a, expected)
		end
		return res, t.err
	end)
end

---Count keys in the table, where key is not nil.
---@type Assertion
local function toHaveKeysLength(t, expected)
	return compare(t, expected, function(a)
		local i = 0
		for _ in pairs(a) do
			i = i + 1
		end

		local res = i == expected
		if not res then
			t.err = errorx.new(Labels.ErrorAssertion, i, expected)
		end
		return res, t.err
	end)
end

---Checks a key in the table, where key is not nil.
---@type Assertion
local function toHaveKey(t, expected)
	return compare(t, true, function(a, b)
		local res = a[expected] ~= nil
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res, t.err
	end)
end

-- ---------------------------------------------------------------------------
-- Spies ---------------------------------------------------------------------
-- ---------------------------------------------------------------------------

---Checks that spy has been called
---@type Assertion
local function toHaveBeenCalled(t)
	return compare(t, true, function(a)
		local res = a:getCallsCount() > 0
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that spy has been called once.
---@type Assertion
local function toHaveBeenCalledOnce(t)
	return compare(t, true, function(a)
		local res = a:getCallsCount() == 1
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that spy has been called times.
---@type Assertion
local function toHaveBeenCalledTimes(t, expected)
	return compare(t, true, function(a)
		local res = a:getCallsCount() == expected
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that spy has been called with given arguments.
---@type Assertion
local function toHaveBeenCalledWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, call in ipairs(a:getCalls()) do
			for _, x in ipairs(call) do
				if x == expected then
					res = true
					break
				end
			end
		end

		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that last call called with given arguments.
---@type Assertion
local function toHaveBeenLastCalledWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, x in ipairs(a:getLastCall()) do
			if x == expected then
				res = true
				break
			end
		end

		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that last call called with given arguments.
---@type Assertion
local function toHaveBeenFirstCalledWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, x in ipairs(a:getFirstCall()) do
			if x == expected then
				res = true
				break
			end
		end
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that n-th call called with given arguments.
---expected must have the first key is a number of the call,
---second argument is an argument's value.
---@type Assertion
local function toHaveBeenNthCalledWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, x in ipairs(a:getCall(expected[1])) do
			if x == expected[2] then
				res = true
				break
			end
		end
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that spy has returned, and return value is not nil.
---@type Assertion
local function toHaveReturned(t)
	return compare(t, true, function(a)
		local res = false
		for _, call in ipairs(a:getCalls()) do
			for _, x in ipairs(call) do
				res = type(x) == "function" and x() ~= nil
				if res then
					break
				end
			end
		end

		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that spy has returned n times, and return value is not nil.
---@type Assertion
local function toHaveReturnedTimes(t, expected)
	return compare(t, expected, function(a)
		local i = 0
		for _, call in ipairs(a:getCalls()) do
			for _, x in ipairs(call) do
				if type(x) == "function" and x() ~= nil then
					i = i + 1
				end
			end
		end
		local res = i == expected
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks that spy has returned with argument
---@type Assertion
local function toHaveReturnedWith(t, expected)
	return compare(t, expected, function(a)
		local res = false
		for _, call in ipairs(a:getCalls()) do
			for _, x in ipairs(call) do
				if x == expected then
					res = true
					break
				end
			end
		end
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks the last call of the spy has returned with argument.
---@type Assertion
local function toHaveLastReturnedWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, x in ipairs(a:getLastCall(expected)) do
			if x == expected then
				res = true
				break
			end
		end
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks the first call of the spy has returned with argument.
---@type Assertion
local function toHaveFirstReturnedWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, x in ipairs(a:getFirstCall(expected)) do
			if x == expected then
				res = true
				break
			end
		end
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

---Checks N-th first call of the spy has returned with argument.
---@type Assertion
local function toHaveNthReturnedWith(t, expected)
	return compare(t, true, function(a)
		local res = false
		for _, x in ipairs(a:getCall(expected[1])) do
			if x == expected[2] then
				res = true
				break
			end
		end
		local act, exp = true, false
		if not res then
			act, exp = exp, act
		end
		t.err = errorx.new(Labels.ErrorAssertion, act, exp)
		return res
	end)
end

local matchers = {
	toBe = toDeepEqual, -- alias of toDeepEqual
	toBeNil = toBeNil,
	toBeFalsy = toBeFalsy,
	toBeFinite = toBeFinite,
	toBeInfinite = toBeInfinite,
	toBeTruthy = toBeTruthy,
	toDeepEqual = toDeepEqual,
	toEqual = toEqual,
	toHaveLength = toHaveLength,
	toHaveKeysLength = toHaveKeysLength,
	toHaveKey = toHaveKey,
	-- spies
	toHaveBeenCalled = toHaveBeenCalled,
	toHaveBeenCalledOnce = toHaveBeenCalledOnce,
	toHaveBeenCalledTimes = toHaveBeenCalledTimes,
	toHaveBeenCalledWith = toHaveBeenCalledWith,
	toHaveBeenFirstCalledWith = toHaveBeenFirstCalledWith,
	toHaveBeenLastCalledWith = toHaveBeenLastCalledWith,
	toHaveBeenNthCalledWith = toHaveBeenNthCalledWith,
	toHaveReturned = toHaveReturned,
	toHaveReturnedTimes = toHaveReturnedTimes,
	toHaveReturnedWith = toHaveReturnedWith,
	toHaveFirstReturnedWith = toHaveFirstReturnedWith,
	toHaveLastReturnedWith = toHaveLastReturnedWith,
	toHaveNthReturnedWith = toHaveNthReturnedWith,
}

-- create negations
-- spairs() is required here to be sure that functions are always in the
-- sorted order. Using pairs() iterator might cause random error.
for key, matcher in helpers.spairs(matchers) do
	local firstCap = key:sub(1, 1):upper()
	local rest = key:sub(2)
	local negKey = table.concat({ "not", firstCap, rest })
	matchers[negKey] = matcher
end

return matchers
