local startTime = os.clock()
local printer = require("lib.printer")
local labels = require("lib.labels")
local fs = require("lib.util.fs")
local config = require("config")
local helpers = require("lib.util.helpers")
local Context = require("lib.classes.Context")
local Runner = require("lib.classes.Runner")

local ctx = Context.global()
local runner = Runner:new(ctx)

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

runner:runTests()
runner:reportTests()
runner:reportErrors()
runner:reportSummary()
runner:reportTime(startTime)
runner:done()
