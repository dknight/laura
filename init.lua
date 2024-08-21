local startTime = os.clock()
local printer = require("lib.printer")
local context = require("lib.context")
local time = require("lib.util.time")
local labels = require("lib.labels")
local errorx = require("lib.errorx")
local fs = require("lib.fs")
local config = require("config")
local helpers = require("lib.util.helpers")

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
		chunk()
	else
		printer.printActual(loadErr or labels.errorSyntax)
		os.exit(config.exitFailed)
	end
end

-- os.exit(1)

if #ctx.errors > 0 then
	io.write("\n")
	printer.printStyle(
		labels.failedTests,
		printer.termStyles.bold,
		printer.termStyles.underlined
	)
	for i = 1, #ctx.errors do
		io.write(string.format("%d. ", i))
		errorx.print(ctx.errors[i])
	end
end

printer.printStyle(
	labels.summary,
	printer.termStyles.bold,
	printer.termStyles.underlined
)

local successMsg =
	string.format("%d of %d passing\n", ctx.passed, ctx.total - ctx.skipped)
io.write(successMsg)

local failedMessage = string.format("%d failing\n", ctx.failed, ctx.total)
io.write(failedMessage)

local skippedMessage = string.format("%d skipping\n", ctx.skipped)
io.write(skippedMessage)

local formatedTime = time.format(os.clock() - startTime)
local str = string.format(labels.timeSummary, formatedTime, os.date())
io.write(str)

if ctx.failed > 0 then
	print(labels.failed)
	os.exit(config.exitFailed)
else
	print(labels.pass)
	os.exit(config.exitPass)
end
