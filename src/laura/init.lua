-- coverage: disable
local Context = require("laura.Context")
local Coverage = require("laura.Coverage")
local helpers = require("laura.util.helpers")
local tablex = require("laura.ext.tablex")

local ctx = Context.global()

---Enables coverage collection.
local function collectCoverage()
	ctx.coverage = Coverage:new()
	local hookFn = ctx.coverage:createHookFunction(2)
	local hook = debug.gethook()
	if hook == nil then
		debug.sethook(hookFn, "l")
	end
end

---Setup the project. All initiazliation stuff goes here.
---@param defaults? Config | table
local function setup(defaults)
	defaults = defaults or {}

	-- Merge from Config.lua file
	ctx.config =
		tablex.merge(defaults --[[@as table]], defaults --[[@as table]])

	-- Read config from .rc file
	local conf, _ = helpers.readFromRCFile()
	if conf ~= nil then
		ctx.config = tablex.merge(ctx.config, conf)
	end

	local code = helpers.processFlags(arg)
	if code ~= -1 then
		os.exit(code)
	end

	if helpers.hasFlag("--nocoverage") then
		ctx.config.Coverage.Enabled = false
	elseif helpers.hasFlag("--coverage") then
		ctx.config.Coverage.Enabled = true
	end

	if ctx.config.Coverage.Enabled then
		collectCoverage()
	end
end

-- initial setup, not sure should it be here
local defaults = require("laura.Config")
setup(defaults)

return {
	Config = require("laura.Config"),
	Context = require("laura.Context"),
	Coverage = require("laura.Coverage"),
	describe = require("laura.Suite"),
	expect = require("laura.expect"),
	Hook = require("laura.Hook"),
	hooks = require("laura.hooks"),
	it = require("laura.Test"),
	Labels = require("laura.Labels"),
	Reporter = require("laura.Reporter"),
	Runnable = require("laura.Runnable"),
	Runner = require("laura.Runner"),
	setup = setup,
	Spy = require("laura.Spy"),
	Status = require("laura.Status"),
	Stub = require("laura.Stub"),
	Suite = require("laura.Suite"),
	suite = require("laura.Suite"), -- alias
	Terminal = require("laura.Terminal"),
	Test = require("laura.Test"),
	test = require("laura.Test"), -- alias
	LuaVersion = require("laura.LuaVersion"),
}
-- coverage: enable
