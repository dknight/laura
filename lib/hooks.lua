local Context = require("lib.classes.Context")
local Hook = require("lib.classes.Hook")

local ctx = Context.global()

return {
	[ctx.config.AfterAllName] = Hook.new(ctx.config.AfterAllName),
	[ctx.config.AfterEachName] = Hook.new(ctx.config.AfterEachName),
	[ctx.config.BeforeAllName] = Hook.new(ctx.config.BeforeAllName),
	[ctx.config.BeforeEachName] = Hook.new(ctx.config.BeforeEachName),
}
