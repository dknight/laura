local startTime = os.clock()

local config = require("tests.config")
local Context = require("lib.classes.Context")
local fs = require("lib.util.fs")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local Runner = require("lib.classes.Runner")
local Terminal = require("lib.classes.Terminal")

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
		Terminal.printActual(loadErr or labels.errorSyntax)
		os.exit(config.exitFailed)
	end
end

runner:runTests()
runner:reportTests()
runner:reportErrors()
runner:reportSummary()
runner:reportTime(startTime)
runner:done()
