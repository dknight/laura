---@alias DiffResults table{del: table|nil, mod: table|nil, sub: table|nil}
---@alias DiffCount table{added: number, remove: number}

local labels = require("lib.labels")
local helpers = require("lib.util.helpers")
local printer = require("lib.printer")

local spairs = helpers.spairs
local tab = helpers.tab

---Returnts the result difference from two tales.
---@param a table
---@param b table
---@param count? DiffCount
---@return DiffResults, DiffCount
local function diff(a, b, count)
	---@type DiffResults
	local df = { del = {}, mod = {}, sub = {} }
	---@type DiffCount
	count = count or { added = 0, removed = 0 }

	for k, v in pairs(a) do
		if b[k] ~= nil and type(a[k]) == "table" and type(b[k]) == "table" then
			df.sub[k] = diff(a[k], b[k], count)
			if next(df.sub[k]) == nil then
				df.sub[k] = nil
			end
			count.added = count.added + 1
		elseif b[k] == nil then
			df.del[k] = true
			count.added = count.added + 1
		elseif b[k] ~= v then
			df.mod[k] = b[k]
			count.added = count.added + 1
		end
	end

	for k, v in pairs(b) do
		if df.sub[k] ~= nil then
			count.removed = count.removed + 1
		elseif
			a[k] ~= nil
			and type(a[k]) == "table"
			and type(b[k]) == "table"
		then
			df.sub[k] = diff(b[k], a[k], count)
			if next(df.sub[k]) == nil then
				df.sub[k] = nil
			end
			count.removed = count.removed + 1
		elseif b[k] ~= a[k] then
			df.mod[k] = v
			count.removed = count.removed + 1
		end
	end

	-- Should be faster than check length every time.
	if next(df.sub) == nil then
		df.sub = nil
	end

	if next(df.mod) == nil then
		df.mod = nil
	end

	if next(df.del) == nil then
		df.del = nil
	end

	return df, count
end

---Creates new table from source table and difference table.
---@param a table
---@param d DiffResults
---@return table
local function patch(a, d)
	local t = {}
	for k, v in pairs(a) do
		t[k] = v
	end
	if d.sub ~= nil then
		for k, v in pairs(d.sub) do
			t[k] = patch(a[k], v)
		end
	end

	if d.del ~= nil then
		for _, v in pairs(d.del) do
			t[v] = nil
		end
	end

	if d.mod ~= nil then
		for k, v in pairs(d.mod) do
			t[k] = v
		end
	end
	return t
end

---Comapares two tables for deep equality.
---@param a table
---@param b table
---@return boolean
local function equal(a, b)
	local d = diff(a, b)
	return d.mod == nil and d.sub == nil and d.del == nil
end

---Prints the value, if table prints table as string.
---@param val any Value to be printed.
---@param key string | number Key to be printerd.
---@param sign string Added, removed or unchanged sign.
---@param status statuses Status of the difference.
---@param i number Indentation level
local function printValue(val, key, sign, status, i)
	i = i or 0
	local out = ""

	if type(val) == "table" then
		out = "\n" .. tab(i) .. sign .. "{\n"
		i = i + 1
		for k, v in pairs(val) do
			out = out
				.. string.format(
					"%s%s%s[%q] = %s,\n",
					tab(i - 1),
					sign,
					tab(1),
					k,
					v
				)
		end
		i = i - 1
		out = out .. tab(i) .. sign .. "}"
	else
		out = out .. string.format("%q", val)
	end

	return printer.setColor(status)
		.. string.format("%s%s[%q] = %s\n", tab(i), sign, key, out)
		.. printer.resetColor()
end

---@param t table Table to print
---@param d table Table with difference
---@param i number Start indentation level
---@return string
local function printDiff(t, d, i)
	i = i or 0
	local out = tab(i) .. "{\n"
	i = i + 1

	local patched = patch(t, d)

	for k in spairs(patched) do
		local isKeyChanged = false

		-- Deletions
		if d.del ~= nil and d.del[k] ~= nil then
			out = out
				.. printValue(t[k], k, labels.added, printer.statuses.actual, i)
			isKeyChanged = true
		end

		-- Modifications
		if d.mod ~= nil and d.mod[k] ~= nil then
			out = out
				.. printValue(
					d.mod[k],
					k,
					labels.removed,
					printer.statuses.expected,
					i
				)

			if t[k] ~= nil then
				out = out
					.. printValue(
						t[k],
						k,
						labels.added,
						printer.statuses.actual,
						i
					)
			end
			isKeyChanged = true
		end

		-- Sub-tables
		if d.sub ~= nil and d.sub[k] ~= nil then
			out = out .. string.format("%s[%q] = \n", tab(i), k)
			out = out .. printDiff(t[k], d.sub[k], i)
			isKeyChanged = true
		end

		-- Not changed
		if not isKeyChanged then
			out = out
				.. printValue(
					t[k],
					k,
					labels.unchanged,
					printer.statuses.unchanged,
					i
				)
		end
	end
	i = i - 1
	return out .. tab(i) .. "}\n"
end

return {
	diff = diff,
	equal = equal,
	print = printDiff,
}
