local Context = require("lib.classes.Context")
local fs = require("lib.util.fs")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local Reporter = require("lib.reporters.Reporter")
local Runner = require("lib.classes.Runner")
local Terminal = require("lib.classes.Terminal")

local ctx = Context.global()
ctx.config = require("config")

helpers.processFlags()

local runner = Runner:new()

-- last argument should be directory with tests
local dir = arg[#arg]
if not fs.isDir(dir) then
	dir = ctx.config.dir
end

if not fs.isDir(dir) and dir ~= "." and dir ~= "./" and dir ~= ".\\" then
	error(dir .. " " .. labels.errorNotADir)
end

local files, fcount = fs.getFiles(dir)
if fcount == 0 then
	print(labels.noTests)
	os.exit(ctx.config._exitOK)
end

-- Sorting files in alphabetical order to keep consistency.
for fname in helpers.spairs(files) do
	local chunk, err = loadfile(fname, "t", _G)
	if chunk ~= nil then
		chunk()
	else
		Terminal.printActual(err or labels.errorSyntax)
		os.exit(ctx.config._exitFailed)
	end
end

local results = runner:runTests()
local genericReporter = Reporter:new(results)

if ctx.config.reportSummary and #ctx.config.reporters > 0 then
	genericReporter:report()
end

runner:done()
