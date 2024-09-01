local Status = require("lib.classes.Status")

---@type table{[string]: string}
return {
	added = "+",
	errorActual = "Actual: ",
	errorAssertion = "Assertion error: ",
	errorExpected = "Exptected: ",
	errorSyntax = "Syntax error",
	errorHookNotFunction = "Hook is not a function",
	failedTests = "FAILED TESTS",
	noTests = "No tests found",
	removed = "-",
	resultFailed = "FAILED",
	resultPass = "PASS",
	statuses = {
		[Status.Passed] = "PASSED",
		[Status.Unchanged] = "",
		[Status.Failed] = "FAILED",
		[Status.Skipped] = "SKIPPED",
		[Status.Common] = "",
	},
	summary = {
		title = "\nSUMMARY",
		failing = "%d failing\n",
		passing = "%d of %d passing\n",
		skipping = "%d skipping\n",
	},
	performance = "\nApproximate execution time %s / Mem: %s @ %s\n",
	unknownContext = "Unknown context",
}
