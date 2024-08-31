local Context = require("lib.classes.Context")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local osx = require("lib.ext.osx")
local Status = require("lib.classes.Status")

local ctx = Context.global()

---@enum style
local Style = {
	Normal = 0,
	Bold = 10,
	Dim = 100,
	Italic = 1000,
	Underlined = 10000,
	Blinking = 100000,
	Reverse = 1000000,
	Invisible = 10000000,
}

---@enum colors
local Color = {
	[Status.Passed] = "32",
	[Status.Failed] = "31",
	[Status.Skipped] = "0;36",
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
	return ""
end

---@param message string
---@param status Status
---@param suffix? string | nil
---@param level? number
local function printResult(message, status, suffix, level)
	level = level or 0
	suffix = suffix or ""
	local tpl = ""
	if status ~= Status.Common then
		tpl = tpl .. "%s[%s] %s%s\n"
	else
		tpl = tpl .. "%s%s%s\n"
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

---Prints out styles in the terminal.
---@param msg string
---@param ... style
local function printStyle(msg, ...)
	if isColorSupported() then
		local styles = table.concat({ ... }, ";")
		io.write("\27[" .. styles .. "m" .. msg .. "\27[0m\n")
	else
		io.write(msg .. "\n")
	end
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
