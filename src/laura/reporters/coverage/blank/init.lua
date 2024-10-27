local CoverageReporter = require("laura.reporters.coverage.CoverageReporter")
local Context = require("laura.Context")
local Labels = require("laura.Labels")
local helpers = require("laura.util.helpers")
local fs = require("laura.util.fs")

local ctx = Context.global()
local config = ctx.config

local spairs = helpers.spairs
local EOL = fs.EOL
local PathSep = fs.PathSep

---@class CoverageBlankReporter : CoverageReporter
---@field private coverage Coverage
---@field private threshold number
local CoverageBlankReporter = {}

---@param coverage CoverageData
---@param threshold number
---@return CoverageTerminalReporter
function CoverageBlankReporter:new(coverage, threshold)
	local t = {
		coverage = coverage,
		threshold = threshold,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports blank.
function CoverageBlankReporter:report()
	self:prepare()
	-- Do not print anything.
	print("blank")
end

return CoverageBlankReporter
