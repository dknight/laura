local key = require("key")

---@enum Config
local Config = {
	-- Externally configurable.
	---------------------------------------------------------------------------
	-- Change this
	---------------------------------------------------------------------------
	-- Enables colors in terminal if possible. true by default.
	Color = true,

	-- Directory where tests are located. Current directory by default.
	Dir = ".",

	-- Pattern for tests files.
	FilePattern = "*_test.lua",

	-- Tabulation string, "\t" by default.
	Tab = "\t",

	-- Print full traceback from debug library on test failure.
	-- false by default.
	Traceback = false,

	-- List of reporters. Check reporter section for possible values.
	Reporters = { "text" },

	-- Print tests summary if reporter support it. true by default.
	ReportSummary = true,

	-- Internally configurable, do not meant to be change externally.
	---------------------------------------------------------------------------
	-- Not recommened to change.
	---------------------------------------------------------------------------
	-- Application name. "Laura" is default.
	_appKey = key,

	-- Suite error level, used to report more pricise error call
	-- stack
	_suiteLevel = 3,

	-- Failure exit code, usually non-zero by *nix convention.
	_exitFailed = 1,

	-- Sucess exit code, usually zero by *nix convention.
	_exitOK = 0,

	-- Unique key in global context in case of integration with other software.
	_rootSuiteKey = "__LAURA_ROOT__",

	-- Hooks names.
	_beforeEachName = "beforeEach",
	_beforeAllName = "beforeAll",
	_afterEachName = "afterEach",
	_afterAllName = "afterAll",
}

return Config