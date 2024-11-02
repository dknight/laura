---@class Context
---@field public children Runnable[]
---@field public config {[string]: any}
---@field public coverage? Coverage
---@field public current? Runnable
---@field public level number
---@field public parent? Runnable
---@field public root? Runnable
---@field public suites Runnable[]
local Context = {}

---@return Context
Context.new = function()
	return {
		children = {},
		config = {},
		current = nil,
		level = 0,
		parent = nil,
		root = nil,
		suites = {},
		coverage = nil,
	}
end

---Returns the app contenxt. If context non-exists in global scope _G, then
---creates a new context in _G.
---@return Context
Context.global = function()
	local key = "__LAURA_CONTEXT__"
	_G[key] = _G[key] or Context.new()
	return _G[key]
end

return Context
