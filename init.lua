local startTime = os.clock()
local printer = require("lib.printer")
local context = require("lib.context")
local time = require("lib.util.time")
local labels = require("lib.labels")
local errorx = require("lib.errorx")
local fs = require("lib.fs")
local config = require("config")
local helpers = require("lib.util.helpers")
local Status = require("lib.status")
local Runnable = require("lib.runnable")

local ctx = context.global()

local files, fcount = fs.getFiles(arg[1] or config.dir)
if fcount == 0 then
	print(labels.noTests)
	os.exit(config.exitFailed)
end

-- Sorting files in alphabetical order to keep consistency.
for fname in helpers.spairs(files) do
	local chunk, loadErr = loadfile(fname, "t", _G)
	if chunk ~= nil then
		chunk() -- pcall? check descibe
	else
		printer.printActual(loadErr or labels.errorSyntax)
		os.exit(config.exitFailed)
	end
end

local function runTests(tests)
	for i = 1, #tests do
		for j = 1, #tests[i] do
			tests[i][j]:run()
		end
	end
end

local function printTests2(tests)
	for i = 1, #tests do
		for j = 1, #tests[i] do
			local test = tests[i][j]
			if test.isSuite then
				printer.printStyle(
					helpers.tab(test.level - 1) .. test.description,
					1
				)
			else
				local tdiffstr =
					string.format(" (%s)", time.format(test.execTime))
				if test.status == Status.skipped then
					printer.printSkipped(test.description, nil, test.level)
				elseif test.status == Status.failed then
					printer.printActual(test.description, tdiffstr, test.level)
				elseif test.status == Status.passed then
					printer.printExpected(
						test.description,
						tdiffstr,
						test.level
					)
				end
			end
		end
	end
end

local all, allTotal = Runnable.filter(ctx.tests, {})
local onlyTests, onlyTotal = Runnable.getOnly(ctx.tests)
if #onlyTests > 0 then
	all = onlyTests
	allTotal = onlyTotal
end

runTests(all)

local failed, failedTotal =
	Runnable.filter(all, { status = Status.failed, isSuite = false })
local passed, passedTotal =
	Runnable.filter(all, { status = Status.passed, isSuite = false })
local skipped, skippedTotal =
	Runnable.filter(all, { status = Status.skipped, isSuite = false })

printTests2(all)

if failedTotal > 0 then
	io.write("\n")
	printer.printStyle(
		labels.failedTests,
		printer.termStyles.bold,
		printer.termStyles.underlined
	)
	local n = 1
	for lvl = 1, #failed do
		for j = 1, #failed[lvl] do
			io.write(string.format("%d. ", n))
			errorx.print(failed[lvl][j].err)
			n = n + 1
		end
	end
end

printer.printStyle(
	labels.summary,
	printer.termStyles.bold,
	printer.termStyles.underlined
)

local successMsg =
	string.format("%d of %d passing\n", passedTotal, allTotal - skippedTotal)
io.write(successMsg)

local failedMessage =
	string.format("%d failing\n", failedTotal, allTotal - skippedTotal)
io.write(failedMessage)

local skippedMessage = string.format("%d skipping\n", skippedTotal)
io.write(skippedMessage)

local formatedTime = time.format(os.clock() - startTime)
local str = string.format(labels.timeSummary, formatedTime, os.date())
io.write(str)

if failedTotal > 0 then
	print(labels.failed)
	os.exit(config.exitFailed)
else
	print(labels.pass)
	os.exit(config.exitPass)
end
