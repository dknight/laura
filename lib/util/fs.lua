local Context = require("lib.Context")
local Labels = require("lib.Labels")
local osx = require("lib.ext.osx")

local ctx = Context.global()

-- TDOO checks for read failed
---@param directory string
---@return {[number]: string}
local scandir = function(directory)
	local cmd
	if osx.isWindows() then
		cmd = "DIR /S/B/O:n %s\\%s"
	else
		cmd = "find '%s' -type f -name '%s' -print0 | sort"
	end
	local t = {}
	local fd =
		assert(io.popen((cmd):format(directory, ctx.config.FilePattern), "r"))
	local list = fd:read("*a")
	fd:close()

	-- [^\n\0]+ carefully for new lines
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

---Checks that file exists,
---@param file string
---@return boolean, string?
local function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			return true, nil
		end
	end
	return ok, err
end

---Check if a directory exists in this path
---@Param path string
---@return boolean
local function isdir(path)
	return exists(path .. "/")
end

---Read config from the path.
---@param path string
local function mergeFromConfigFile(path)
	local chunk, err = loadfile(path, "t")
	if chunk ~= nil then
		for k, v in pairs(chunk()) do
			if ctx.config[k] ~= nil then
				ctx.config[k] = v
			end
		end
	else
		error(Labels.ErrorConfigRead .. err)
	end
end

return {
	exists = exists,
	getFiles = getFiles,
	isDir = isdir,
	scandir = scandir,
	mergeFromConfigFile = mergeFromConfigFile,
}
