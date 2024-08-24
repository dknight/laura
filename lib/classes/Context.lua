local config = require("config")

---@class Context
---@field public level number
---@field public tests Runnable[]
local Context = {}

---Creates new app context.
---@return Context
function Context.new()
	return {
		level = 0,
		tests = {},
	}
end

---Returns the app contenxt. If context non-exists in global scope _G, then
---creates a new context in _G.
---@return Context
function Context.global()
	_G[config.appKey] = _G[config.appKey] or Context.new()
	return _G[config.appKey]
end

return Context
