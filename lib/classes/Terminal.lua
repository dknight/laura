local Context = require("lib.classes.Context")
local helpers = require("lib.util.helpers")
local Labels = require("lib.labels")
local osx = require("lib.ext.osx")
local Status = require("lib.classes.Status")

local ctx = Context.global()

---@enum style
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

---@enum colors
local Color = {
	[Status.Passed] = "32",
	[Status.Failed] = "31",
	[Status.Skipped] = "2;36",
	[Status.Common] = "1;1",
	[Status.Unchanged] = "90",
}

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
	return true
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
	print(os.getenv("TERM"))
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
	if status ~= Status.Common then
		tpl = "%s[%s] %s%s\n"
	end
	if status == Status.Skipped then
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

local function printExpected(msg, suffix, level)
	printResult(msg, Status.Passed, suffix, level)
end

local function printActual(msg, suffix, level)
	printResult(msg, Status.Failed, suffix, level)
end

local function printSkipped(msg, suffix, level)
	printResult(msg, Status.Skipped, suffix, level)
end

---@enum Terminal
local Terminal = {
	Color = Color,
	isColorSupported = isColorSupported,
	printActual = printActual,
	printExpected = printExpected,
	printResult = printResult,
	printSkipped = printSkipped,
	printStyle = printStyle,
	resetColor = resetColor,
	setColor = setColor,
	Style = Style,
}

return Terminal
