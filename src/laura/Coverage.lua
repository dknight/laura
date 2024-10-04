local helpers = require("laura.util.helpers")
local stringx = require("laura.ext.stringx")
local Terminal = require("laura.Terminal")
local Status = require("laura.Status")
local Context = require("laura.Context")

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
	return #stringx.split(stringx.removeComments(s), "\n")
end

---Creates coverage hook function that collects coverad lines.
---@param level number
---@return function
function Coverage:createHook(level)
	level = level or 2
	return function(_, lineno)
		-- FIXME very bad performance optimize this
		local src = debug.getinfo(level, "S").short_src

		-- skip test pattern files
		if src:match("." .. self.ctx.config.FilePattern) == nil then
			self.data[src] = self.data[src] or {}
			self.data[src][lineno] = (self.data[src][lineno] or 0) + 1
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
		io.write(color)
		io.write(string.format("%-" .. longest .. "s %6.1f%%\n", src, pct))
		io.write(Terminal.reset())
	end
end

return Coverage
