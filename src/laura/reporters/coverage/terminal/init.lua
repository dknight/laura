-- TODO coverage
-- coverage: disable
local CoverageReporter = require("laura.reporters.coverage.CoverageReporter")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local Status = require("laura.Status")
local Terminal = require("laura.Terminal")
local fs = require("laura.util.fs")

local EOL = fs.EOL
local spairs = helpers.spairs

---@class CoverageTerminalReporter : CoverageReporter
---@field private coverage Coverage
local CoverageTerminalReporter = {}

---@param coverage CoverageData
---@return CoverageTerminalReporter
function CoverageTerminalReporter:new(coverage)
	local t = {
		coverage = coverage,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports coverage in the terminal.
function CoverageTerminalReporter:report()
	local data = self.coverage.data
	local longest = 0
	for src in pairs(data) do
		longest = math.max(src:len(), longest)
	end

	for src in spairs(data) do
		local pct = self.coverage:getCoveredPercent(src)
		local color = Terminal.setColor(Status.Failed)
		if pct >= self.coverage.points.High then
			color = Terminal.setColor(Status.Passed)
		elseif
			pct >= self.coverage.points.Average
			and pct < self.coverage.points.High
		then
			color = Terminal.setColor(Status.Warning)
		end
		if Terminal.isColorSupported() then
			io.write(color)
		end
		io.write(string.format("%-" .. longest .. "s %6.1f%%%s", src, pct, EOL))
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
			self.coverage:calculateTotalAveragePercent()
		)
	)
end

return CoverageTerminalReporter
-- coverage: enable
