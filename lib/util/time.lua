---Time related module.
return {
	---Formats C's clock function to the human readable format.
	---Time is very relative, depending one OS processes and other factors.
	---Output of this function is very approximate.
	---@param s number
	---@return string
	format = function(s)
		local unit = "μs"
		local n = s * 1000000
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
	end,
}
