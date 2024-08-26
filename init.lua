local startTime = os.clock()

local constants = require("lib.util.constants")
local Context = require("lib.classes.Context")
local fs = require("lib.util.fs")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local Runner = require("lib.classes.Runner")
local Terminal = require("lib.classes.Terminal")

local ctx = Context.global()
local runner = Runner:new(ctx)
ctx.config = require("config")

---Read config from the path.
---@param path string
local function setConfigFromFile(path)
	local chunk, err = loadfile(path, "t")
	if chunk ~= nil then
		for k, v in pairs(chunk()) do
			if ctx.config[k] ~= nil then
				ctx.config[k] = v
			end
		end
	else
		error("cannot read config file\n" .. err)
	end
end

-- Very dirty and primitive arguments parsing.
for k, v in ipairs(arg) do
	if v == "-h" or v == "-?" or v == "--help" then
		helpers.usage()
		os.exit(constants.exitOk)
	end

	if v == "-v" or v == "--version" then
		print(string.format("%s v%s", constants.appKey, helpers.version()))
		os.exit(constants.exitOk)
	end

	if v == "-c" or v == "--config" then
		local path = arg[k + 1]
		if path == nil then
			error("config path is emtpy")
		end
		setConfigFromFile(path)
	end
end

-- last argument should be directory with tests
local filesDir = ctx.config.dir
if #arg ~= 0 then
	filesDir = arg[#arg]
end

if
	not fs.isDir(filesDir)
	and filesDir ~= "."
	and filesDir ~= "./"
	and filesDir ~= ".\\"
then
	error(filesDir .. " is not a directory.")
end

local files, fcount = fs.getFiles(filesDir)
if fcount == 0 then
	print(labels.noTests)
	os.exit(constants.exitOk)
end

-- Sorting files in alphabetical order to keep consistency.
for fname in helpers.spairs(files) do
	local chunk, err = loadfile(fname, "t", _G)
	if chunk ~= nil then
		chunk() -- pcall? check descibe
	else
		Terminal.printActual(err or labels.errorSyntax)
		os.exit(constants.exitFailed)
	end
end

runner:runTests()
runner:reportTests()
runner:reportErrors()
runner:reportSummary()
runner:reportTime(startTime)
runner:done()
