---Very dumb split string function.
---@param str string
---@param sep? string
---@return string[]
local function split(str, sep)
	sep = sep or "%s"
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

---Check article about counting utf8 sequences
---http://lua-users.org/wiki/LuaUnicode
---@param str string
---@return number
local function len(str)
	local length = 0
	for _ in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
		length = length + 1
	end
	return length
end

return {
	len = len,
	split = split,
	trim = trim,
}
