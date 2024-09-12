local Context = require("lib.Context")
local helpers = require("lib.util.helpers")
local Labels = require("lib.Labels")
local osx = require("lib.ext.osx")
local Status = require("lib.Status")

local ctx = Context.global()

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
	[Status.passed] = "32",
	[Status.failed] = "31",
	[Status.skipped] = "2;36",
	[Status.common] = "1;1",
	[Status.unchanged] = "90",
}

setmetatable(Color, {
	__index = function(_, key)
		error(string.format(Labels.ErrorEnumKey, tostring(key), "Color"), 2)
	end,
})

---Runs `tput colors` command and get color count
---@return boolean
local function testTputColors()
	local fd = io.popen("tput colors", "r")
	local colorsNum = 0
	if fd ~= nil then
		colorsNum = fd:read("*n")
		fd:close()
	end
	return colorsNum > 0
end

local colorsNum = testTputColors()

---Checks that termianl supports colors. If in config file 'color' set to false
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
	return term:match("color") or os.getenv("LS_COLORS") or colorsNum
end

---@return string
local function resetColor()
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

---Sets terminal styles.
---@param msg string
---@param ... Style
local function setStyle(msg, ...)
	if isColorSupported() then
		local styles = table.concat({ ... }, ";")
		msg = "\27[" .. styles .. "m" .. msg .. "\27[0m"
	end
	return msg
end

---Prints out styles in the terminal.
---@param msg string
---@param ... Style
local function printStyle(msg, ...)
	io.write(setStyle(msg .. "\n", ...))
end

---Toggle the terminal cursor
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
	local tpl = "%s%s%s\n"
	if status ~= Status.common then
		tpl = "%s[%s] %s%s\n"
	end
	if status == Status.skipped then
		tpl = "%s"
			.. setStyle("[", Style.Dim)
			.. "%s"
			.. setStyle("] %s%s\n", Style.Dim)
	end
	local str = string.format(
		tpl,
		helpers.tab(level),
		setColor(status) .. Labels.Statuses[status] .. resetColor(),
		message,
		suffix
	)
	io.write(str)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printExpected(msg, suffix, level)
	printResult(msg, Status.passed, suffix, level)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printActual(msg, suffix, level)
	printResult(msg, Status.failed, suffix, level)
end

---@param msg string
---@param suffix? string
---@param level? number
local function printSkipped(msg, suffix, level)
	printResult(msg, Status.skipped, suffix, level)
end

---Restores terminal, if was changed.
local function restore()
	toggleCursor(false)
	resetColor()
end

---@enum Terminal
local Terminal = {
	color = Color,
	isColorSupported = isColorSupported,
	printActual = printActual,
	printExpected = printExpected,
	printResult = printResult,
	printSkipped = printSkipped,
	printStyle = printStyle,
	resetColor = resetColor,
	setColor = setColor,
	style = Style,
	restore = restore,
	toggleCursor = toggleCursor,
}

return Terminal