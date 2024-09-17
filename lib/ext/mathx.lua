---Compatible with different Lua versions power function.
---@param a number
---@param b number
local function pow(a, b)
	local ok, x = pcall(math.pow, a, b)
	if ok then
		return x
	end
	return a ^ b
end

return {
	pow = pow,
}
