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
local Version = require("lib.Version")

local ctx = Context.global()

---@type Assertion
local function compare(t, expected, cmp)
	t.expected = expected
	t.ok, t.error = cmp(t.actual, t.expected)

	-- default error
	if not t.error then
		t.error = errorx.new({ actual = t.actual, expected = expected })
	end

	-- create negation
	if t.isNot then
		t.error.expectedOperator = ctx.config._negationPrefix
			.. " "
			.. t.error.expectedOperator
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
		local ok = true
		local err
		if type(a) ~= type(b) then
			ok = false
		end

		if areBothTables then
			ok = tablex.equal(a, b)
		else
			ok = a == b
		end

		if not ok then
			if areBothTables then
				local diff, count = tablex.diff(a, b)
				err = errorx.new({
					added = count.added,
					expected = count.removed,
					message = tablex.diffToString(a, diff, 1),
				})
			else
				err = errorx.new({ actual = a, expected = b })
			end
		end
		return ok, err
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
	return compare(t, ctx.config._rationalSet, function(a)
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
		return type(a) == b, errorx.new({ actual = type(a), expected = b })
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
		local isString = type(a) == "string"
		local len = isString and stringx.len(a, ctx.config.UTF8) or #a
		return len == expected,
			errorx.new({
				actual = len,
				expected = b,
				message = string.format(
					"\n%s%s%s%s%s\n",
					helpers.tab(1),
					isString and Labels.Actual.String or Labels.Actual.Table,
					Terminal.setColor(Status.Failed),
					isString and a or tablex.inline(a),
					Terminal.reset()
				),
			})
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
		return i == b,
			errorx.new({
				actual = i,
				expected = b,
				message = string.format(
					"\n%s%s%s%s%s\n",
					helpers.tab(1),
					Labels.Actual.Table,
					Terminal.setColor(Status.Failed),
					tablex.inline(a, true),
					Terminal.reset()
				),
			})
	end)
end

