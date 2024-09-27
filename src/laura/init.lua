local Context = require("laura.Context")
local Hook = require("laura.Hook")

---@param ctx Context
---@param cfg? Config
local function setup(ctx, cfg)
	ctx.config = require("laura.Config")
	for k, v in
		pairs(cfg or {} --[[@as table]])
	do
		if ctx.config[k] ~= nil then
			ctx.config[k] = v
		end
	end
end

---@param ctx Context
---@return {[string]: Hook}
local function hooks(ctx)
	return {
		[ctx.config._afterAllName] = Hook.new(ctx.config._afterAllName),
		[ctx.config._afterEachName] = Hook.new(ctx.config._afterEachName),
		[ctx.config._beforeAllName] = Hook.new(ctx.config._beforeAllName),
		[ctx.config._beforeEachName] = Hook.new(ctx.config._beforeEachName),
	}
end

setup(Context.global())

return {
	Config = require("laura.Config"),
	Context = require("laura.Context"),
	describe = require("laura.Suite"),
	expect = require("laura.expect"),
	Hook = require("laura.Hook"),
	hooks = hooks,
	it = require("laura.Test"),
	Labels = require("laura.Labels"),
	Runnable = require("laura.Runnable"),
	Runner = require("laura.Runner"),
	setup = setup,
	Spy = require("laura.Spy"),
	Status = require("laura.Status"),
	Suite = require("laura.Suite"),
	suite = require("laura.Suite"), -- alias
	Terminal = require("laura.Terminal"),
	Test = require("laura.Test"),
	test = require("laura.Test"), -- alias
	Version = require("laura.Version"),
}
