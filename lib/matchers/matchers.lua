---@alias MatchResult {actual: any, err: Error, ok: boolean, isNot: boolean, [string]: function}

local errorx = require("lib.ext.errorx")
local Labels = require("lib.Labels")
local tablex = require("lib.ext.tablex")
local helpers = require("lib.util.helpers")

---Checks the equality of actual and expected. This don't use deep comparison for tables.
---For tables use toDeepEqual method.
---@param t table
---@param expected any
---@return MatchResult
local function toEqual(t, expected)
	t.ok = t.actual == expected
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, t.actual, expected)
	end
	return t(expected)
end

---Checks the deep equality of actual and expected.
---@param t table
---@param expected any
---@return MatchResult
local function toDeepEqual(t, expected)
	t.ok = true
	if t.actual == expected then
		t.ok = false
	end

	if type(t.actual) ~= type(expected) then
		t.ok = false
	end

	if type(t.actual) == "table" and not tablex.equal(t.actual, expected) then
		t.ok = false
	end

	if not t.ok then
		local diff, count = tablex.diff(t.actual, expected)
		t.err = errorx.new(
			Labels.ErrorAssertion,
			count.added,
			count.removed,
			nil,
			tablex.print(t.actual, diff, 1)
		)
	end
	return t(expected)
end

---Checks if value is truthy, in Lua everything is true expect false and nil.
---@param t table
---@return MatchResult
local function toBeTruthy(t)
	t.ok = not not t.actual
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, true, t.actual)
	end
	return t()
end

---Checks if value is falsy, false and nil are false in Lua.
---@param t table
---@return MatchResult
local function toBeFalsy(t)
	t.ok = t.actual == false or t.actual == nil
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, false, t.actual)
	end
	return t()
end

---Checks if value is nil.
---@param t table
---@return MatchResult
local function toBeNil(t)
	t.ok = t.actual == nil
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, nil, t.actual)
	end
	return t()
end

---Checks if number is finite.
---@param t table
---@return MatchResult
local function toBeFinite(t)
	t.ok = not (t.actual == math.huge or t.actual == -math.huge)
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, true, t.ok)
	end
	return t()
end

---Checks if number is infinite.
---@param t table
---@return MatchResult
local function toBeInfinite(t)
	t.ok = t.actual == math.huge or t.actual == -math.huge
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, true, t.ok)
	end
	return t()
end

local matchers = {
	toBeNil = toBeNil,
	toBeFalsy = toBeFalsy,
	toBeTruthy = toBeTruthy,
	toDeepEqual = toDeepEqual,
	toEqual = toEqual,
	toBeFinite = toBeFinite,
	toBeInfinite = toBeInfinite,
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
