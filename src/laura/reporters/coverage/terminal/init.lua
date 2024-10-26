local CoverageReporter = require("laura.reporters.coverage.CoverageReporter")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local Status = require("laura.Status")
local Terminal = require("laura.Terminal")

local spairs = helpers.spairs

---@class CoverageTerminalReporter : CoverageReporter
---@field private coverage Coverage
---@field private threshold number
local CoverageTerminalReporter = {}

---@param coverage CoverageData
---@param threshold number
---@return CoverageTerminalReporter
function CoverageTerminalReporter:new(coverage, threshold)
	local t = {
		coverage = coverage,
		threshold = threshold,
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
			self.coverage:calculateTotalAveragePercent()
		)
	)
end

return CoverageTerminalReporter
