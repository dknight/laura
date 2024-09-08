---@alias HookType
---| "afterAll"
---| "afterEach"
---| "beforeAll"
---| "beforeEach"

local Context = require("lib.classes.Context")
local errorx = require("lib.ext.errorx")
local labels = require("lib.labels")

local ctx = Context.global()

---@class Hook
---@field name string
---@field func function
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
				errorx.new(labels.ErrorHookNotFunction, type(func), "function")
			)
		end
		if not ctx.current then
			error(errorx.new(labels.UnknownContext))
		end
		table.insert(ctx.current.hooks[typ], {
			name = localName,
			func = func,
			type = typ,
		} --[[@as Hook]])
	end
end

return Hook
