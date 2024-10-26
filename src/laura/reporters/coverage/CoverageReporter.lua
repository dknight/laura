local Context = require("laura.Context")
local Labels = require("laura.Labels")
local Terminal = require("laura.Terminal")
local fs = require("laura.util.fs")

local ctx = Context.global()
local config = ctx.config
local mkdir = fs.mkdir
local isdir = fs.isdir

---@class CoverageReporter
---@field private coverage Coverage
---@field private threshold number
local CoverageReporter = {
	printTitle = function()
		print(
			Terminal.setStyle(
				"\n" .. Labels.Summary.Coverage,
				Terminal.Style.Bold,
				Terminal.Style.Underlined
			)
		)
	end,
}
CoverageReporter.__index = CoverageReporter

---@param coverage Coverage
---@param threshold number
---@return CoverageReporter
function CoverageReporter:new(coverage, threshold)
	local t = {
		coverage = coverage,
		threshold = threshold,
	}
	return setmetatable(t, self)
end

---@return boolean?
function CoverageReporter:prepare()
	local path = config.Coverage.Dir
	local ok = mkdir(path)
	if not ok and not isdir(path) then
		error(string.format(Labels.ErrorCannotCreateDir, path))
	end
	return ok
end

---Common results of coverage.
function CoverageReporter:results()
	local threshold = self.threshold
	local pct = self.coverage:calculateTotalAveragePercent()
	if threshold > 0 and pct < threshold then
		print(string.format(Labels.ErrorCoverageNotMet, pct, threshold))
		print(Labels.ResultFailed)
		os.exit(config._exitCoverageFailed)
	end
end

---Reports coverage
function CoverageReporter:report()
	-- override in subclass
end

return CoverageReporter
