local bind = require("lib.util.bind")
local matchers = require("lib.matchers.matchers")

---Expects value to be tested with matcher.
---@param a any
---@return table
local function expect(a)
	local t = {
		a = a,
		ok = false,
		err = {},
	}

	t.toEqual = bind(matchers.toEqual, t)
	t.toDeepEqual = bind(matchers.toDeepEqual, t)
	t.toBeTruthy = bind(matchers.toBeTruthy, t)
	t.toBeFalsy = bind(matchers.toBeFalsy, t)
	t.toBeNil = bind(matchers.toBeNil, t)

	return setmetatable(t, {
		__call = function()
			if not t.ok then
				error(t.err)
			end
		end,
	})
end

return expect
