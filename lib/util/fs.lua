local config = require("config")
local osx = require("lib.ext.osx")

-- TDOO checks for read failed
---@param directory string
---@return table{[number]: string}
local scandir = function(directory)
	local cmd
	if osx.isWindows() then
		cmd = "DIR /S/B/O:n %s\\%s"
	else
		cmd = "find '%s' -type f -name '%s' -print0 | sort"
	end
	local t = {}
	local fd =
		assert(io.popen((cmd):format(directory, config.filePattern), "r"))
	local list = fd:read("*a")
	fd:close()

	-- [^\n\0]+ carefully fir new lines
	for fname in list:gmatch("[^\n\0]+") do
		t[fname] = true
	end
	return t
end

---Gets test files list from given pattern.
---@param pattern string
---@return {[string]: boolean}, number
local function getFiles(pattern)
	local files = {}
	local i = 0
	for d in string.gmatch(pattern, "([^:]+)") do
		for fname in pairs(scandir(d)) do
			files[fname] = true
			i = i + 1
		end
	end
	return files, i
end

return {
	scandir = scandir,
	getFiles = getFiles,
}
