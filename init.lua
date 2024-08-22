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

local function printTests(collection)
	for level = 1, #collection do
		for i = 1, #collection[level] do
			local test = collection[level][i]
			if collection[level][i].isSuite then
				printer.printStyle(
					helpers.tab(level - 1) .. test.description,
					1
				)
			else
				local tdiffstr =
					string.format(" (%s)", time.format(test.execTime))
				if test.status == Status.skipped then
					printer.printSkipped(test.description, nil, level)
				elseif test.status == Status.actual then
					printer.printActual(test.description, tdiffstr, level)
				elseif test.status == Status.expected then
					printer.printExpected(test.description, tdiffstr, level)
				end
			end
		end
	end
end

printTests(ctx.tests)

local all = Runnable.getAll()
local passed =
	Runnable.filter(all, { status = Status.expected, isSuite = false })
local failed = Runnable.filter(all, { status = Status.actual, isSuite = false })
local skipped =
	Runnable.filter(all, { status = Status.skipped, isSuite = false })

-- Cache totals
local total = #all
local passedTotal = #passed
local failedTotal = #failed
local skippedTotal = #skipped

if failedTotal > 0 then
	io.write("\n")
	printer.printStyle(
		labels.failedTests,
		printer.termStyles.bold,
		printer.termStyles.underlined
	)
	for i = 1, #failed do
		io.write(string.format("%d. ", i))
		errorx.print(failed[i].err)
	end
end

printer.printStyle(
	labels.summary,
	printer.termStyles.bold,
	printer.termStyles.underlined
)

local successMsg =
	string.format("%d of %d passing\n", passedTotal, total - skippedTotal)
io.write(successMsg)

local failedMessage = string.format("%d failing\n", failedTotal, total)
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