---Checks a key in the table, where key is not nil.
---@type Assertion
local function toHaveKey(t, expected)
	return compare(t, expected, function(a, b)
		return a[expected] ~= nil,
			errorx.new({
				actual = a,
				expected = b,
				expectedLabel = Labels.Expected.Key,
				actualLabel = Labels.Actual.Table,
			})
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
	return compare(t, n, function(a, b)
		local d = mathx.pow(10, -decs) / 2
		local x = math.abs(a - n)
		return x < d,
			errorx.new({
				actual = a,
				expected = b,
				message = table.concat({
					helpers.tab(1),
					string.format(Labels.Expected.Precision, decs),
					string.format(
						Labels.Expected.Difference,
						Terminal.setColor(Status.Passed),
						d,
						Terminal.reset()
					),
					string.format(
						Labels.Actual.Difference,
						Terminal.setColor(Status.Failed),
						x,
						Terminal.reset()
					),
					"",
				}, "\n"),
			})
	end)
end

---Checks number is greater than expected number.
---@type Assertion
local function toBeGreaterThan(t, expected)
	return compare(t, expected, function(a, b)
		return a > b,
			errorx.new({
				actual = a,
				expected = b,
				expectedOperator = "> ",
			})
	end)
end

---Checks number is greater than or equal expected number.
---@type Assertion
local function toBeGreaterThanOrEqual(t, expected)
	return compare(t, expected, function(a, b)
		return a >= b,
			errorx.new({
				actual = a,
				expected = b,
				expectedOperator = ">= ",
			})
	end)
end

---Checks number is less than expected number.
---@type Assertion
local function toBeLessThan(t, expected)
	return compare(t, expected, function(a, b)
		return a < b,
			errorx.new({
				actual = a,
				expected = b,
				expectedOperator = "< ",
			})
	end)
end

---Checks number is less or equal than expected number.
---@type Assertion
local function toBeLessThanOrEqual(t, expected)
	return compare(t, expected, function(a, b)
		return a <= b,
			errorx.new({
				actual = a,
				expected = b,
				expectedOperator = "=< ",
			})
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
		return string.match(a, b) ~= nil,
			errorx.new({
				actual = a,
				expected = b,
				actualLabel = Labels.Actual.Pattern,
				expectedLabel = Labels.Expected.Pattern,
			})
	end)
end

---Checks that string or array contains an element or substring.
---@type Assertion
local function toContain(t, expected)
	return compare(t, expected, function(a, b)
		local isTable = type(a) == "table"
		local isString = type(a) == "string"
		local ok = false
		if isTable then
			-- TODO binary search is faster
			for _, elem in ipairs(a) do
				if expected == elem then
					ok = true
					break
				end
			end
		elseif isString then
			ok = not not string.match(a, b)
		end

		return ok,
			errorx.new({
				actual = a,
				expected = b,
				actualLabel = isString and Labels.Actual.Pattern
					or Labels.ErrorActual,
				expectedLabel = isString and Labels.Expected.Pattern
					or Labels.ErrorExpected,
			})
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
		--COMPAT %s in string.format() requires tostring(v)
		if Version[_VERSION] <= Version["Lua 5.2"] then
			actual = tostring(actual)
		end
		local e = errorx.new({
			actual = string.format("%s %s", actual, Labels.Actual.FnFail),
			expected = string.format("%s %s", actual, Labels.Expected.FnFail),
		})

		--- TODO not only string probably
		if type(err) == "string" then
			local act = err
			local matches = stringx.split(err, ":")
			if #matches > 0 then
				act = stringx.trim(matches[#matches])
			end
			e.actualLabel = Labels.Actual.Pattern
			e.expectedLabel = Labels.Expected.Pattern
			e.actual = act
			e.expected = b
		end
		return not ok, e
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
		return calls >= 1,
			errorx.new({
				actual = calls,
				expected = 1,
				expectedOperator = ">= ",
				actualLabel = Labels.Actual.Calls,
				expectedLabel = Labels.Expected.Calls,
			})
	end)
end

---Checks that spy has been called once.
---@type Assertion
local function toHaveBeenCalledOnce(t)
	return compare(t, 1, function(a)
		local calls = a:getCallsCount()
		return calls == 1,
			errorx.new({
				actual = calls,
				expected = 1,
				actualLabel = Labels.Actual.Calls,
				expectedLabel = Labels.Expected.Calls,
			})
	end)
end

---Checks that spy has been called times.
---@type Assertion
local function toHaveBeenCalledTimes(t, expected)
	return compare(t, expected, function(a, b)
		local calls = a:getCallsCount()
		return calls == expected,
			errorx.new({
				actual = calls,
				expected = b,
				actualLabel = Labels.Actual.Calls,
				expectedLabel = Labels.Expected.Calls,
			})
	end)
end

---Checks that spy has been called with given arguments.
---@type Assertion
local function toHaveBeenCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local calls = a:getCalls()
		for _, call in ipairs(calls) do
			for _, x in ipairs(call) do
				if x == expected then
					ok = true
					break
				end
			end
		end

		local tmp = {}
		for _, call in ipairs(calls) do
			for _, x in ipairs(call) do
				tmp[#tmp + 1] = x
			end
		end
		if #tmp == 1 then
			tmp = tmp[1]
		end

		return ok,
			errorx.new({
				actual = tmp,
				expected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfCalls,
					#calls
				),
			})
	end)
end

---Checks that last call called with given arguments.
---@type Assertion
local function toHaveBeenLastCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local call = a:getLastCall()
		for _, x in ipairs(call) do
			if x == expected then
				ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		return ok,
			errorx.new({
				actual = act,
				expected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfCalls,
					a:getCallsCount()
				),
			})
	end)
end

---Checks that last call called with given arguments.
---@type Assertion
local function toHaveBeenFirstCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local call = a:getFirstCall()
		for _, x in ipairs(call) do
			if x == expected then
				ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)
		return ok,
			errorx.new({
				actual = act,
				expected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfCalls,
					a:getCallsCount()
				),
			})
	end)
