local key = require("key")

local Config = {
	-- External configurable
	Color = true,
	Dir = ".",
	FilePattern = "*_test.lua",
	Tab = "\t",
	Traceback = false,

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
