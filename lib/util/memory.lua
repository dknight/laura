---Memory related helpers.

---Formats kilobytes into other units.
---@param kb number
---@return string
local function format(kb)
	local unit = "Kb"
	local n = kb
	if kb >= 1024 then -- 2 ^ 10
		n = n / 1024
		unit = "mb"
	end

	if kb >= 1048576 then -- 2 ^ 20
		n = n / 1048576
		unit = "gb"
	end

	return string.format("%." .. 2 .. "f%s", n, unit)
end

return {
	format = format,
}
