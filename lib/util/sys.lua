local config = require("config")

---Checks that OS is Microsoft Windows.
---@return boolean
local function isWindows()
	return type(package) == "table"
		and type(package.config) == "string"
		and package.config:sub(1, 1) == "\\"
end

---Checks that termianl supports colors. If in config file 'color' set to false
---the function ignores all checks and return false immideatly.
---@return boolean
local function isColorSupported()
	if not config.color then
		return false
	end
	if isWindows() then
		return not not os.getenv("ANSICON")
	end
	return true
end

return {
	isWindows = isWindows,
	isColorSupported = isColorSupported,
}
