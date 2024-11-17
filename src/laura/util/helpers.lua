local Context = require("laura.Context")
local fs = require("laura.util.fs")
local Labels = require("laura.Labels")
local stringx = require("laura.ext.stringx")

local EOL = fs.EOL
local ctx = Context.global()

---Get the version.
---@return string
local function version()
	return (require("src.laura.version"))
end

---Sort table by keys in alphabetical order.
---@param t table
---@param sortFunc? fun(t:table, a: any, b: any): boolean
---@retrn fun(): string | number | boolean, any
local function spairs(t, sortFunc)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if type(sortFunc) == "function" then
		table.sort(keys, sortFunc)
	else
		table.sort(keys)
	end

	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

---Gets N indentations.
---@param n number
---@string
local function tab(n)
	return string.rep(ctx.config.Tab, n)
end

---Prints usage in terminal.
local function usage()
	io.write(table.concat({
		string.format("Laura %s", version()),
		"Usage: laura [-chvrS?] <directory-with-tests>",
		"\t-c,--config\tPath to config file.",
		"\t-r,--reporters\tComma-separated reporters:",
		"\t\t- text: Reports as text in the terminal (default).",
		"\t\t- dots: Prints a dot for every test (very compact)",
		"\t\t- blank: Do not report any test information.",
		"\t\t- count: Prints tests counters.",
		"\t--color\tForce to use colors, if system supports colored terminal.",
		"\t--no-color\tForce to disable colors.",
		"\t-s,--summary\tForce to print report summary.",
		"\t-S,--no-summary\tDo not report summary.",
		"\t--coverage\tForce to enable code coverage report.",
		"\t--no-coverage\tForce to disable code coverage report.",
		"\t--version\tPrint program name and it's version.",
		"\t-h,-?,--help\tPrint this help message.",
		"",
	}, EOL))
end

---@param ...string
---@return boolean
local function hasFlag(...)
	for _, a in ipairs(_G.arg) do
		for _, f in ipairs({ ... }) do
			if f == a then
				return true
			end
		end
	end
	return false
end

---@retrn number exit code, if exit code is negative, do not quit programm.
local function processFlags(flags)
	-- Very dirty and primitive arguments parsing.
	for i in ipairs(flags) do
		if hasFlag(flags, "-h", "-?", "--help") then
			usage()
			return ctx.config._Exit.OK
		end

		if hasFlag("-v", "--version") then
			print(string.format("%s v%s", ctx.config._appKey, version()))
			return ctx.config._Exit.OK
		end

		if hasFlag("-c", "--config") then
			local path = flags[i + 1]
			if path == nil then
				if type(warn) == "function" then
					warn(Labels.ErrorConfigFilePath)
				end
				return ctx.config._Exit.Failed
			end
			fs.mergeFromConfigFile(path)
		end

		if hasFlag("--color") then
			ctx.config.Color = true
		end
		if hasFlag("--no-color") then
			ctx.config.Color = false
		end

		if hasFlag("-r", "--reporters") then
			local reportersStr = flags[i + 1]
			if reportersStr == nil then
				if type(warn) == "function" then
					warn(Labels.WarningNoReporters)
				end
				ctx.config.Reporters = {}
			else
				local rs = stringx.split(reportersStr, ",;")
				for j in ipairs(rs) do
					rs[j] = stringx.trim(rs[j])
				end
				ctx.config.Reporters = rs
			end
		end
		if hasFlag("-S", "--no-summary") then
			ctx.config.ReportSummary = false
		end
		if hasFlag("-s", "--summary") then
			ctx.config.ReportSummary = true
		end
		if hasFlag("--coverage") then
			ctx.config.Coverage.Enabled = true
		end
		if hasFlag("--no-coverage") then
			ctx.config.Coverage.Enabled = false
		end
	end
	return -1
end

---Reads and merges configuration from .laurarc file.
---@return (table|nil), (Error|string|nil)?
local function readFromRCFile()
	local path = ctx.config._rcFile
	local env = {}
	local chunk, err = loadfile(path, "t", env)
	if chunk ~= nil then
		chunk()
		return env, nil
	else
		return nil, err
	end
end

return {
	hasFlag = hasFlag,
	processFlags = processFlags,
	readFromRCFile = readFromRCFile,
	spairs = spairs,
	tab = tab,
	usage = usage,
	version = version,
}
