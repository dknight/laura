---@alias Printer fun(msg: string, ...?: (string|nil)): nil

local config = require("config")
local context = require("lib.context")
local sys = require("lib.util.sys")
local Status = require("lib.status")
local helpers = require("lib.util.helpers")

local ctx = context.global()

---@enum termStyles
local termStyles = {
	normalStyle = 0,
	bold = 1,
	dim = 2,
	italic = 3,
	underlined = 4,
	blinking = 5,
	reverse = 7,
	invisible = 8,
}
---@enum colors
local colors = {
	[Status.expected] = "32",
	[Status.actual] = "31",
	[Status.skipped] = "0;36",
	[Status.common] = "1;1",
	[Status.unchanged] = "90",
}

---@return string
local resetColor = function()
	if sys.isColorSupported() then
		return "\27[0m"
	end
	return ""
end

---@param status Status
---@return string
local function setColor(status)
	if sys.isColorSupported() then
		return string.format("\27[%sm", colors[status])
	end
	return ""
end

---@param message string
---@param status Status
---@param suffix? string | nil
---@param level? number
local printResult = function(message, status, suffix, level)
	level = level or 0
	suffix = suffix or ""
	local tpl = string.rep(config.tab, ctx.level)
	if status ~= Status.common then
		tpl = tpl .. "%s[%s] %s%s\n"
	else
		tpl = tpl .. "%s%s%s\n"
	end
	local str = string.format(
		tpl,
		helpers.tab(level),
		setColor(status) .. status .. resetColor(),
		message,
		suffix
	)
	io.write(str)
end

---@type {printExpected: Printer, printActual: Printer, printSkipped: Printer, printStyle: fun(msg: string, ...?: termStyles), setColor: fun(status: Status): string, resetColor: fun(): string, statuses: Status, termStyles: termStyles}
return {
	printExpected = function(msg, suffix, level)
		printResult(msg, Status.expected, suffix, level)
	end,

	printActual = function(msg, suffix, level)
		printResult(msg, Status.actual, suffix, level)
	end,

	printSkipped = function(msg, suffix, level)
		printResult(msg, Status.skipped, suffix, level)
	end,

	--Prints out different styles in the terminal.
	---@param msg string
	---@param ... termStyles
	printStyle = function(msg, ...)
		if sys.isColorSupported() then
			local sts = table.concat({ ... }, ";")
			io.write("\27[" .. sts .. "m" .. msg .. "\27[0m\n")
		else
			io.write(msg .. "\n")
		end
	end,

	resetColor = resetColor,
	setColor = setColor,
	termStyles = termStyles,
}
