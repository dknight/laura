---Memory related helpers.

---Formats kilobytes into other units.
---@param kb number
---@return string
local function format(kb)
	local unit = "KB"
	local n = kb
	if kb >= 1024 then -- 2 ^ 10
		n = n / 1024
		unit = "MB"
	end

	if kb >= 1048576 then -- 2 ^ 30
		n = n / 1048576
		unit = "GB"
	end

	if kb >= 1073741824 then -- 2 ^ 30
		n = n / 1073741824
		unit = "TB"
	end

	return string.format("%." .. 2 .. "f%s", n, unit)
end

return {
	format = format,
}
