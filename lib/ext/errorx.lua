---@alias Error{message: string, expected: any, actual: any, description?: string, diffString?: string, debuginfo?: table, traceback?: string}

local Context = require("lib.Context")
local helpers = require("lib.util.helpers")
local labels = require("lib.Labels")
local Status = require("lib.Status")
local Terminal = require("lib.Terminal")

local ctx = Context.global()

---Creates a new error object.
---@param message string Extra messgef for the error.
---@param actual any Actual value.
---@param expected any Expected value.
---@param description? string Desctiption of the test case.
---@param diffString? string Used to print table diff.
---@param debuginfo? debuginfo Used to print table diff.
---@param traceback? string Used to print table diff.
---@return Error
local function new(
	message,
	actual,
	expected,
	description,
	diffString,
	debuginfo,
	traceback
)
	return {
		message = message,
		actual = actual,
		expected = expected,
		description = description or "",
		diffString = diffString or "",
		debuginfo = debuginfo,
		traceback = traceback,
	}
end

---@param err Error
---@return string
local function toString(err)
	local out = {
		helpers.tab(ctx.level),
		err.message,
		err.description,
		"\n\n",
		helpers.tab(1),
		labels.RemovedSymbol,
		labels.ErrorExpected,
		Terminal.setColor(Status.Passed),
		string.format("%q", err.expected),
		Terminal.resetColor(),
		helpers.tab(ctx.level),
		"\n",
		helpers.tab(1),
		labels.AddedSymbol,
		labels.ErrorActual,
		Terminal.setColor(Status.Failed),
		string.format("%q", err.actual),
		Terminal.resetColor(),
		"\n",
		err.diffString,
		"\n",
	}
	if err.debuginfo ~= nil then
		out[#out + 1] = string.format(
			"%s:%d\n\n",
			err.debuginfo.source,
			err.debuginfo.linedefined
		)
	end
	if ctx.config.Traceback then
		out[#out + 1] = err.traceback
		out[#out + 1] = "\n"
	end
	return table.concat(out)
end

---@param err Error
local function printError(err)
	io.write(toString(err))
end

return {
	new = new,
	print = printError,
	toString = toString,
}
