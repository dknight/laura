---@class MatchResult
---@field actual any
---@field expected any
---@field error Error
---@field ok boolean
---@field isNot boolean

---@alias comparator fun(a: any, b?: any): boolean, Error?
---@alias Assertion fun(t: table, expected: any, cmp: comparator): boolean Error?

local Context = require("lib.Context")
local errorx = require("lib.ext.errorx")
local helpers = require("lib.util.helpers")
local Labels = require("lib.Labels")
local mathx = require("lib.ext.mathx")
local Status = require("lib.Status")
local tablex = require("lib.ext.tablex")
local Terminal = require("lib.Terminal")
local stringx = require("lib.ext.stringx")

local ctx = Context.global()

---@type Assertion
local function compare(t, expected, cmp)
	local err
	t.expected = expected
	-- not very elegant to return error extra error here
	t.ok, err = cmp(t.actual, t.expected)
	if not t.ok and not err then
		t.error = errorx.new(
			t.error.message or Labels.ErrorAssertion,
			t.actual,
			t.expected
		)
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
				t.error = errorx.new(
					Labels.ErrorAssertion,
					count.added,
					count.removed,
					"",
					tablex.diffToString(a, diff, 1)
				)
			else
				t.error = errorx.new(Labels.ErrorAssertion, a, b)
			end
		end
		return t.ok, t.error
	end)
end

---Checks if value is truthy, in Lua everything is true expect false and nil.
---@type Assertion
local function toBeTruthy(t)
	return compare(t, true, function(a)
		return a
	end)
end

---Checks if value is falsy, false and nil are false in Lua.
---@type Assertion
local function toBeFalsy(t)
	return compare(t, false, function(a)
		return a == false or a == nil
	end)
end

---Checks if value is nil.
---@type Assertion
local function toBeNil(t)
	return compare(t, nil, function(a)
		return a == nil
	end)
end

---Checks if number is finite.
---@type Assertion
local function toBeFinite(t)
	return compare(t, true, function(a)
		return not (a == math.huge or a == -math.huge)
	end)
end

---Checks if number is infinite.
---@type Assertion
local function toBeInfinite(t)
	return compare(t, true, function(a)
		return a == math.huge or a == -math.huge
	end)
end

---Checks  type of a value.
---@type Assertion
local function toHaveTypeOf(t, expected)
	return compare(t, expected, function(a, b)
		t.error = errorx.new(Labels.ErrorAssertion, type(a), b)
		t.error.expectedOperator = t.isNot and ctx.config._negationPrefix or ""
		t.ok = type(a) == b
		return t.ok, t.error
	end)
end

-- ---------------------------------------------------------------------------
-- Length and keys -----------------------------------------------------------
-- ---------------------------------------------------------------------------

---Checks length of a table. It uses # operator, so beware if table is not a sequence.
---For UTF-8 comparison sring, check for config UTF8 flag.
---@type Assertion
local function toHaveLength(t, expected)
	return compare(t, expected, function(a, b)
		local len
		if type(a) == "string" then
			len = ctx.config.UTF8 and utf8.len(a) or string.len(a)
		else
			len = #a
		end
		t.error = errorx.new(Labels.ErrorAssertion, len, b)
		return len == expected, t.error
	end)
end

---Count keys in the table, where key is not nil.
---@type Assertion
local function toHaveKeysLength(t, expected)
	return compare(t, expected, function(a, b)
		local i = 0
		for _ in pairs(a) do
			i = i + 1
		end

		t.ok = i == b
		if not t.ok then
			t.error = errorx.new(Labels.ErrorAssertion, i, b)
		end
		return t.ok, t.error
	end)
end

---Checks a key in the table, where key is not nil.
---@type Assertion
local function toHaveKey(t, expected)
	return compare(t, true, function(a)
		t.ok = a[expected] ~= nil
		local act, exp = true, false
		if not t.ok then
			act, exp = exp, act
		end
		t.error = errorx.new(Labels.ErrorAssertion, act, exp)
		return t.ok, t.error
	end)
end

-- ---------------------------------------------------------------------------
-- Numbers -------------------------------------------------------------------
-- ---------------------------------------------------------------------------

---Checks number is close to another number, useful to compare floats.
---default 2.
---@type Assertion
local function toBeCloseTo(t, expected)
	local n
	local decs = 2
	if type(expected) == "number" then
		n = expected
	else
		n = expected[1]
		decs = expected[2]
	end
	return compare(t, n, function(a)
		local d = mathx.pow(10, -decs) / 2
		local x = math.abs(a - n)
		t.error = errorx.new(Labels.ErrorAssertion, t.actual, t.expected)
		t.error.diffString = table.concat({
			"\t",
			string.format(Labels.Expected.Precision, decs),
			string.format(
				Labels.Expected.Difference,
				Terminal.setColor(Status.Passed),
				d,
				Terminal.resetColor()
			),
			string.format(
				Labels.Actual.Difference,
				Terminal.setColor(Status.Failed),
				x,
				Terminal.resetColor()
			),
		}, "\n")
		return x < d, t.error
	end)
