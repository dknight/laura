local Context = require("laura.Context")
local Coverage = require("laura.Coverage")

local ctx = Context.global()

---Enables coverage collection.
local function enableCoverage()
	ctx.coverage = Coverage:new()
	local hoolFn = ctx.coverage:createHook(2)
	local hook = debug.gethook()
	if hook == nil then
		debug.sethook(hoolFn, "l")
	end
end

---Merges config from defaults to context.
---@param config? Config | table
local function mergeConfig(config)
	config = config or {}
	ctx = ctx or Context.global()
	ctx.config = require("laura.Config")
	for k, v in
		pairs(config --[[@as table]])
	do
		if ctx.config[k] ~= nil then
			ctx.config[k] = v
		end
	end
end

---Setup the project. All initiazliation stuff goes here.
---@param config? Config | table
local function setup(config)
	mergeConfig(config)
	if ctx.config.Coverage.Enabled then
		enableCoverage()
	end
end

-- initial setup, not sure should it be here
setup({})

---#coverage

return {
	Config = require("laura.Config"),
	Context = require("laura.Context"),
	describe = require("laura.Suite"),
	expect = require("laura.expect"),
	Hook = require("laura.Hook"),
	hooks = require("laura.hooks"),
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
