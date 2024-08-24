---@alias MatchResult {a: any, err: Error, ok: boolean}

local errorx = require("lib.ext.errorx")
local labels = require("lib.labels")
local tablex = require("lib.ext.tablex")

local matchers = {}

---Checks the equality of a and b. This don't use deep comparison for tables.
---For tables use toDeepEqual method.
---@param t table
---@param b any
---@return MatchResult
matchers.toEqual = function(t, b)
	t.ok = t.a == b
	if not t.ok then
		t.err = errorx.new(labels.errorAssertion, t.a, b)
	end
	return t(b)
end

---Checks the deep equality of a and b.
---@param t table
---@param b any
---@return MatchResult
matchers.toDeepEqual = function(t, b)
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
			labels.errorAssertion,
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
matchers.toBeTruthy = function(t)
	t.ok = not not t.a
	if not t.ok then
		t.err = errorx.new(labels.errorAssertion, true, t.a)
	end
	return t()
end

---Checks if value is falsy, false and nil are false in Lua.
---@param t table
---@return MatchResult
matchers.toBeFalsy = function(t)
	t.ok = t.a == false or t.a == nil
	if not t.ok then
		t.err = errorx.new(labels.errorAssertion, false, t.a)
	end
	return t()
end

---Checks if value is nil.
---@param t table
---@return MatchResult
matchers.toBeNil = function(t)
	t.ok = t.a == nil
	if not t.ok then
		t.err = errorx.new(labels.errorAssertion, nil, t.a)
	end
	return t()
end

return matchers
