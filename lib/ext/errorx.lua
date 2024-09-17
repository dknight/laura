local Context = require("lib.Context")
local helpers = require("lib.util.helpers")
local labels = require("lib.Labels")
local Status = require("lib.Status")
local Terminal = require("lib.Terminal")

---@class Error
---@field message string Extra messgef for the error.
---@field actual any Actual value.
---@field expected any Expected value.
---@field description? string Desctiption of the test case.
---@field diffString? string Used to print extra diff and error output
---information.
---@field debuginfo? debuginfo Used to print table diff.
---@field traceback? string Used to print table diff.
---@field actualOperator? string Actual comparison operator.
---@field expectedOperator? string Expected comparison operator.
---@field precision? number Prcision for floats number in the output.

local ctx = Context.global()

---Creates a new error instance.
---@param message string
---@param actual any
---@param expected any
---@param description? string
---@param diffString? string
---@param debuginfo? debuginfo
---@param traceback? string
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
		actualOperator = "", -- not in use
		expectedOperator = "", -- not in use
		precision = 0,
	}
end

---@param v any
---@param precision? number
---@return string
local function resolveQualifier(v, precision)
	precision = precision or 2
	local q = "%q"
	if type(v) == "number" then
		if math.type(v) == "float" then
			q = "%." .. precision .. "f"
		else
			q = "%d"
		end
	elseif type(v) == "string" then
		q = "%s"
	end
	return q
end

-- FIXME tabulation with operators
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
		labels.ErrorExpected .. err.expectedOperator .. " ",
		Terminal.setColor(Status.Passed),
		string.format(resolveQualifier(err.expected), err.expected),
		Terminal.resetColor(),
		helpers.tab(ctx.level),
		"\n",
		helpers.tab(1),
		labels.AddedSymbol,
		labels.ErrorActual .. err.actualOperator .. " ",
		Terminal.setColor(Status.Failed),
		string.format(resolveQualifier(err.actual), err.actual),
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
	resolveQualifier = resolveQualifier,
}