end

---Checks that n-th call called with given arguments.
---expected must have the first key is a number of the call,
---second argument is an argument's value.
---@type Assertion
local function toHaveBeenNthCalledWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local call = a:getCall(expected[1])
		for _, x in ipairs(call) do
			if x == expected[2] then
				ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(call) do
			tmp[#tmp + 1] = call[i]
		end
		local act = table.concat(tmp)

		return ok,
			errorx.new({
				actual = act,
				expected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfCalls,
					a:getCallsCount()
				),
			})
	end)
end

---Checks that spy has returned, and return value is not nil.
---@type Assertion
local function toHaveReturned(t, expected)
	return compare(t, expected, function(a)
		return #a:getReturns() > 0,
			errorx.new({
				actual = a:getReturnsCount(),
				expected = 1,
				expectedOperator = ">= ",
				actualLabel = Labels.Actual.Returns,
				expectedLabel = Labels.Expected.Returns,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfReturns,
					a:getReturnsCount()
				),
			})
	end)
end

---Checks that spy has returned n times, and return value is not nil.
---@type Assertion
local function toHaveReturnedTimes(t, expected)
	return compare(t, expected, function(a, b)
		local count = a:getReturnsCount()
		return count == expected,
			errorx.new({
				actual = count,
				expected = b,
				actualLabel = Labels.Actual.Returns,
				expectedLabel = Labels.Expected.Returns,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfReturns,
					count
				),
			})
	end)
end

---Checks that spy has returned with argument
---@type Assertion
local function toHaveReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local rets = a:getReturns()
		for _, ret in ipairs(rets) do
			for _, x in ipairs(ret) do
				if x == expected then
					ok = true
					break
				end
			end
		end

		local tmp = {}
		for i in ipairs(rets) do
			for j in ipairs(rets[i]) do
				tmp[#tmp + 1] = rets[i][j]
			end
		end
		if #tmp == 1 then
			tmp = tmp[1]
		end

		return ok,
			errorx.new({
				actual = tmp,
				expected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfReturns,
					a:getReturnsCount()
				),
			})
	end)
end

---Checks the last call of the spy has returned with argument.
---@type Assertion
local function toHaveLastReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local ret = a:getLastReturn(expected)
		for _, x in ipairs(ret) do
			if x == expected then
				ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(ret) do
			tmp[#tmp + 1] = ret[i]
		end
		if #tmp == 1 then
			tmp = tmp[1]
		end

		return ok,
			errorx.new({
				actual = tmp,
				sexpected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfReturns,
					a:getReturnsCount()
				),
			})
	end)
end

---Checks the first call of the spy has returned with argument.
---@type Assertion
local function toHaveFirstReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local ret = a:getFirstReturn(expected)
		for _, x in ipairs(ret) do
			if x == expected then
				ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(ret) do
			tmp[#tmp + 1] = ret[i]
		end
		if #tmp == 1 then
			tmp = tmp[1]
		end
		return ok,
			errorx.new({
				actual = tmp,
				expected = b,
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfReturns,
					a:getReturnsCount()
				),
			})
	end)
end

---Checks N-th first call of the spy has returned with argument.
---@type Assertion
local function toHaveNthReturnedWith(t, expected)
	return compare(t, expected, function(a, b)
		local ok = false
		local ret = a:getReturn(expected[1])
		for _, x in ipairs(ret) do
			if x == expected[2] then
				ok = true
				break
			end
		end

		local tmp = {}
		for i in ipairs(ret) do
			tmp[#tmp + 1] = ret[i]
		end
		if #tmp == 1 then
			tmp = tmp[1]
		end

		return ok,
			errorx.new({
				actual = tmp,
				expected = b[2],
				message = string.format(
					"\n%s%s%d\n",
					helpers.tab(1),
					Labels.NumberOfReturns,
					a:getReturnsCount()
				),
			})
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
