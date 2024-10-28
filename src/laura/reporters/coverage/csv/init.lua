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

---@class CoverageCSVReporter : CoverageReporter
---@field private coverage Coverage
---@field private threshold number
local CoverageCSVReporter = {}

---@param coverage CoverageData
---@param threshold number
---@return CoverageTerminalReporter
function CoverageCSVReporter:new(coverage, threshold)
	local t = {
		coverage = coverage,
		threshold = threshold,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports coverage in the csv file.
function CoverageCSVReporter:report()
	self:prepare()

	local path = config.Coverage.Dir
	local data = self.coverage.data
	local excludeIndex = config._coverageExcludeLineIndex

	local records = {}
	for source in spairs(data) do
		records[#records + 1] = "@" .. source

		local n = 1
		for _, record in ipairs(data[source]) do
			local hits = record.included and record.hits or excludeIndex
			-- In CSV usually double qoutes inside are repeatedly replaced
			-- with double qoutes. Usually this rule is used by spreadsheet
			-- software.
			record.code = record.code:gsub('"', string.rep('"', 2))
			records[#records + 1] =
				string.format('"%d"\t"%d"\t"%s"', n, hits, record.code)
			n = n + 1
		end
	end

	local reportFileName = string.format(
		"%s%s%s-%s.csv",
		path,
		PathSep,
		config.Coverage.ReportName,
		os.date("%Y-%m-%d")
	)
	local fp = io.open(reportFileName, "w")
	if fp == nil then
		error(string.format(Labels.ErrorCannotWriteFile, reportFileName))
	end
	fp:write(table.concat(records, EOL))
	fp:close()
	print(string.format(Labels.ReportWrittenTo, reportFileName))
end

return CoverageCSVReporter
