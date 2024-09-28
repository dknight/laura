local Context = require("laura.Context")
local fs = require("laura.util.fs")
local Labels = require("laura.Labels")
local stringx = require("laura.ext.stringx")

local ctx = Context.global()

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

---Gets app version.
---@return string
local function version()
	return "0.1.0"
end

---Prints usage in terminal.
local function usage()
	print(table.concat({
		string.format("Laura %s", version()),
		"Usage: laura [-chvrS?] <directory-with-tests>",
		"\t" .. "-c,--config\tPath to config file.",
		"\t" .. "-v,--version\tPrint program name and it's version.",
		"\t" .. "-r,--reporters\tComma-separated reporters:",
		"\t\t" .. "- text : Reports as text in the terminal (default).",
		"\t\t" .. "- dots : Prints a dot for every test (very compact)",
		"\t\t" .. "- blank : Do not report any test information.",
		"\t\t" .. "- count : Prints tests counters.",
		"",
		"\t" .. "-S\tDo not report summary.",
		"\t" .. "-h, -?, --help\tPrint this help message.",
	}, "\n"))
end

local function processFlags()
	-- Very dirty and primitive arguments parsing.
	for k, v in ipairs(arg) do
		if v == "-h" or v == "-?" or v == "--help" then
			usage()
			os.exit(ctx.config._exitOK)
		end

		if v == "-v" or v == "--version" then
			print(string.format("%s v%s", ctx.config._appKey, version()))
			os.exit(ctx.config._exitOK)
		end

		if v == "-c" or v == "--config" then
			local path = arg[k + 1]
			if path == nil then
				error(Labels.ErrorConfigFilePath)
			end
			fs.mergeFromConfigFile(path)
		end

		if v == "-r" or v == "--reporters" then
			local reportersStr = arg[k + 1]
			if reportersStr == nil then
				warn(Labels.warningNoReporters)
				ctx.config.Reporters = {}
			else
				local rs = stringx.split(reportersStr, ",;")
				for i in ipairs(rs) do
					rs[i] = stringx.trim(rs[i])
				end
				ctx.config.Reporters = rs
			end
		end
		if v == "-S" then
			ctx.config.ReportSummary = false
		end
	end
end

return {
	processFlags = processFlags,
	spairs = spairs,
	tab = tab,
	usage = usage,
	version = version,
}
