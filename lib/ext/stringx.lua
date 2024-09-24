local Version = require("lib.Version")
---@param str string
---@param sep? string
---@return string[]
local function split(str, sep)
	sep = sep or ""
	local t = {}
	for s in string.gmatch(str, "([^" .. sep .. "]+)") do
		t[#t + 1] = s
	end
	return t
end

---@param str string
---@return string, number
local function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

---@param str string
---@param useUTF8? boolean
---@return number
local function len(str, useUTF8)
	--COMPAT there is no utf8 in Lua before 5.2
	if Version[_VERSION] <= Version["Lua 5.2"] then
		useUTF8 = false
	end
	return useUTF8 and utf8.len(str) or string.len(str)
end

return {
	len = len,
	split = split,
	trim = trim,
}
