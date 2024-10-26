---Compatible with different Lua versions power function.
---@param a number
---@param b number
---@return number
local function pow(a, b)
	---@diagnostic disable-next-line: deprecated
	local ok, x = pcall(math.pow, a, b)
	if ok then
		return x
	end
	return a ^ b
end

return {
	pow = pow,
}
