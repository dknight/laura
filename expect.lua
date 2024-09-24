local bind = require("lib.util.bind")
local Context = require("lib.Context")
local errorx = require("lib.ext.errorx")
local matchers = require("lib.matchers")

local ctx = Context.global()

---@param actual any
---@return MatchResult
local createResult = function(actual)
	local t = {
		actual = actual,
		error = nil,
		expected = nil,
		isNot = false,
		ok = false,
	}
	return setmetatable(t, {
		__call = function()
			--COMPAT
			--  assert(v, [, message]) - for some lua versions message expected
			--  to be only string, not table.
			-- assert(t.isNot ~= t.ok, t.error)

			if t.isNot == t.ok then
				error(t.error)
			end
		end,
	})
end

---Expects value to be tested with matcher.
---@param actual any
---@return table
local function expect(actual)
	local ms = {}
	for key, matcher in pairs(matchers) do
		local t2 = createResult(actual)
		t2.isNot = key:sub(1, 3) == ctx.config._negationPrefix
		t2.error = errorx.new({
			actual = actual,
			expected = actual,
			expectedOperator = ctx.config._negationPrefix .. " ",
		})
		ms[key] = bind(matcher, t2)
	end

	local t = createResult(actual)
	for key in pairs(matchers) do
		t[key] = ms[key]
	end

	return t
end

return expect
