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

---Converts error to string.
---@param err Error
---@return string
local function tostring(err)
	-- TODO refactor to readable code
	local retval = string.format(
		"%s%s\n\n%s%s%q%s\n%s%s%s%q%s%s\n",
		helpers.tab(ctx.level),
		err.message .. (err.description or ""),
		"\t" .. labels.removed,
		labels.errorExpected .. Terminal.setColor(Status.Passed),
		err.expected,
		Terminal.resetColor(),
		helpers.tab(ctx.level),
		"\t" .. labels.added,
		labels.errorActual .. Terminal.setColor(Status.Failed),
		err.actual,
		Terminal.resetColor(),
		"\n" .. (err.diffString or "")
	)
	if err.debuginfo ~= nil then
		retval = retval
			.. string.format(
				"%s:%d\n\n",
				err.debuginfo.source,
				err.debuginfo.linedefined
			)
	end
	if config.traceback then
		retval = retval .. err.traceback .. "\n"
	end
	return retval
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
