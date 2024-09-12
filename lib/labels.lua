local Status = require("lib.classes.Status")

---@type table{[string]: string}
return {
	addedSymbol = "+",
	errorActual = "actual: ",
	errorAssertion = "assertion error: ",
	errorConfigFilePath = "no config path diven",
	errorConfigRead = "cannot read config file\n",
	errorExpected = "exptected: ",
	errorHookNotFunction = "hook is not a function",
	errorCallbackNotFunction = "callback is not a function",
	errorNotADir = "is not a directory",
	errorSyntax = "syntax error",
	failedTests = "FAILED TESTS",
	noTests = "no tests found",
	performance = "\ntime: ≈%s / mem: %s @ %s\n",
	removedSymbol = "-",
	resultFailed = "failed",
	resultPass = "pass",
	warningNoReporters = "no reporters given",
	statuses = {
		[Status.passed] = "passing",
		[Status.unchanged] = "",
		[Status.failed] = "failing",
		[Status.skipped] = "skipping",
		[Status.common] = "",
	},
	summary = {
		title = "\nSUMMARY",
		failing = "%d failing\n",
		passing = "%d of %d passing\n",
		skipping = "%d skipping\n",
	},
	total = "total",
	unchangedSymbol = "",
	unknownContext = "unknown context",
}
