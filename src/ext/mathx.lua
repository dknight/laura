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

---Compatible with different Lua versions math.type function.
---@param a number
---@return string | nil
local function typex(a)
	if type(a) ~= "number" then
		return nil
	else
		return a % 1 == 0 and "integer" or "float"
	end
end

return {
	pow = pow,
	type = math.type == "function" and math.type or typex,
}
