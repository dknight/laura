local Context = require("laura.Context")

local ctx = Context.global()

---Setup the project. All initiazliation stuff goes here.
---@param config? Config | table
local function setup(config)
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

-- initial setup
setup({})

---#coverage
-- local hoolFn = function(event, lineno)
-- local src = debug.getinfo(2, "S").short_src
-- ctx.coverage[src] = ctx.coverage[src] or {}
-- ctx.coverage[src][lineno] = (ctx.coverage[src][lineno] or 0) + 1
-- print(event, lineno, src)
-- end
-- local hook = debug.gethook()
-- if hook == nil then
-- debug.sethook(hoolFn, "l")
-- end

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
