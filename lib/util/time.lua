---Time related helpers.

---TODO FIXME formatting is wrong minutes show instead of nanosecs
---
---Formats C's clock function to the human readable format.
---Time is very relative, depending one OS processes and other factors.
---Output of this function is very approximate.
---@param seconds number
---@return string
local function format(seconds)
	local unit = "μs"
	local n = seconds * 1000000
	local digits = 0
	if n >= 1000 then
		n = n / 1000
		unit = "ms"
		digits = 0
	end
	if n >= 1000 then
		n = n / 1000
		unit = "s"
		digits = 2
	end
	if n >= 60 then
		n = n / 60
		unit = "m"
		digits = 2
	end
	if n >= 60 then
		n = n / 60
		unit = "h"
		digits = 2
	end

	return string.format("%." .. digits .. "f%s", n, unit)
end

return {
	format = format,
}
