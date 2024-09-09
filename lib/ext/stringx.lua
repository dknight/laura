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
---@return string
local function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

return {
	split = split,
	trim = trim,
}
