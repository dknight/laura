---@alias Config{appKey: string, color: boolean, dir: string, exitFailed: number, exitPass: number, filePattern: string, tab: string, traceback: boolean }

---@type Config
local config = {
	appKey = "aura",
	color = true,
	dir = ".",
	exitFailed = 1,
	exitPass = 0,
	filePattern = "*_test.lua",
	tab = "\t",
	traceback = false,
}

return config
