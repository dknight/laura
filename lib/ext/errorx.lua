local Context = require("lib.Context")
local helpers = require("lib.util.helpers")
local Labels = require("lib.Labels")
local Status = require("lib.Status")
local Terminal = require("lib.Terminal")
local tablex = require("lib.ext.tablex")

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

---Creates a new error instance.
---@param err? Error
---@return Error
local function new(err)
	local opts = {
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
			opts[k] = v
		end
	end

	return opts
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
		-- edge cases
		if v == ctx.config._rationalSet then -- Rational number
			q = "%s"
		else
			q = '"%s"'
		end
	end
	return q
end

---@param err Error
---@return string
local function toString(err)
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

	local actualValue = err.actual
	if type(err.actual) == "table" and #err.actual > 0 then
		actualValue = tablex.inline(err.actual, true)
	end

	local out = {
		helpers.tab(ctx.level),
		err.title,
		"\n\n",
		helpers.tab(1),
		exp,
		Terminal.setColor(Status.Passed),
		string.format(resolveQualifier(err.expected), err.expected),
		Terminal.reset(),
		helpers.tab(ctx.level),
		"\n",
		helpers.tab(1),
		act,
		Terminal.setColor(Status.Failed),
		string.format(resolveQualifier(err.actual), actualValue),
		Terminal.reset(),
		"\n",
		err.message,
		"\n",
	}
	if err.debuginfo ~= nil then
		-- might be better?
		local activeLine = math.huge
		for i in pairs(err.debuginfo.activelines) do
			activeLine = math.min(i, activeLine)
		end
		-- end --

		out[#out + 1] = string.format(
			"%s:%d\n\n",
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
				local f = "%" .. math.ceil(decs) .. "d. %s\n"
				if err.debuginfo.activelines[lineno] then
					local match = l:gsub(
						"%((.*)%)(.*)%((.*)%)",
						"("
							.. Terminal.setColor(Status.Failed)
							.. "%1"
							.. Terminal.reset()
							.. ")%2("
							.. Terminal.setColor(Status.Passed)
							.. "%3"
							.. Terminal.reset()
							.. ")"
					)
					l = Terminal.setStyle(match, Terminal.Style.Normal)
				else
					l = Terminal.setStyle(line, Terminal.Style.Dim)
				end
				out[#out + 1] = string.format(f, lineno, l)
			end
		end
		out[#out + 1] = "\n"
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
