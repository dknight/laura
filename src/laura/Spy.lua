---@alias SpyArgs table
---@alias SpyCall table
---@alias SpyReturn table

---Very basic spy implementation.
---@class Spy
---@field private _args SpyArgs
---@field private _calls SpyCall
---@field private _returns SpyReturn
local Spy = {}

---@return Spy
function Spy:new()
	local t = {
		_args = {},
		_calls = {},
		_returns = {},
	}

	return setmetatable(t, {
		__index = self,
		__call = function(_, ...)
			local args = { ... }
			t._args = args
			t._calls[#t._calls + 1] = args
			if type(args[1]) == "function" then
				local ret = args[1]()
				if ret ~= nil then
					t._returns[#t._returns + 1] = { ret }
				end
				return ret
			end
		end,
	})
end

---Gets the call stack.
---@return SpyCall[]
function Spy:getCalls()
	return self._calls
end

---Gets calls number 'n' from the call stack.
---@param n number
---@return SpyCall | nil
function Spy:getCall(n)
	return self._calls[n]
end

---Gets the first call from the call stack.
---@return SpyCall | nil
function Spy:getFirstCall()
	return self._calls[1]
end

---Gets the last call from the call stack.
---@return SpyCall | nil
function Spy:getLastCall()
	return self._calls[#self._calls]
end

---Gets an amount of total the calls.
---@return number
function Spy:getCallsCount()
	return #self._calls
end

---Gets the returns stack.
---@return table
function Spy:getReturns()
	return self._returns
end

---Gets return number 'n' from the return stack.
---@param n number
---@return SpyReturn | nil
function Spy:getReturn(n)
	return self._returns[n]
end

---Gets the first return from the return stack.
---@return SpyReturn | nil
function Spy:getFirstReturn()
	return self._returns[1]
end

---Gets the last return from the return stack.
---@return SpyReturn | nil
function Spy:getLastReturn()
	return self._returns[#self._returns]
end

---Gets an amount of total the returns that are not nil.
---@return number
function Spy:getReturnsCount()
	return #self._returns
end

return Spy
