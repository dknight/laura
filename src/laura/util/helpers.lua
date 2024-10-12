local Context = require("laura.Context")
local fs = require("laura.util.fs")
local Labels = require("laura.Labels")
local stringx = require("laura.ext.stringx")

local ctx = Context.global()

---Get the version.
---@return string
local function version()
	return "0.9.0-3"
end

---Sort table by keys in alphabetical order.
---@param t table
---@param sortFunc? fun(t:table, a: any, b: any): boolean
---@retrn fun(): string | number, any
local function spairs(t, sortFunc)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if type(sortFunc) == "function" then
		table.sort(keys, function(a, b)
			return sortFunc(t, a, b)
		end)
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
	print(table.concat({
		string.format("Laura %s", version()),
		"Usage: laura [-chvrS?] <directory-with-tests>",
		"\t" .. "-c,--config\tPath to config file.",
		"\t" .. "-r,--reporters\tComma-separated reporters:",
		"\t\t" .. "- text : Reports as text in the terminal (default).",
		"\t\t" .. "- dots : Prints a dot for every test (very compact)",
		"\t\t" .. "- blank : Do not report any test information.",
		"\t\t" .. "- count : Prints tests counters.",
		"",
		"\t"
			.. "--color\tForce to use colors, if system supports colored terminal.",
		"\t" .. "--nocolor\tForce to disable colors.",
		"\t" .. "-S,--nosummary\tDo not report summary.",
		"\t" .. "--coverage\tForce to enable code coverage report.",
		"\t" .. "--nocoverage\tForce to disable code coverage report.",
		"\t" .. "-v,--version\tPrint program name and it's version.",
		"\t" .. "-h,-?,--help\tPrint this help message.",
	}, "\n"))
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

local function processFlags()
	-- Very dirty and primitive arguments parsing.
	for i, flag in ipairs(arg) do
		if hasFlag("-h", "-?", "--help") then
			usage()
			os.exit(ctx.config._exitOK)
		end

		if hasFlag("-v", "--version") then
			print(string.format("%s v%s", ctx.config._appKey, version()))
			os.exit(ctx.config._exitOK)
		end

		if hasFlag("-c", "--config") then
			local path = arg[i + 1]
			if path == nil then
				error(Labels.ErrorConfigFilePath)
			end
			fs.mergeFromConfigFile(path)
		end

		if hasFlag("--color") then
			ctx.config.Color = true
		end
		if hasFlag("--nocolor") then
			ctx.config.Color = false
		end

		if hasFlag("-r", "--reporters") then
			local reportersStr = arg[i + 1]
			if reportersStr == nil then
				warn(Labels.WarningNoReporters)
				ctx.config.Reporters = {}
			else
				local rs = stringx.split(reportersStr, ",;")
				for j in ipairs(rs) do
					rs[j] = stringx.trim(rs[j])
				end
				ctx.config.Reporters = rs
			end
		end
		if hasFlag("-S", "--nosummary") then
			ctx.config.ReportSummary = false
		end
		if hasFlag("--coverage") then
			ctx.config.Coverage.Enabled = true
		end
		if hasFlag("--nocoverage") then
			ctx.config.Coverage.Enabled = false
		end
	end
end

return {
	hasFlag = hasFlag,
	processFlags = processFlags,
	spairs = spairs,
	tab = tab,
	usage = usage,
	version = version,
}
