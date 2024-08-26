local Context = require("lib.classes.Context")
local constants = require("lib.util.constants")

local ctx = Context.global()

---Sort table by keys in alphabetical order.
---@param t table
---@param sortFn? fun(t:table, a: any, b: any): boolean
---@retrn fun(): string | number, any
local function spairs(t, sortFn)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if type(sortFn) == "function" then
		table.sort(keys, function(a, b)
			return sortFn(t, a, b)
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

---Print n indentations.
---@param n number
---@string
local function tab(n)
	return string.rep(ctx.config.tab, n)
end

---Read version number from file VERSION.
---@return string
local function version()
	local fd, err = io.open("VERSION")
	if fd ~= nil then
		local contents = fd:read("*a")
		fd:close()
		return contents
	else
		error(err)
	end
end

---Prints usage in terminal.
local function usage()
	print(table.concat({
		string.format("%s v%s", constants.appKey, version()),
		"Usage: laura [-chv?] <directory-with-tests>",
		"\t" .. "-c, --config\tPath to config file.",
		"\t" .. "-v, --version\tPrint program name and it's version.",
		"\t" .. "-h, -?, --help\tPrint the usage.",
	}, "\n"))
end

return {
	spairs = spairs,
	tab = tab,
	usage = usage,
	version = version,
}
