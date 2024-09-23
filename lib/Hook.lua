---@alias HookType
---| "afterAll"
---| "afterEach"
---| "beforeAll"
---| "beforeEach"

local Context = require("lib.Context")
local errorx = require("lib.ext.errorx")
local Labels = require("lib.Labels")

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
