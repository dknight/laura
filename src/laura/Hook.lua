---@alias HookType
---| "afterAll"
---| "afterEach"
---| "beforeAll"
---| "beforeEach"

local Context = require("laura.Context")
local errorx = require("laura.ext.errorx")
local Labels = require("laura.Labels")

local ctx = Context.global()

---@class Hook
---@field func function | Hook
---@field name string
---@field type HookType
local Hook = {}

---@param name? string
---@param typ HookType
---@return fun(func: function | Hook)
Hook.new = function(typ, name)
	local localName = name or typ
	return function(func)
		if not ctx.current then
			error(errorx.new({ title = Labels.UnknownContext }))
		end
		table.insert(ctx.current.hooks[typ], {
			name = localName,
			func = func,
			type = typ,
		} --[[@as Hook]])
	end
end

return Hook
