---@alias Config{appKey: string, color: boolean, dir: string, exitFailed: number, exitPass: number, filePattern: string, tab: string, traceback: boolean }

---@type Config
local config = {
	appKey = "Laura",
	color = true,
	dir = ".",
	exitFailed = 1,
	exitOk = 0,
	filePattern = "*_test.lua",
	tab = "\t",
	traceback = false,
}

return config
