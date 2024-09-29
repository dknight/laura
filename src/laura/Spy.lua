---@alias SpyArgs table
---@alias SpyCall table
---@alias SpyReturn table

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

---@return SpyCall[]
function Spy:getCalls()
	return self._calls
end

---@param n number
---@return SpyCall | nil
function Spy:getCall(n)
	return self._calls[n]
end

---@return SpyCall | nil
function Spy:getFirstCall()
	return self._calls[1]
end

---@return SpyCall | nil
function Spy:getLastCall()
	return self._calls[#self._calls]
end

---@return number
function Spy:getCallsCount()
	return #self._calls
end

---@return table
function Spy:getReturns()
	return self._returns
end

---@param n number
---@return SpyReturn | nil
function Spy:getReturn(n)
	return self._returns[n]
end

---@return SpyReturn | nil
function Spy:getFirstReturn()
	return self._returns[1]
end

---@return SpyReturn | nil
function Spy:getLastReturn()
	return self._returns[#self._returns]
end

---@return number
function Spy:getReturnsCount()
	return #self._returns
end

return Spy
