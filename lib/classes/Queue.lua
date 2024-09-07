---@class Queue
---@field private _first number
---@field private _last number
---@field private _size number
local Queue = {}
Queue.__index = Queue

---@return Queue
function Queue:new()
	local t = {
		_first = 0,
		_last = -1,
		_size = 0,
	}
	return setmetatable(t, self)
end

---@param v any
function Queue:enqueue(v)
	local last = self._last + 1
	self._last = last
	self[last] = v
	self._size = self._size + 1
end

---@return any
function Queue:dequeue()
	if self:isEmpty() then
		return nil
	end
	local first = self._first
	local v = self[first]
	self[first] = nil -- garbage collection removes it
	self._first = self._first + 1
	self._size = self._size - 1
	return v
end

---@return boolean
function Queue:isEmpty()
	return self._first > self._last
end

---@return any
function Queue:front()
	return self[self._first]
end

---@return any
function Queue:rear()
	return self[self._last]
end

---@return number
function Queue:size()
	return self._size
end

---@params sep? string
---@return string
function Queue:toString(sep)
	sep = sep or ","
	local t = {}
	for i = self._first, self._last do
		t[#t + 1] = tostring(self[i])
	end
	return table.concat(t, sep)
end

return Queue
