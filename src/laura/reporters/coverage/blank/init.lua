-- coverage: disable
local CoverageReporter = require("laura.reporters.coverage.CoverageReporter")

---@class CoverageBlankReporter : CoverageReporter
---@field private coverage Coverage
local CoverageBlankReporter = {}

---@param coverage CoverageData
---@return CoverageBlankReporter
function CoverageBlankReporter:new(coverage)
	local t = {
		coverage = coverage,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports blank.
function CoverageBlankReporter:report()
	self:prepare()
	-- noop
end

return CoverageBlankReporter
-- coverage: enable
