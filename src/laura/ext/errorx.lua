local Context = require("laura.Context")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local Status = require("laura.Status")
local tablex = require("laura.ext.tablex")
local Terminal = require("laura.Terminal")
local fs = require("laura.util.fs")
local Version = require("laura.Version")

local EOL = fs.EOL

---@class Error
---@field title? string Title for the error.
---@field actual any Actual value.
---@field expected any Expected value.
---@field actualLabel? string Actual label.
---@field expectedLabel? string Expected label.
---@field message? string Used to print extra diff and error output
---information.
---@field debuginfo? debuginfo Used to print table diff.
---@field traceback? string Used to print table diff.
---@field actualOperator? string Actual comparison operator.
---@field expectedOperator? string Expected comparison operator.
---@field precision? number Precision for floats number in the output.
---@field currentLine? number Current line of a call

local ctx = Context.global()

---@param err? Error
---@return Error
local function new(err)
	local params = {
		actual = nil,
		actualOperator = "",
		currentLine = -1,
		debuginfo = nil,
		expected = nil,
		expectedOperator = "",
		message = "",
		title = "",
		precision = 0,
		traceback = nil,
	}

	if type(err) == "table" then
		for k, v in pairs(err) do
			params[k] = v
		end
	end

	return params
end

---@param v any
---@return string
local function resolveQualifier(v)
	local typ = type(v)
	local q = "%q"
	if typ == "number" then
		q = "%d"
	elseif typ == "table" or typ == "function" then
		q = "%s"
	elseif typ == "string" then
		-- edge cases
		-- Rational numbers
		if v == ctx.config._rationalSet then
			q = "%s"
		else
			q = '"%s"'
		end
	end
	return q
end

---@param err Error
---@param isColor? boolean
---@return string
local function toString(err, isColor)
	if not err then
		return Labels.ErrorUnknown
	end
	local act = string.format(
		"%s%s",
		err.actualLabel or Labels.ErrorActual,
		err.actualOperator
	)
	local exp = string.format(
		"%s%s",
		err.expectedLabel or Labels.ErrorExpected,
		err.expectedOperator
	)
	local space = math.max(#act, #exp)
	local fmt = "%-" .. space .. "s"
	act = string.format(fmt, act)
	exp = string.format(fmt, exp)

	local expectedValue = err.expected
	local actualValue = err.actual
	if type(err.actual) == "table" and #err.actual > 0 then
		actualValue = tablex.inline(err.actual, true)
	end

	-- COMPAT
	-- coverage: disable
	if Version[_VERSION] <= Version["Lua 5.1"] then
		if type(expectedValue) ~= "string" then
			expectedValue = tostring(expectedValue)
		end
		if type(actualValue) ~= "string" then
			actualValue = tostring(actualValue)
		end
	end
	-- coverage: enable

	local passedColor = isColor and Terminal.setColor(Status.Passed) or ""
	local failedColor = isColor and Terminal.setColor(Status.Failed) or ""
	local resetSeq = isColor and Terminal.reset() or ""
	local out = {
		helpers.tab(ctx.level),
		err.title,
		string.rep(EOL, 2),
		helpers.tab(1),
		exp,
		passedColor,
		string.format(resolveQualifier(err.expected), expectedValue),
		resetSeq,
		helpers.tab(ctx.level),
		EOL,
		helpers.tab(1),
		act,
		failedColor,
		string.format(resolveQualifier(err.actual), actualValue),
		resetSeq,
		EOL,
		err.message,
		EOL,
	}
	if err.debuginfo ~= nil then
		-- might be better?
		local activeLine = math.huge
		local activeLines = err.debuginfo.activelines
		if not activeLines then
			activeLine = -1
			activeLines = {}
		end
		for i in pairs(activeLines) do
			activeLine = math.min(i, activeLine)
		end
		-- end --

		out[#out + 1] = string.format(
			"%s:%d" .. string.rep(EOL, 2),
			err.debuginfo.source,
			err.currentLine > 0 and err.currentLine or activeLine
		)

		local lineno = 0
		for line in io.lines(err.debuginfo.short_src) do
			lineno = lineno + 1
			if
				lineno >= err.debuginfo.linedefined
				and lineno <= err.debuginfo.lastlinedefined
			then
				local decs = math.log(err.debuginfo.lastlinedefined, 10) + 1
				local l = line
				local f = "%" .. math.ceil(decs) .. "d. %s" .. EOL
				if activeLines[lineno] then
					local match = l:gsub(
						"%((.*)%)(.*)%((.*)%)",
						"("
							.. failedColor
							.. "%1"
							.. resetSeq
							.. ")%2("
							.. passedColor
							.. "%3"
							.. resetSeq
							.. ")"
					)
					l = Terminal.setStyle(match, Terminal.Style.Normal)
				else
					l = Terminal.setStyle(line, Terminal.Style.Dim)
				end
				out[#out + 1] = string.format(f, lineno, l)
			end
		end
		out[#out + 1] = EOL
	end
	if ctx.config.Traceback then
		out[#out + 1] = err.traceback
		out[#out + 1] = EOL
	end
	return table.concat(out)
end

---@param isColor? boolean
---@param err Error
local function printError(err, isColor)
	io.write(toString(err, isColor))
end

return {
	new = new,
	print = printError,
	-- COMPAT print() cause an error in Lua 5.1
	printError = printError,
	toString = toString,
}
