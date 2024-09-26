local Context = require("laura.Context")
local Hook = require("laura.Hook")

local ctx = Context.global()

return {
	[ctx.config._afterAllName] = Hook.new(ctx.config._afterAllName),
	[ctx.config._afterEachName] = Hook.new(ctx.config._afterEachName),
	[ctx.config._beforeAllName] = Hook.new(ctx.config._beforeAllName),
	[ctx.config._beforeEachName] = Hook.new(ctx.config._beforeEachName),
}
