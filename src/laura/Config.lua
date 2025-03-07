local Labels = require("laura.Labels")

---@enum Config
local Config = {
	---------------------------------------------------------------------------
	-- Externally configurable.
	-- Change this.
	---------------------------------------------------------------------------
	-- Enables colors in terminal if possible. true by default.
	Color = true,

	-- Directory where tests are located. Current directory by default.
	Dir = ".",

	-- Pattern for tests files.
	-- Be careful with with MS Windows, unix command and DIR are completely not compatible.
	TestPattern = "*test.lua",

	-- Tabulation string, "\t" by default.
	Tab = "\t",

	-- Print full traceback from debug library on test failure.
	-- false by default.
	Traceback = false,

	-- List of reporters.
	Reporters = {
		--"blank",
		--"count",
		--"dots",
		"text",
	},

	-- Date/time format for the reports.
	DateFormat = "%Y-%m-%d %H:%M:%S",

	-- Print tests summary if reporter support it. true by default.
	ReportSummary = true,

	-- Collect code coverage.
	Coverage = {
		Enabled = false,
		Threshold = 80,
		ThresholdPoints = {
			Low = 50,
			Average = 66.7,
			High = 90,
		},
		ReportName = "covreport",

		-- Coverage reporters.
		Reporters = {
			--"blank",
			--"csv",
			-- "html",
			--"json",
			--"lua",
			--"xml",
			"terminal",
		},

		-- Directory where coverage is written.
		Dir = "coverage",

		-- Files mask to include files.
		IncludePattern = ".*%.lua",
	},

	--
	-- Internally configurable, do not meant to be change externally.
	---------------------------------------------------------------------------
	-- Not recommened to change.
	---------------------------------------------------------------------------
	-- Application name. "Laura" is default.
	_appKey = "Laura",

	-- Unique key in global context in case of integration with other software.
	_contextKey = "__LAURA_CONTEXT__",

	-- Unique key in global context for root test suite/case.
	_rootKey = "__LAURA_ROOT__",

	-- Failure exit code, usually non-zero by *nix convention.
	_Exit = {
		-- Sucess exit code, usually zero by *nix convention.
		OK = 0,
		-- Lua or system error.
		SysErr = 1,
		-- Tests are failed.
		Failed = 2,
		-- Failure exit code, when coverage threshold is not met.
		CoverageFailed = 3,
	},

	-- Hooks names.
	_beforeEachName = "beforeEach",
	_beforeAllName = "beforeAll",
	_afterEachName = "afterEach",
	_afterAllName = "afterAll",

	-- Negation markers prefix, use to negate matcher.
	_negationPrefix = "not",

	-- rational numbers set
	_rationalSet = "n={Q}",

	-- executable name
	_execName = "laura",

	-- lines marked as execluded in coverage reporters
	_coverageExcludeLineIndex = -1,

	-- confing rc filename
	_rcFile = ".laurarc",
}

return setmetatable(Config, {
	__index = function(_, k)
		error(string.format(Labels.ErrorEnumKey, tostring(k), "Config"), 2)
	end,
})
