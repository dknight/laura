local bind = require("lib.util.bind")
local matchers = require("lib.matchers.matchers")
local errorx = require("lib.ext.errorx")
local Labels = require("lib.Labels")

---@param actual any
---@return MatchResult
local createResult = function(actual)
	local t = {
		actual = actual,
		ok = false,
		err = errorx.new(
			Labels.ErrorAssertion,
			actual,
			string.format("%s %s", Labels.Not, actual)
		),
		isNot = false,
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
		local t = createResult(actual)
		t.isNot = key:sub(1, 3) == "not"
		ms[key] = bind(matcher, t)
	end

	local t = createResult(actual)
	for key in pairs(matchers) do
		t[key] = ms[key]
	end

	return t
end

return expect
