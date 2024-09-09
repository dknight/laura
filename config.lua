local key = require("key")

---@type {[string]: string | ReporterType[] | boolean | number}
local Config = {
	-- Externally configurable
	color = true,
	dir = ".",
	filePattern = "*_test.lua",
	tab = "\t",
	traceback = false,
	reporters = { "text" },
	reportSummary = true,

	-- Internally configurable, do not meant to be change externally.
	_appKey = key,
	_suiteLevel = 3,
	_exitFailed = 1,
	_exitOK = 0,
	_rootSuiteKey = "__LAURA_ROOT__",
	_beforeEachName = "beforeEach", ---@as [[HookType]]
	_beforeAllName = "beforeAll", ---@as [[HookType]]
	_afterEachName = "afterEach", ---@as [[HookType]]
	_afterAllName = "afterAll", ---@as [[HookType]]
}

return Config
