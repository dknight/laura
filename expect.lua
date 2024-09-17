local bind = require("lib.util.bind")
local Context = require("lib.Context")
local errorx = require("lib.ext.errorx")
local Labels = require("lib.Labels")
local matchers = require("lib.matchers")

local ctx = Context.global()

---@param actual any
---@return MatchResult
local createResult = function(actual)
	local t = {
		actual = actual,
		err = {},
		expected = nil,
		isNot = false,
		ok = false,
	}
	return setmetatable(t, {
		__call = function()
			assert(t.isNot ~= t.ok, t.err)
		end,
	})
end

---Expects value to be tested with matcher.
---@param actual any
---@return table
local function expect(actual)
	local ms = {}
	for key, matcher in pairs(matchers) do
		local fmt = errorx.resolveQualifier(actual)
		local t2 = createResult(actual)
		t2.isNot = key:sub(1, 3) == ctx.config._negationPrefix
		t2.err = errorx.new(
			Labels.ErrorAssertion,
			string.format(fmt, actual),
			string.format(fmt, actual)
		)
		t2.err.expectedOperator = Labels.Not
		ms[key] = bind(matcher, t2)
	end

	local t = createResult(actual)
	for key in pairs(matchers) do
		t[key] = ms[key]
	end

	return t
end

return expect
