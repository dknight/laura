---A very simple stub implementataion.
---@class Stub
---@field private key any
---@field private orig table
---@field private old any
local Stub = {}
Stub.__index = Stub

---@param o table
---@param key string
---@param stub any
---@return Stub
function Stub:new(o, key, stub)
	local t = {
		orig = o,
		old = o[key],
		key = key,
	}
	t.orig[key] = stub
	return setmetatable(t, self)
end

---Restores the original.
function Stub:restore()
	self.orig[self.key] = self.old
	self.old = nil
end

return Stub
