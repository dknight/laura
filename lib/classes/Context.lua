local constants = require("lib.util.constants")

---@class Context
---@field public level number
---@field public tests Runnable[]
---@field public config {[string]: any}
local Context = {}

---Creates new app context.
---@return Context
function Context.new()
	return {
		level = 0,
		tests = {},
		config = {},
	}
end

---Returns the app contenxt. If context non-exists in global scope _G, then
---creates a new context in _G.
---@return Context
function Context.global()
	_G[constants.appKey] = _G[constants.appKey] or Context.new()
	return _G[constants.appKey]
end

return Context
