local Context = require("laura.Context")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local Status = require("laura.Status")
local stringx = require("laura.ext.stringx")
local Terminal = require("laura.Terminal")

---@class Coverage
---@field public data {[string]: number[]}
---@field private ctx Context
local Coverage = {}
Coverage.__index = Coverage

---@param ctx? Context
---@return Coverage
function Coverage:new(ctx)
	local t = {
		data = {},
		ctx = ctx or Context.global(),
	}
	return setmetatable(t, self)
end

---@private
---@param src string
---@return number
function Coverage:countTotalLines(src)
	local fd = io.open(src, "r")
	local s
	if fd ~= nil then
		s = fd:read("*a")
		fd:close()
	end
	-- local function declarations not counted as debug? So, if yes
	-- then skip
	s = stringx.removeComments(s)
	s = s:gsub("%s*local%s+function%s*[%w_]+%([%w%s_,]*%)", "")
	return #stringx.split(s, "\n")
end

---Creates coverage hook function that collects coverad lines.
---@param level? number
---@return function
function Coverage:createHookFunction(level)
	return function(_, lineno)
		local isLibTesting = os.getenv("LAURA_DEV_TEST")
		-- FIXME very bad performance, optimize this
		local info = debug.getinfo(level or 2, "S")
		if not info then
			warn(Labels.WarningUnknownContext)
			return
		end

		local source = info.source:gsub("^@", "")
		-- collaspe slashes (bad)
		source = source:gsub("////+", "")

		-- skip test pattern files and exec
		local matchPattern = source:match("." .. self.ctx.config.FilePattern)
		local matchExec =
			source:match(string.format("^.*%s$", self.ctx.config._execName))
		local shouldInclude = matchPattern == nil and matchExec == nil

		-- skipping lib calls to print from testing outside the lib.
		if not isLibTesting and source:match("/laura/") ~= nil then
			shouldInclude = false
		end

		if shouldInclude then
			self.data[source] = self.data[source] or {}
			self.data[source][lineno] = (self.data[source][lineno] or 0) + 1
		end
	end
end

---@private
---@param src string
---@return number
function Coverage:countCoveredLines(src)
	local n = 0
	for _ in pairs(self.data[src]) do
		n = n + 1
	end
	return n
end

---@param src string
---@return number
function Coverage:getCoveredPercent(src)
	local total = self:countTotalLines(src)
	local cov = self:countCoveredLines(src)
	if total == 0 then
		return 0
	end
	return ((cov / total) * 100)
end

---@return number
function Coverage:calculateTotalAveragePercent()
	local total = 0
	local n = 0
	for src in pairs(self.data) do
		total = total + self:getCoveredPercent(src)
		n = n + 1
	end

	if n == 0 then
		return 0
	end

	return (total / n)
end

---@public
function Coverage:printReport()
	local longest = 0
	for src in pairs(self.data) do
		longest = math.max(src:len(), longest)
	end

	for src in helpers.spairs(self.data) do
		local pct = self:getCoveredPercent(src)
		local color = Terminal.setColor(Status.Failed)
		if pct >= 90 then
			color = Terminal.setColor(Status.Passed)
		elseif pct >= 75 and pct < 90 then
			color = Terminal.setColor(Status.Warning)
		end
		if Terminal.isColorSupported() then
			io.write(color)
		end
		io.write(string.format("%-" .. longest .. "s %6.1f%%\n", src, pct))
		if Terminal.isColorSupported() then
			io.write(Terminal.reset())
		end
	end

	if longest == 0 then
		print(Labels.ErrorNothingToCover)
		return
	end

	print(
		string.format(
			"%-" .. longest .. "s %6.1f%%",
			Labels.Total,
			self:calculateTotalAveragePercent()
		)
	)
end

return Coverage
