---@alias HookType
---| "afterAll"
---| "afterEach"
---| "beforeAll"
---| "beforeEach"

local Context = require("laura.Context")
local errorx = require("laura.ext.errorx")
local Labels = require("laura.Labels")

---@class Hook
---@field func function | Hook
---@field name string
---@field type HookType
---@field protected ctx Context
local Hook = {
	ctx = Context.global(),
}

---@param name? string
---@param typ HookType
---@return fun(func: function | Hook)
function Hook:new(typ, name)
	local localName = name or typ
	return function(func)
		if not Hook.ctx.current then
			error(errorx.new({ title = Labels.UnknownContext }))
		end
		table.insert(Hook.ctx.current.hooks[typ], {
			name = localName,
			func = func,
			type = typ,
			ctx = Hook.ctx,
		} --[[@as Hook]])
	end
end

return Hook
