local Status = require("lib.Status")

---@type {[string]: any}
local Labels = {
	AddedSymbol = "+",
	ErrorActual = "actual: ",
	ErrorAssertion = "assertion error: ",
	ErrorCallbackNotFunction = "callback is not a function",
	ErrorConfigFilePath = "no config path diven",
	ErrorConfigRead = "cannot read config file\n",
	ErrorEnumKey = "%q is not a valid member of %s",
	ErrorExpected = "exptected: ",
	ErrorHookNotFunction = "hook is not a function",
	ErrorNotADir = "is not a directory",
	ErrorSyntax = "syntax error",
	FailedTests = "FAILED TESTS",
	Not = "not",
	NoTests = "no tests found",
	Performance = "\ntime: ≈%s / mem: %s @ %s\n",
	RemovedSymbol = "-",
	ResultFailed = "failed",
	ResultPass = "pass",
	Expected = {
		Precision = "\texpected precision:    %d",
		Difference = "\texpected difference: < %s%s%s",
		Error = "function should fail",
	},
	Actual = {
		Difference = "\tactual difference:     %s%s%s",
		Error = "function did not fail",
	},
	Statuses = {
		[Status.Passed] = "passing",
		[Status.Unchanged] = "",
		[Status.Failed] = "failing",
		[Status.Skipped] = "skipping",
		[Status.Common] = "",
	},
	Summary = {
		Title = "\nSUMMARY",
		Failing = "%d failing\n",
		Passing = "%d of %d passing\n",
		Skipping = "%d skipping\n",
	},
	Total = "Total",
	UnchangedSymbol = "",
	UnknownContext = "unknown context",
	WarningNoReporters = "no reporters given",
}

return setmetatable(Labels, {
	__index = function(_, key)
		error(string.format(Labels.ErrorEnumKey, tostring(key), "Labels"), 2)
	end,
})