end

---Checks number is greater than expected number.
---@type Assertion
local function toBeGreaterThan(t, expected)
	return compare(t, expected, function(a, b)
		t.error = errorx.new(Labels.ErrorAssertion, a, b)
		t.error.expectedOperator = string.format(
			"%s%s",
			t.isNot and ctx.config._negationPrefix or "",
			"> "
		)
		return a > b, t.error
	end)
end

---Checks number is greater than or equal expected number.
---@type Assertion
local function toBeGreaterThanOrEqual(t, expected)
	return compare(t, expected, function(a, b)
		t.error = errorx.new(t.error.message, a, b)
		t.ErrorExpected = "boo"
		t.error.expectedOperator = string.format(
			"%s%s",
			t.isNot and ctx.config._negationPrefix or "",
			">= s"
		)
		return a >= b, t.error
	end)
end

---Checks number is less than expected number.
---@type Assertion
local function toBeLessThan(t, expected)
	return compare(t, expected, function(a, b)
		t.error = errorx.new(Labels.ErrorAssertion, a, b)
		t.error.expectedOperator = string.format(
			"%s%s",
			t.isNot and ctx.config._negationPrefix or "",
			"< "
		)
		return a < b, t.error
	end)
end

---Checks number is less or equal than expected number.
---@type Assertion
local function toBeLessThanOrEqual(t, expected)
	return compare(t, expected, function(a, b)
		t.error = errorx.new(Labels.ErrorAssertion, a, b)
		t.error.expectedOperator = string.format(
			"%s%s",
			t.isNot and ctx.config._negationPrefix or "",
			"=< "
		)
		return a <= b, t.error
	end)
end

-- ---------------------------------------------------------------------------
-- String --------------------------------------------------------------------
-- ---------------------------------------------------------------------------

---Checks string matches another string with pattern (simplified regexp).
---https://www.lua.org/manual/5.4/manual.html#6.4.1
---@type Assertion
local function toMatch(t, expected)
	return compare(t, expected, function(a, b)
		t.error = errorx.new(Labels.ErrorAssertion, a, b)
		t.ok = string.match(a, b)
		return t.ok ~= nil, t.error
	end)
end

---Checks that string or array contains an element or substring.
---@type Assertion
local function toContain(t, expected)
	return compare(t, expected, function(a, b)
		local isTable = type(a) == "table"
		local isString = type(a) == "string"
		if isTable then
			-- TODO binary search is faster
			for _, elem in ipairs(a) do
				if expected == elem then
					t.ok = true
					break
				end
			end
		elseif isString then
			t.ok = string.match(a, b)
		end

		local act = a
		if isTable then
			act = table.concat(a, ", ") -- TODO better output
		end

		t.error = errorx.new(Labels.ErrorAssertion, act, b)
		if isString then
			t.error.expectedOperator =
				string.format("%s%s", t.isNot and "not " or "", "~")
		end
		return t.ok, t.error
	end)
end

-- ---------------------------------------------------------------------------
-- Errors --------------------------------------------------------------------
-- ---------------------------------------------------------------------------

