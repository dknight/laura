local key = require("laura.key")

---@class Context
---@field public children Runnable[]
---@field public config {[string]: any}
---@field public current? Runnable
---@field public level number
---@field public parent? Runnable
---@field public root? Runnable
---@field public suites Runnable[]
local Context = {}

---Creates new app context.
---@return Context
function Context.new()
	return {
		children = {},
		config = {},
		current = nil,
		level = 0,
		parent = nil,
		root = nil,
		suites = {},
	}
end

---Returns the app contenxt. If context non-exists in global scope _G, then
---creates a new context in _G.
---@return Context
function Context.global()
	_G[key] = _G[key] or Context.new()
	return _G[key]
end

return Context
