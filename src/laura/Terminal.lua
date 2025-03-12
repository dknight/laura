local Context = require("laura.Context")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local osx = require("laura.ext.osx")
local Status = require("laura.Status")
local fs = require("laura.util.fs")

local ctx = Context.global()
local EOL = fs.EOL

---@alias Style {[key: string]: number}
---@enum Style
local Style = {
	Normal = 0,
	Bold = 1,
	Dim = 2,
	Italic = 3,
	Underlined = 4,
	Blinking = 5,
	Reverse = 7,
	Invisible = 8,
}

setmetatable(Style, {
	__index = function(_, key)
		error(string.format(Labels.ErrorEnumKey, tostring(key), "Style"), 2)
	end,
})

---@enum Color
local Color = {
	[Status.Passed] = "32",
	[Status.Failed] = "31",
	[Status.Skipped] = "2;36",
	[Status.Common] = "1;1",
	[Status.Unchanged] = "90",
	[Status.Warning] = "33",
}

setmetatable(Color, {
	__index = function(_, key)
		error(string.format(Labels.ErrorEnumKey, tostring(key), "Color"), 2)
	end,
})

---Runs `tput colors` command and get color count
---@return boolean
local function testTputColors()
	if osx.isWindows() then
		return false
	end
	-- vt100 should return 8 for colors as the last fallback.
	local term = os.getenv("TERM") or "vt100"
	local fd, err = io.popen(string.format("tput -T %s colors", term), "r")
	if fd ~= nil then
		if type(warn) == "function" then
			warn(tostring(err))
		end
		return false
	end
	local colorsNum = -1
	if fd ~= nil then
		colorsNum = fd:read("*n")
		fd:close()
	end
	if colorsNum == nil then
		return false
	end
	return colorsNum > 1
end

local hasTermColors = testTputColors()

---Checks that termianl supports colors. If in config 'color' set to false
---the function ignores all checks and return false immideatly.
---@return boolean
local function isColorSupported()
	if not ctx.config.Color then
		return false
	end
	if osx.isWindows() then
		return not not os.getenv("ANSICON")
	end

	local term = os.getenv("TERM") or ""
	return not not (
		term:match("color")
		or term:match("xterm")
		or hasTermColors
	)
end

---@return string
local function reset()
	if isColorSupported() then
		return "\27[0m"
	end
	return ""
end

---@param status Status
---@return string
local function setColor(status)
	if isColorSupported() then
		return string.format("\27[%sm", Color[status])
	end
	return ""
end

---@param msg string
---@param ... Style
local function setStyle(msg, ...)
	if isColorSupported() then
		local styles = table.concat({ ... }, ";")
		msg = "\27[" .. styles .. "m" .. msg .. "\27[0m"
	end
	return msg
end

---@param msg string
---@param ... Style
local function printStyle(msg, ...)
	io.write(setStyle(msg .. EOL, ...))
end

---@param flag boolean
local function toggleCursor(flag)
	if flag then
		io.write("\027[?25l")
	else
		io.write("\027[?25h")
	end
end

---@param message string
---@param status Status
---@param suffix? string
---@param level? number
local function printResult(message, status, suffix, level)
	level = level or 0
	suffix = suffix or ""
	local tpl = "%s%s%s" .. EOL
	if status ~= Status.Common then
		tpl = "%s[%s] %s%s" .. EOL
	end
	if status == Status.Skipped then
		tpl = "%s"
			.. setStyle("[", Style.Dim)
			.. "%s"
			.. setStyle("] %s%s" .. EOL, Style.Dim)
	end
	local str = string.format(
		tpl,
		helpers.tab(level),
		setColor(status) .. Labels.Statuses[status] .. reset(),
		message,
		suffix
	)
	io.write(str)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printExpected(msg, suffix, level)
	printResult(msg, Status.Passed, suffix, level)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printActual(msg, suffix, level)
	printResult(msg, Status.Failed, suffix, level)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printSkipped(msg, suffix, level)
	printResult(msg, Status.Skipped, suffix, level)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printWarning(msg, suffix, level)
	printResult(msg, Status.Warning, suffix, level)
end

---Restores terminal styling, if was changed.
local function restore()
	if isColorSupported() then
		toggleCursor(false)
		reset()
	end
end

---@enum Terminal
local Terminal = {
	isColorSupported = isColorSupported,
	printActual = printActual,
	printExpected = printExpected,
	printResult = printResult,
	printSkipped = printSkipped,
	printStyle = printStyle,
	printWarning = printWarning,
	reset = reset,
	restore = restore,
	setColor = setColor,
	setStyle = setStyle,
	Color = Color,
	Style = Style,
	toggleCursor = toggleCursor,
}

return Terminal
