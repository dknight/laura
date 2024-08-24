local config = require("config")
local osx = require("lib.ext.osx")

---Checks that termianl supports colors. If in config file 'color' set to false
---the function ignores all checks and return false immideatly.
---@return boolean
local function isColorSupported()
	if not config.color then
		return false
	end
	if osx.isWindows() then
		return not not os.getenv("ANSICON")
	end
	return true
end

return {
	isColorSupported = isColorSupported,
}
