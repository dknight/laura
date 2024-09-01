local constants = require("lib.util.constants")

---@class Context
---@field public children Runnable[]
---@field public config {[string]: any}
---@field public current Runnable
---@field public level number
---@field public onlyTests Runnable[]
---@field public parent? Runnable
---@field public root? Runnable
---@field public suites Runnable[]
---@field public suitesLevels Runnable[]
---@field public tests Runnable[]
local Context = {}

---Creates new app context.
---@return Context
function Context.new()
	return {
		children = {},
		config = {},
		level = 0,
		onlyTests = {},
		parent = nil,
		root = nil,
		suites = {},
		suitesLevels = {},
		tests = {},
		current = nil,
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
