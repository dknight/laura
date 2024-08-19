---Checks that OS is Microsoft Windows.
---@return boolean
local function isWindows()
	return type(package) == "table"
		and type(package.config) == "string"
		and package.config:sub(1, 1) == "\\"
end

---Checks that termianl supports colors.
---@return boolean
local function isColorSupported()
	if isWindows() then
		return not not os.getenv("ANSICON")
	end
	return true
end

return {
	isWindows = isWindows,
	isColorSupported = isColorSupported,
}
