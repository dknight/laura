---Checks that OS is Microsoft Windows.
---@return boolean
local function isWindows()
	return type(package) == "table"
		and type(package.config) == "string"
		and package.config:sub(1, 1) == "\\"
end

return {
	isWindows = isWindows,
}
