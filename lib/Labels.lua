local Status = require("lib.Status")

---@type table{[string]: string}
local Labels = {
	AddedSymbol = "+",
	ErrorActual = "actual: ",
	ErrorAssertion = "assertion error: ",
	ErrorConfigFilePath = "no config path diven",
	ErrorConfigRead = "cannot read config file\n",
	ErrorExpected = "exptected: ",
	ErrorHookNotFunction = "hook is not a function",
	ErrorCallbackNotFunction = "callback is not a function",
	ErrorEnumKey = "%q is not a valid member of %s",
	ErrorNotADir = "is not a directory",
	ErrorSyntax = "syntax error",
	FailedTests = "FAILED TESTS",
	NoTests = "no tests found",
	Performance = "\ntime: ≈%s / mem: %s @ %s\n",
	RemovedSymbol = "-",
	ResultFailed = "failed",
	ResultPass = "pass",
	WarningNoReporters = "no reporters given",
	Statuses = {
		[Status.passed] = "passing",
		[Status.unchanged] = "",
		[Status.failed] = "failing",
		[Status.skipped] = "skipping",
		[Status.common] = "",
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
}

return setmetatable(Labels, {
	__index = function(_, key)
		error(string.format(Labels.ErrorEnumKey, tostring(key), "Labels"), 2)
	end,
})
