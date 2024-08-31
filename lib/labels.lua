local Status = require("lib.classes.Status")

---@type table{[string]: string}
return {
	added = "+",
	errorActual = "Actual: ",
	errorAssertion = "Assertion error: ",
	errorExpected = "Exptected: ",
	errorSyntax = "Syntax error",
	failedTests = "FAILED TESTS",
	noTests = "No tests found",
	removed = "-",
	statuses = {
		[Status.Passed] = "PASSED",
		[Status.Unchanged] = "",
		[Status.Failed] = "FAILED",
		[Status.Skipped] = "SKIPPED",
		[Status.Common] = "",
	},
	summary = "SUMMARY",
	timeSummary = "\nApproximate execution time %s @ %s\n",
}
