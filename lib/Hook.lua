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
---@field func function
---@field name string
---@field type HookType
local Hook = {}

---@param typ HookType
---@param name? string
---@return fun(func: function)
Hook.new = function(typ, name)
	local localName = name or typ
	return function(func)
		if type(func) ~= "function" then
			error(
				errorx.new(Labels.ErrorHookNotFunction, type(func), "function")
			)
		end
		if not ctx.current then
			error(errorx.new(Labels.unknownContext))
		end
		table.insert(ctx.current.hooks[typ], {
			name = localName,
			func = func,
			type = typ,
		} --[[@as Hook]])
	end
end

return Hook
