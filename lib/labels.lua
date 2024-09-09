local Status = require("lib.classes.Status")

---@type table{[string]: string}
return {
	addedSymbol = "+",
	errorActual = "actual: ",
	errorNoRoot = "no root found",
	errorAssertion = "assertion error: ",
	errorExpected = "Exptected: ",
	errorSyntax = "syntax error",
	errorHookNotFunction = "hook is not a function",
	errorConfigRead = "cannot read config file\n",
	errorNotADir = "is not a directory",
	errorConfigFilePath = "no config path diven",
	warningNoReporters = "no reporters given",
	failedTests = "FAILED TESTS",
	noTests = "no tests found",
	removedSymbol = "-",
	resultFailed = "failed",
	resultPass = "pass",
	statuses = {
		[Status.passed] = "PASSED",
		[Status.unchanged] = "",
		[Status.failed] = "FAILED",
		[Status.skipped] = "SKIPPED",
		[Status.common] = "",
	},
	summary = {
		title = "\nSUMMARY",
		failing = "%d failing\n",
		passing = "%d of %d passing\n",
		skipping = "%d skipping\n",
	},
	unchangedSymbol = "",
	performance = "\napproximate execution time %s / Mem: %s @ %s\n",
	unknownContext = "unknown context",
}
