---@alias Context {errors: Error[], failed: number, level: number, passed: number, skipped: number, total: number}

local config = require("config")

---Creates new app context.
---@return Context
local function new()
	return {
		errors = {},
		failed = 0,
		level = 0,
		passed = 0,
		skipped = 0,
		total = 0,
	}
end

---Returns the app contenxt. If context non-exists in global scope _G, then
---creates a new context in _G.
---@return Context
local function global()
	_G[config.appKey] = _G[config.appKey] or new()
	return _G[config.appKey]
end

return {
	global = global,
	new = new,
}
