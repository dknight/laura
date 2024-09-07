local Status = require("lib.classes.Status")

---@type table{[string]: string}
return {
	Added = "+",
	ErrorActual = "Actual: ",
	ErrorAssertion = "Assertion error: ",
	ErrorExpected = "Exptected: ",
	ErrorSyntax = "Syntax error",
	ErrorHookNotFunction = "Hook is not a function",
	FailedTests = "FAILED TESTS",
	NoTests = "No tests found",
	Removed = "-",
	ResultFailed = "FAILED",
	ResultPass = "PASS",
	Statuses = {
		[Status.Passed] = "PASSED",
		[Status.Unchanged] = "",
		[Status.Failed] = "FAILED",
		[Status.Skipped] = "SKIPPED",
		[Status.Common] = "",
	},
	Summary = {
		Title = "\nSUMMARY",
		Failing = "%d failing\n",
		Passing = "%d of %d passing\n",
		Skipping = "%d skipping\n",
	},
	Performance = "\nApproximate execution time %s / Mem: %s @ %s\n",
	UnknownContext = "Unknown context",
}
