local key = require("key")

---@type {[string]: ReporterType[] | HookType | boolean | number | string}
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
	_beforeEachName = "beforeEach",
	_beforeAllName = "beforeAll",
	_afterEachName = "afterEach",
	_afterAllName = "afterAll",
}

return Config
