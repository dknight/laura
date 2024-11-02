local Status = require("laura.Status")

---@type {[string]: any|table}
local Labels = {
	AddedSymbol = "+",
	ErrorActual = "actual: ",
	ErrorCallbackNotFunction = "callback is not a function",
	ErrorConfigFilePath = "no config path diven",
	ErrorConfigRead = "cannot read config file",
	ErrorCoverageNotMet = "coverage is %.1f%%, but required %.1f%%",
	ErrorEnumKey = "%q is not a valid member of %s",
	ErrorExpected = "exptected: ",
	ErrorHookNotFunction = "hook is not a function",
	ErrorNotADir = "is not a directory",
	ErrorSyntax = "syntax error",
	ErrorNothingToCover = "nothing to cover",
	ErrorCannotCreateDir = "cannot create directory %s",
	ErrorCannotRemoveDir = "cannot remove directory %s",
	ErrorCannotReadFile = "cannot read file %s",
	ErrorCannotWriteFile = "cannot write to file %s",
	ErrorUnknown = "unknown error",
	FailedTests = "FAILED TESTS",
	NoTests = "no tests found",
	NumberOfCalls = "number of calls: ",
	NumberOfReturns = "number of returns: ",
	Performance = "time: ~%s / mem: %s @ %s",
	RemovedSymbol = "-",
	ReportWrittenTo = "report written to %s",
	ResultFailed = "failed",
	ResultPass = "pass",
	Expected = {
		Precision = "\texpected precision:    %d",
		Difference = "\texpected difference: < %s%s%s",
		FnFail = "should fail",
		Pattern = "expected pattern: ",
		Calls = "expected number of calls: ",
		Returns = "expected number of returns: ",
		Key = "expected key: ",
	},
	Actual = {
		Difference = "\tactual difference:     %s%s%s",
		FnFail = "did not fail",
		Pattern = "actual string: ",
		Calls = "actual number of calls: ",
		Returns = "actual number of returns: ",
		Table = "actual table: ",
		String = "actual string: ",
	},
	Statuses = {
		[Status.Passed] = "passing",
		[Status.Unchanged] = "",
		[Status.Failed] = "failing",
		[Status.Skipped] = "skipping",
		[Status.Common] = "",
	},
	Summary = {
		Title = "SUMMARY",
		Failing = "%d failing",
		Passing = "%d of %d passing",
		Skipping = "%d skipping",
		Coverage = "COVERAGE",
	},
	Total = "Total",
	UnchangedSymbol = "",
	UnknownContext = "unknown context",
	WarningNoReporters = "no reporters given",
	WarningUnknownContext = "unknown source",
}

return setmetatable(Labels, {
	__index = function(_, key)
		error(string.format(Labels.ErrorEnumKey, tostring(key), "Labels"), 2)
	end,
})
