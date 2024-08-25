local config = require("tests.config")

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
	return string.rep(config.tab, n)
end

return {
	spairs = spairs,
	tab = tab,
}
