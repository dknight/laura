---@alias Error{message: string, expected: any, actual: any, description?: string, diffString?: string, debuginfo?: table, traceback?: string}

local config = require("config")
local Context = require("lib.classes.Context")
local helpers = require("lib.util.helpers")
local labels = require("lib.labels")
local Status = require("lib.classes.Status")
local Terminal = require("lib.classes.Terminal")

local ctx = Context.global()

---Creates a new error object.
---@param message string Extra messgef for the error.
---@param actual any Actual value.
---@param expected any Expected value.
---@param description? string Desctiption of the test case.
---@param diffString? string Used to print table diff.
---@return Error
local function new(message, actual, expected, description, diffString)
	return {
		message = message,
		actual = actual,
		expected = expected,
		description = description,
		diffString = diffString,
	}
end

---@param err Error
---@return string
local function tostring(err)
	local out = {
		helpers.tab(ctx.level),
		err.message,
		err.description or "",
		"\n\n",
		config.tab(1),
		labels.removed,
		labels.errorExpected,
		Terminal.setColor(Status.Passed),
		string.format("%q", err.expected),
		Terminal.resetColor(),
		helpers.tab(ctx.level),
		"\n",
		helpers.tab(1),
		labels.added,
		labels.errorActual,
		Terminal.setColor(Status.Failed),
		string.format("%q", err.actual),
		Terminal.resetColor(),
		err.diffString or "",
		"\n\n",
	}
	if err.debuginfo ~= nil then
		out[#out + 1] = string.format(
			"%s:%d\n\n",
			err.debuginfo.source,
			err.debuginfo.linedefined
		)
	end
	if config.traceback then
		out[#out + 1] = err.traceback
		out[#out + 1] = "\n"
	end
	return table.concat(out)
end

---@param err Error
local function printError(err)
	io.write(tostring(err))
end

return {
	new = new,
	print = printError,
	tostring = tostring,
}
