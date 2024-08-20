local startTime = os.clock()
local printer = require("lib.printer")
local context = require("lib.context")
local time = require("lib.util.time")
local labels = require("lib.labels")
local errorx = require("lib.errorx")
local scandir = require("lib.fs.scandir")
local config = require("config")

local ctx = context.global()

local pattern = arg[1] or "."
local dirs = {}
for str in string.gmatch(pattern, "([^:]+)") do
	dirs[#dirs + 1] = str
end

local files = {}
for _, dir in pairs(dirs) do
	for _, filename in pairs(scandir(dir)) do
		files[#files + 1] = filename
	end
end

-- Sorting files in alphabetical order to keep consistency.
table.sort(files)

for _, filename in pairs(files) do
	local chunk = loadfile(filename, "bt", _G)
	if chunk ~= nil then
		local ok, err = pcall(chunk)
		if not ok then
			printer.printActual(err)
		end
	end
end

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
