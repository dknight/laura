local Context = require("lib.classes.Context")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local osx = require("lib.ext.osx")
local Status = require("lib.classes.Status")

local ctx = Context.global()

---@enum style
local style = {
	normal = 0,
	bold = 1,
	dim = 2,
	italic = 3,
	underlined = 4,
	blinking = 5,
	reverse = 7,
	invisible = 8,
}

---@enum colors
local color = {
	[Status.passed] = "32",
	[Status.failed] = "31",
	[Status.skipped] = "2;36",
	[Status.common] = "1;1",
	[Status.unchanged] = "90",
}

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
	if not ctx.config.color then
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
		return string.format("\27[%sm", color[status])
	end
	return ""
end

---Sets terminal styles.
---@param msg string
---@param ... style
local function setStyle(msg, ...)
	if isColorSupported() then
		local styles = table.concat({ ... }, ";")
		msg = "\27[" .. styles .. "m" .. msg .. "\27[0m"
	end
	return msg
end

---Prints out styles in the terminal.
---@param msg string
---@param ... style
local function printStyle(msg, ...)
	io.write(setStyle(msg .. "\n", ...))
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
			.. setStyle("[", style.dim)
			.. "%s"
			.. setStyle("] %s%s\n", style.dim)
	end
	local str = string.format(
		tpl,
		helpers.tab(level),
		setColor(status) .. labels.statuses[status] .. resetColor(),
		message,
		suffix
	)
	io.write(str)
end

local function printExpected(msg, suffix, level)
	printResult(msg, Status.passed, suffix, level)
end

local function printActual(msg, suffix, level)
	printResult(msg, Status.failed, suffix, level)
end

local function printSkipped(msg, suffix, level)
	printResult(msg, Status.skipped, suffix, level)
end

---@enum Terminal
local Terminal = {
	color = color,
	isColorSupported = isColorSupported,
	printActual = printActual,
	printExpected = printExpected,
	printResult = printResult,
	printSkipped = printSkipped,
	printStyle = printStyle,
	resetColor = resetColor,
	setColor = setColor,
	style = style,
}

return Terminal
