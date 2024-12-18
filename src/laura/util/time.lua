---Time related helpers.

-- COMPAT Lua 5.1
-- coverage: disable
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack
-- coverage: enable

---Formats C's clock function to the human readable format.
---Time is very relative, depending one OS processes and other factors.
---Output of this function is very approximate.
---Retuns nil if the number is negative or infinite.
---@param s number
---@return string | nil
local function format(s)
	if s < 0 or math.abs(s) == math.huge then
		return nil
	end
	local second = 1000000
	local micros = s * second
	local n = micros / second
	local secs = n % 60
	n = n / 60
	local mins = n % 60
	n = n / 60
	local hours = n

	local t = { "%.0fμs", micros }
	if micros >= 1000 then
		t = { "%.0fms", secs * 1000 }
	end

	if micros >= second then
		t = { "%.0fs", math.floor(secs) }
	end

	if micros >= second * 60 then
		t = { "%.0fm%.0fs", math.floor(mins), math.floor(secs) }
	end

	if micros >= second * 60 * 60 then
		t = {
			"%.0fh%.0fm%.0fs",
			math.floor(hours),
			math.floor(mins),
			math.floor(secs),
		}
	end

	return string.format(unpack(t))
end

---Formats time to string
---@param secs number
---@param pattern string
---@return string
local function toString(secs, pattern)
	pattern = pattern or "%f"
	return string.format(pattern, format(secs))
end

return {
	format = format,
	toString = toString,
}
