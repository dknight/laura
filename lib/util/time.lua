---Time related helpers.

---Formats C's clock function to the human readable format.
---Time is very relative, depending one OS processes and other factors.
---Output of this function is very approximate.
---@param secs number
---@return string
local function format(secs)
	local unit = "μs"
	local micros = secs * 1000000
	local n = micros
	local digits = 0
	if micros >= 1000 then
		n = n / 1000
		unit = "ms"
		digits = 1
	end

	if micros >= 1000000 then
		n = micros / 1000000
		unit = "s"
		digits = 1
	end

	if micros >= 1000000 * 60 then
		n = micros / 1000000 * 60
		unit = "m"
		digits = 2
	end

	if micros >= 1000000 * 60 * 60 then
		n = micros / 1000000 * 60 * 60
		unit = "h"
		digits = 2
	end

	return string.format("%." .. digits .. "f%s", n, unit)
end

---Formats time to string
---@param secs number
---@param pattern string
---@return string
local function toString(secs, pattern)
	pattern = pattern or "%s"
	return string.format(pattern, format(secs))
end

return {
	format = format,
	toString = toString,
}
