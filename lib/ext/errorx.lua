local Context = require("lib.Context")
local helpers = require("lib.util.helpers")
local Labels = require("lib.Labels")
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
---@field precision? number Precision for floats number in the output.
---@field currentLine? number Current line of a call

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
		actualOperator = "",
		expectedOperator = "",
		precision = 0,
		currentLine = debug.getinfo(3, "l").currentline,
	}
end
---@param v any
---@param precision? number
---@return string
local function resolveQualifier(v, precision)
	precision = precision or 2
	local typ = type(v)
	local q = "%q"
	if typ == "number" then
		if math.type(v) == "float" then
			q = "%." .. precision .. "f"
		else
			q = "%d"
		end
	elseif typ == "table" or typ == "function" then
		q = "%s"
	elseif typ == "string" then
		q = '"%s"'
	end
	return q
end

---TODO pass extra labels instead of default
---@param err Error
---@return string
local function toString(err)
	local act = string.format(
		"%s%s%s",
		Labels.AddedSymbol,
		Labels.ErrorActual,
		err.actualOperator
	)
	local exp = string.format(
		"%s%s%s",
		Labels.RemovedSymbol,
		Labels.ErrorExpected,
		err.expectedOperator
	)
	local space = math.max(#act, #exp)
	local fmt = "%-" .. space .. "s"
	act = string.format(fmt, act)
	exp = string.format(fmt, exp)

	local actualValue = err.actual
	if type(err.actual) == "table" and #err.actual > 0 then
		local tmp = {}
		for i in ipairs(err.actual) do
			tmp[#tmp + 1] =
				string.format(resolveQualifier(err.actual[i]), err.actual[i])
		end
		actualValue = "{" .. table.concat(tmp, ", ") .. "}"
	end

	local out = {
		helpers.tab(ctx.level),
		err.message,
		err.description,
		"\n\n",
		helpers.tab(1),
		exp,
		Terminal.setColor(Status.Passed),
		string.format(resolveQualifier(err.expected), err.expected),
		Terminal.resetColor(),
		helpers.tab(ctx.level),
		"\n",
		helpers.tab(1),
		act,
		Terminal.setColor(Status.Failed),
		string.format(resolveQualifier(err.actual), actualValue),
		Terminal.resetColor(),
		"\n",
		err.diffString,
		"\n",
	}
	if err.debuginfo ~= nil then
		out[#out + 1] = string.format(
			"%s:%d\n\n",
			err.debuginfo.source,
			err.currentLine or err.debuginfo.linedefined
		)

		local lineno = 0
		for line in io.lines(err.debuginfo.short_src) do
			lineno = lineno + 1
			if
				lineno >= err.debuginfo.linedefined
				and lineno <= err.debuginfo.lastlinedefined
			then
				local l = line
				local f = "%4d. %10s\n"
				if err.currentLine ~= lineno then
					l = Terminal.setStyle(line, Terminal.Style.Dim)
					f = "%4d. %s\n"
				end
				out[#out + 1] = string.format(f, lineno, l)
			end
		end
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
