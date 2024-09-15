---Very basic spy implementation.
---@class Spy
---@field private _calls table
---@field private _args table
local Spy = {}

---@return Spy
function Spy:new()
	local t = {
		_calls = {},
		_args = {},
	}

	return setmetatable(t, {
		__index = self,
		__call = function(_, ...)
			local args = { ... }
			t._args = args
			t._calls[#t._calls + 1] = args
			if type(args[1]) == "function" then
				return args[1]()
			end
		end,
	})
end

---Gets the call stack.
---@return table
function Spy:getCalls()
	return self._calls
end

---Gets calls number 'n' from the call stack.
---@param n number
---@return any
function Spy:getCall(n)
	return self._calls[n]
end

---Gets the first call from the call stack.
---@return any
function Spy:getFirstCall()
	return self._calls[1]
end

---Gets the last call from the call stack.
---@return any
function Spy:getLastCall()
	return self._calls[#self._calls]
end

---Gets an amount of total the calls.
---@return number
function Spy:getCallsCount()
	return #self._calls
end

return Spy