-- TODO check types for all matchers
---Checks that function is failed, in other words 'throws error'.
---@type Assertion
local function toFail(t, expected)
	return compare(t, expected, function(a, b)
		local ok, err = pcall(a)
		if b ~= nil and type(err) == "string" and not string.match(err, b) then
			ok = true
		end
		local actual = a
		local isPatternMatch = type(b) == "string"

		if type(err) == "string" then
			local matches = stringx.split(err, ":")
			if #matches > 0 then
				local act = stringx.trim(matches[#matches])
				if b ~= nil then
					local s = act:find(b) or 1
					local e = #b
					if s ~= nil and e ~= nil then
						act = string.format(
							"%s%s%s%s",
							act:sub(1, s - 1),
							Terminal.setStyle(
								act:sub(s, s + e - 1),
								Terminal.Style.Reverse
							),
							Terminal.setColor(Status.Failed),
							act:sub(s + e, #act)
						)
					end
				end
				actual = isPatternMatch and act or a
			end
		end

		t.error = errorx.new(err, actual, b)
		t.error.expectedOperator = t.isNot and "not "
		return not ok, t.error
	end)
end

-- ---------------------------------------------------------------------------
-- Spies ---------------------------------------------------------------------
-- ---------------------------------------------------------------------------

---Checks that spy has been called
---@type Assertion
local function toHaveBeenCalled(t)
	return compare(t, 1, function(a)
		local calls = a:getCallsCount()
		t.ok = calls >= 1
		t.error = errorx.new(Labels.ErrorAssertion, calls, 1)
		t.error.expectedOperator = string.format(
			"%s%s",
			t.isNot and ctx.config._negationPrefix or "",
			">= "
		)
		return t.ok, t.error
	end)
end

---Checks that spy has been called once.
---@type Assertion
local function toHaveBeenCalledOnce(t)
	return compare(t, 1, function(a)
		local calls = a:getCallsCount()
		t.ok = calls == 1
		t.error = errorx.new(Labels.ErrorAssertion, calls, 1)
		return t.ok, t.error
	end)
end

---Checks that spy has been called times.
---@type Assertion
local function toHaveBeenCalledTimes(t, expected)
	return compare(t, expected, function(a, b)
		local calls = a:getCallsCount()
		t.ok = calls == expected
		t.error = errorx.new(Labels.ErrorAssertion, calls, b)
		return t.ok, t.error
	end)
end

---Checks that spy has been called with given arguments.
---@type Assertion
local function toHaveBeenCalledWith(t, expected)
	return compare(t, true, function(a, b)
		t.ok = false
		local calls = a:getCalls()
		for _, call in ipairs(calls) do
			for _, x in ipairs(call) do
				if x == expected then
					t.ok = true
					break
				end
			end
		end

		local tmp = {}
		for _, call in ipairs(calls) do
			for _, args in ipairs(call) do
				tmp[#tmp + 1] = tostring(args)
			end
		end
		local act = table.concat(tmp, ", ") -- FIXME better output
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks that last call called with given arguments.
---@type Assertion
local function toHaveBeenLastCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local call = a:getLastCall()
		for _, x in ipairs(call) do
			if x == expected then
				t.ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks that last call called with given arguments.
---@type Assertion
local function toHaveBeenFirstCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local call = a:getFirstCall()
		for _, x in ipairs(call) do
			if x == expected then
				t.ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks that n-th call called with given arguments.
---expected must have the first key is a number of the call,
---second argument is an argument's value.
---@type Assertion
local function toHaveBeenNthCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local call = a:getCall(expected[1])
		for _, x in ipairs(call) do
			if x == expected[2] then
				t.ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks that spy has returned, and return value is not nil.
---@type Assertion
local function toHaveReturned(t, expected)
	return compare(t, expected, function(a)
		t.ok = false
		local calls = a:getCalls()
		for _, call in ipairs(calls) do
			for _, x in ipairs(call) do
				t.ok = type(x) == "function" and x() ~= nil
				if t.ok then
					break
				end
			end
		end

		t.error = errorx.new(Labels.ErrorAssertion, #calls, 1)
		t.error.expectedOperator = string.format(
			"%s%s",
			t.isNot and ctx.config._negationPrefix or "",
			">= "
		)

		return t.ok, t.error
	end)
end

---Checks that spy has returned n times, and return value is not nil.
---@type Assertion
local function toHaveReturnedTimes(t, expected)
	return compare(t, expected, function(a, b)
		local i = 0
		local calls = a:getCalls()
		for _, call in ipairs(calls) do
			for _, x in ipairs(call) do
				if type(x) == "function" and x() ~= nil then
					i = i + 1
				end
			end
		end
		t.ok = i == expected
		t.error = errorx.new(Labels.ErrorAssertion, #calls, b)
		return t.ok, t.error
	end)
end

---Checks that spy has returned with argument
---@type Assertion
local function toHaveReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local calls = a:getCalls()
		for _, call in ipairs(calls) do
			for _, x in ipairs(call) do
				if x == expected then
					t.ok = true
					break
				end
			end
		end

		local tmp = {}
		for _, call in ipairs(calls) do
			for _, args in ipairs(call) do
				tmp[#tmp + 1] = tostring(args)
			end
		end
		local act = table.concat(tmp, ", ") -- FIXME better output
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks the last call of the spy has returned with argument.
---@type Assertion
local function toHaveLastReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local call = a:getLastCall(expected)
		for _, x in ipairs(call) do
			if x == expected then
				t.ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks the first call of the spy has returned with argument.
---@type Assertion
local function toHaveFirstReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local call = a:getFirstCall(expected)
		for _, x in ipairs(call) do
			if x == expected then
				t.ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		t.error = errorx.new(Labels.ErrorAssertion, act, b)

		return t.ok, t.error
	end)
end

---Checks N-th first call of the spy has returned with argument.
---@type Assertion
local function toHaveNthReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		t.ok = false
		local call = a:getCall(expected[1])
		for _, x in ipairs(call) do
			if x == expected[2] then
				t.ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		t.error = errorx.new(Labels.ErrorAssertion, act, b[2])

		return t.ok, t.error
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
	toBeCloseTo = toBeCloseTo,
	toBeGreaterThan = toBeGreaterThan,
	toBeGreaterThanOrEqual = toBeGreaterThanOrEqual,
	toBeLessThan = toBeLessThan,
	toBeLessThanOrEqual = toBeLessThanOrEqual,
	toMatch = toMatch,
	toContain = toContain,
	toFail = toFail,
	toHaveTypeOf = toHaveTypeOf,
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

-- create negative matchers
-- spairs() is required here to be sure that functions are always in the
-- sorted order. Using pairs() iterator might cause random error.
for key, matcher in helpers.spairs(matchers) do
	local firstCap = key:sub(1, 1):upper()
	local rest = key:sub(2)
	local negKey = table.concat({ "not", firstCap, rest })
	matchers[negKey] = matcher
end

return matchers
