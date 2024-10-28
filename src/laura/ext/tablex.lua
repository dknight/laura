---@alias DiffResults {del?: table, mod?: table, sub?: table}
---@alias DiffCount {added: number, removed: number}

local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local Status = require("laura.Status")
local Terminal = require("laura.Terminal")
local Version = require("laura.Version")

local spairs = helpers.spairs
local tab = helpers.tab

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

---@param a table
---@param b table
---@return boolean
local function equal(a, b)
	local d = diff(a, b)
	return d.mod == nil and d.sub == nil and d.del == nil
end

---@param val any Value to be printed.
---@param key string | number Key to be printed.
---@param sign string Added, removed or unchanged sign.
---@param status Status Status of the difference.
---@param i number Indentation level
local function printValue(val, key, sign, status, i)
	i = i or 0
	local out = {}

	if type(val) == "table" then
		out[#out + 1] = "\n" .. tab(i) .. sign .. "{\n"
		i = i + 1
		for k, v in pairs(val) do
			out[#out + 1] = string.format(
				"%s%s%s[%q] = %q,\n",
				tab(i - 1),
				sign,
				tab(1),
				k,
				v
			)
		end
		i = i - 1
		out[#out + 1] = tab(i) .. sign .. "}"
	else
		out[#out + 1] = string.format("%q", val)
	end

	return Terminal.setColor(status)
		.. string.format(
			"%s%s[%q] = %s\n",
			tab(i),
			sign,
			key,
			table.concat(out)
		)
		.. Terminal.reset()
end

---@param t table Table to print
---@param d table Table with difference
---@param i number Start indentation level
---@return string
local function diffToString(t, d, i)
	i = i or 0
	local out = { tab(i), "{\n" }
	i = i + 1

	local patched = patch(t, d)

	for k in spairs(patched) do
		local isKeyChanged = false

		-- Deletions
		if d.del ~= nil and d.del[k] ~= nil then
			out[#out + 1] =
				printValue(t[k], k, Labels.AddedSymbol, Status.Failed, i)
			isKeyChanged = true
		end

		-- Modifications
		if d.mod ~= nil and d.mod[k] ~= nil then
			out[#out + 1] =
				printValue(d.mod[k], k, Labels.RemovedSymbol, Status.Passed, i)

			if t[k] ~= nil then
				out[#out + 1] =
					printValue(t[k], k, Labels.AddedSymbol, Status.Failed, i)
			end
			isKeyChanged = true
		end

		-- Sub-tables
		if d.sub ~= nil and d.sub[k] ~= nil then
			out[#out + 1] = string.format("%s[%q] = \n", tab(i), k)
			out[#out + 1] = diffToString(t[k], d.sub[k], i)
			isKeyChanged = true
		end

		-- Not changed
		if not isKeyChanged then
			out[#out + 1] =
				printValue(t[k], k, Labels.UnchangedSymbol, Status.Unchanged, i)
		end
	end
	i = i - 1
	out[#out + 1] = tab(i)
	out[#out + 1] = "}\n"
	return table.concat(out)
end

---@param t table
---@oaram function(v: any, index?: number): boolean
---@return table
local function filter(t, predicate)
	local newt = {}
	local i = 0
	for _, v in pairs(t) do
		i = i + 1
		if predicate(v, i) then
			newt[#newt + 1] = v
		end
	end
	return newt
end

---@param t table
---@param keys? boolean
---@return string
local function inline(t, keys)
	local out = {}
	for i = 1, #t do
		local fmt = "%s%s"
		if type(t[i]) == "string" then
			fmt = '%s"%s"'
		end
		if Version[_VERSION] == Version["Lua 5.1"] then
			t[i] = tostring(t[i])
		end
		out[#out + 1] = string.format(fmt, keys and (i .. " = ") or "", t[i])
	end
	return "{ " .. table.concat(out, ", ") .. " }"
end

---Very simple table dump
---@param t table | string
---@return string
local function dumbDump(t)
	if type(t) == "table" then
		local s = "{\n"
		for k, v in pairs(t) do
			if type(k) == "string" then
				k = '"' .. k .. '"'
			end
			if type(v) == "string" then
				v = string.format("%q", v)
			end
			s = s .. "[" .. k .. "] = " .. dumbDump(v) .. ","
		end
		return s .. "}\n"
	else
		return tostring(t)
	end
end

return {
	diff = diff,
	diffToString = diffToString,
	dump = dumbDump,
	equal = equal,
	filter = filter,
	inline = inline,
	patch = patch,
}
