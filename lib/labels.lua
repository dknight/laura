local Status = require("lib.classes.Status")

---@type table{[string]: string}
return {
	addedSymbol = "+",
	errorActual = "Actual: ",
	errorNoRoot = "No root found",
	errorAssertion = "Assertion error: ",
	errorExpected = "Exptected: ",
	errorSyntax = "Syntax error",
	errorHookNotFunction = "Hook is not a function",
	errorConfigRead = "cannot read config file\n",
	failedTests = "FAILED TESTS",
	noTests = "No tests found",
	removedSymbol = "-",
	resultFailed = "FAILED",
	resultPass = "PASS",
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
	performance = "\nApproximate execution time %s / Mem: %s @ %s\n",
	unknownContext = "Unknown context",
}
