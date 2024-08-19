local startTime = os.clock()
local printer = require("lib.printer")
local context = require("lib.context")
local time = require("lib.util.time")
local sys = require("lib.util.sys")
local labels = require("lib.labels")
local errorx = require("lib.errorx")
local config = require("config")

local ctx = context.global()
ctx.aura = {
	failed = 0,
	passed = 0,
	total = 0,
	skipped = 0,
	level = 0,
	errors = {},
}

local function scandir(directory)
	local cmd
	if sys.isWindows() then
		cmd = "DIR /S/B/O:n *_test.lua"
	else
		cmd = "find '%s' -type f -name '*_test.lua' -print0 | sort"
	end
	local i, t = 0, {}
	local fd = assert(io.popen((cmd):format(directory), "r"))
	local list = fd:read("*a")
	fd:close()

	for filename in list:gmatch("[^\0]+") do
		i = i + 1
		t[i] = filename
	end
	return t
end

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
	local chunk = loadfile(filename, "bt", ctx)
	if chunk ~= nil then
		local ok, err = pcall(chunk)
		if not ok then
			printer.printActual(err)
		end
	end
end

if #ctx.aura.errors > 0 then
	io.write("\n")
	printer.printStyle(
		labels.failedTests,
		printer.termStyles.bold,
		printer.termStyles.underlined
	)
	for i = 1, #ctx.aura.errors do
		io.write(string.format("%d. ", i))
		errorx.print(ctx.aura.errors[i])
	end
end

printer.printStyle(
	labels.summary,
	printer.termStyles.bold,
	printer.termStyles.underlined
)

local successMsg = string.format(
	"%d of %d passing\n",
	ctx.aura.passed,
	ctx.aura.total - ctx.aura.skipped
)
io.write(successMsg)

local failedMessage =
	string.format("%d failing\n", ctx.aura.failed, ctx.aura.total)
io.write(failedMessage)

local skippedMessage = string.format("%d skipping\n", ctx.aura.skipped)
io.write(skippedMessage)

local formatedTime = time.format(os.clock() - startTime)
local str = string.format(labels.timeSummary, formatedTime, os.date())
io.write(str)

if ctx.aura.failed > 0 then
	print(labels.failed)
	os.exit(config.exitFailed)
else
	print(labels.pass)
	os.exit(config.exitPass)
end
