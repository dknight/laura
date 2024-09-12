---@alias MatchResult {a: any, err: Error, ok: boolean}

local errorx = require("lib.ext.errorx")
local Labels = require("lib.Labels")
local tablex = require("lib.ext.tablex")

---Checks the equality of a and b. This don't use deep comparison for tables.
---For tables use toDeepEqual method.
---@param t table
---@param b any
---@return MatchResult
local function toEqual(t, b)
	t.ok = t.a == b
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, t.a, b)
	end
	return t(b)
end

---Checks the deep equality of a and b.
---@param t table
---@param b any
---@return MatchResult
local function toDeepEqual(t, b)
	t.ok = true
	if t.a == b then
		t.ok = false
	end

	if type(t.a) ~= type(b) then
		t.ok = false
	end

	if type(t.a) == "table" and not tablex.equal(t.a, b) then
		t.ok = false
	end

	if not t.ok then
		local diff, count = tablex.diff(t.a, b)
		t.err = errorx.new(
			Labels.ErrorAssertion,
			count.added,
			count.removed,
			nil,
			tablex.print(t.a, diff, 1)
		)
	end
	return t(b)
end

---Checks if value is truthy, in Lua everything is true expect false and nil.
---@param t table
---@return MatchResult
local function toBeTruthy(t)
	t.ok = not not t.a
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, true, t.a)
	end
	return t()
end

---Checks if value is falsy, false and nil are false in Lua.
---@param t table
---@return MatchResult
local function toBeFalsy(t)
	t.ok = t.a == false or t.a == nil
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, false, t.a)
	end
	return t()
end

---Checks if value is nil.
---@param t table
---@return MatchResult
local function toBeNil(t)
	t.ok = t.a == nil
	if not t.ok then
		t.err = errorx.new(Labels.ErrorAssertion, nil, t.a)
	end
	return t()
end

---Checks if number is finite.
---@param t table
---@return MatchResult
local function toBeFinite(t)
	t.ok = not (t.a == math.huge or t.a == -math.huge)
	if not t.ok then
		t.err = errorx.new("number is infinite", true, math.huge)
	end
	return t()
end

---Checks if number is infinite.
---@param t table
---@return MatchResult
local function toBeInfinite(t)
	t.ok = t.a == math.huge or t.a == -math.huge
	if not t.ok then
		t.err = errorx.new("number is finite", true, math.huge)
	end
	return t()
end

return {
	toBe = toDeepEqual, -- alias toDeepEqual
	toBeNil = toBeNil,
	toBeFalsy = toBeFalsy,
	toBeTruthy = toBeTruthy,
	toDeepEqual = toDeepEqual,
	toEqual = toEqual,
	toBeFinite = toBeFinite,
	toBeInfinite = toBeInfinite,
}
