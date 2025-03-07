local Context = require("laura.Context")
local Labels = require("laura.Labels")
local osx = require("laura.ext.osx")
local stringx = require("laura.ext.stringx")

local ctx = Context.global()
local isWindows = osx.isWindows
local PathSep = isWindows() and "\\" or "/"
local EOL = isWindows() and "\r\n" or "\n"

---@param directory string
---@return {[number]: string}
local scandir = function(directory)
	local cmd
	if isWindows() then
		cmd = "DIR /S /B /O:n %s\\%s"
	else
		cmd = "find '%s' -type f -name '%s' -print | sort"
	end
	local t = {}
	local fd =
		assert(io.popen((cmd):format(directory, ctx.config.TestPattern), "r"))
	local list = fd:read("*a")
	fd:close()

	for _, fname in pairs(stringx.split(list, EOL)) do
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

---Checks that file or directory exists.
---@param file string
---@return boolean, (string|nil)?
local function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			return true, nil
		end
	end
	return not not ok, err
end

---Check if a directory exists in this path
---@Param path string
---@return boolean
local function isdir(path)
	return exists(path .. PathSep)
end

---Read config from the path.
---@param path string
---@return boolean
local function mergeFromConfigFile(path)
	local chunk, err = loadfile(path, "t")
	if not exists(path) then
		return false
	end
	if chunk ~= nil then
		local res = chunk() or {}
		for k, v in pairs(res) do
			if ctx.config[k] ~= nil then
				ctx.config[k] = v
			end
		end
	else
		error(Labels.ErrorConfigRead .. EOL .. err)
	end
	return true
end

---@param path string
---@return boolean?, exitcode?, integer?
local function mkdir(path)
	local cmd
	if isWindows() then
		cmd = "MKDIR " .. path .. " 2>NUL"
	else
		cmd = "mkdir " .. path .. " &>/dev/null"
	end
	return os.execute(cmd)
end

---Not in use, maybe will be useful, but it to dangerous to dive
---software to remove something with `rm -rf`.
-- local function rmdir(path)
-- if isWindows() then
-- cmd = "RMDIR /Q /S " .. path .. " 2>NUL"
-- else
-- cmd = "rm -r " .. path .. " &>/dev/null"
-- end
-- return os.execute(cmd)
-- end

return {
	EOL = EOL,
	exists = exists,
	getFiles = getFiles,
	isdir = isdir,
	mergeFromConfigFile = mergeFromConfigFile,
	mkdir = mkdir,
	PathSep = PathSep,
	scandir = scandir,
}
