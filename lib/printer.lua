---@alias Printer fun(msg: string, ...?: (string|nil)): nil

local config = require("config")
local context = require("lib.context")
local sys = require("lib.util.sys")

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

---@enum statuses
local statuses = {
	expected = "OK",
	actual = "FAILED",
	skipped = "SKIPPED",
	common = "COMMON",
	unchanged = "UNCHANGED",
}

---@enum colors
local colors = {
	[statuses.expected] = "32",
	[statuses.actual] = "31",
	[statuses.skipped] = "0;36",
	[statuses.common] = "1;1",
	[statuses.unchanged] = "90",
}

---@return string
local resetColor = function()
	if sys.isColorSupported() then
		return "\27[0m"
	end
	return ""
end

---@param status statuses
---@return string
local function setColor(status)
	if sys.isColorSupported() then
		return string.format("\27[%sm", colors[status])
	end
	return ""
end

---@param message string
---@param status statuses
---@param suffix? string | nil
local printResult = function(message, status, suffix)
	suffix = suffix or ""
	local tpl = string.rep(config.tab, ctx.level)
	if status ~= statuses.common then
		tpl = tpl .. "[%s] %s%s\n"
	else
		tpl = tpl .. "%s%s\n"
	end
	local str = string.format(
		tpl,
		setColor(status) .. status .. resetColor(),
		message,
		suffix
	)
	io.write(str)
end

---@type {printExpected: Printer, printActual: Printer, printSkipped: Printer, printStyle: fun(msg: string, ...?: termStyles), setColor: fun(status: statuses): string, resetColor: fun(): string, statuses: statuses, termStyles: termStyles}
return {
	printExpected = function(msg, suffix)
		printResult(msg, statuses.expected, suffix)
	end,

	printActual = function(msg, suffix)
		printResult(msg, statuses.actual, suffix)
	end,

	printSkipped = function(msg, suffix)
		printResult(msg, statuses.skipped, suffix)
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
	statuses = statuses,
	termStyles = termStyles,
}
