local key = require("key")

---@type {[string]: boolean | number | string}
local Config = {
	-- External configurable
	color = true,
	dir = ".",
	filePattern = "*_test.lua",
	tab = "\t",
	traceback = false,

	-- Internal do not change
	AppKey = key,
	SuiteLevel = 3,
	ExitFailed = 1,
	ExitOK = 0,
	RootSuiteKey = "__LAURA_ROOT__",
	BeforeEachName = "beforeEach", ---@as [[HookType]]
	BeforeAllName = "beforeAll", ---@as [[HookType]]
	AfterEachName = "afterEach", ---@as [[HookType]]
	AfterAllName = "afterAll", ---@as [[HookType]]
}

return Config
