---@alias Context {level: number,tests: Runnable[]}

local config = require("config")

---Creates new app context.
---@return Context
local function new()
	return {
		level = 0,
		tests = {},
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
