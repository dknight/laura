-- coverage: disable
local CoverageReporter = require("laura.reporters.coverage.CoverageReporter")
local Context = require("laura.Context")
local fs = require("laura.util.fs")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")

local ctx = Context.global()
local config = ctx.config

local concat = table.concat
local spairs = helpers.spairs
local PathSep = fs.PathSep
local EOL = fs.EOL

---@class CoverageJSONReporter : CoverageReporter
---@field private coverage Coverage
local CoverageJSONReporter = {}

---@param coverage CoverageData
---@return CoverageJSONReporter
function CoverageJSONReporter:new(coverage)
	local t = {
		coverage = coverage,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports coverage in the html file.
function CoverageJSONReporter:report()
	self:prepare()
	local data = self.coverage.data
	local path = config.Coverage.Dir
	local json = {}
	json[#json + 1] = "{"
	local reportFileName = string.format(
		"%s%s%s-%s.json",
		path,
		PathSep,
		config.Coverage.ReportName,
		os.date("%Y-%m-%d")
	)
	local fp = io.open(reportFileName, "w")
	if fp == nil then
		error(string.format(Labels.ErrorCannotWriteFile, reportFileName))
	end

	json[#json + 1] = '\t"info": {'
	local avgPct = self.coverage:calculateTotalAveragePercent()
	json[#json + 1] = '\t\t"date": "'
		.. os.date(config.Coverage.DateFormat)
		.. '",'
	json[#json + 1] = '\t\t"average": ' .. avgPct .. ","
	json[#json + 1] = '\t\t"software": "Laura"'
	json[#json + 1] = "\t},"
	json[#json + 1] = '\t"files": ['
	for src in spairs(data) do
		local pct = self.coverage:getCoveredPercent(src)
		for _, rec in ipairs(self:buildRow(src, pct)) do
			json[#json + 1] = rec
		end
	end
	json[#json] = string.sub(json[#json], 1, -2)

	json[#json + 1] = "\t]"
	json[#json + 1] = "}"

	fp:write(concat(json, EOL))
	fp:close()
	print(string.format(Labels.ReportWrittenTo, reportFileName))
end

---@private
---@param source string
---@param percent number
---@return table
function CoverageJSONReporter:buildRow(source, percent)
	local json = {}
	json[#json + 1] = "\t\t{"
	json[#json + 1] = '\t\t\t"source": "' .. source .. '",'
	json[#json + 1] = '\t\t\t"coverage": ' .. percent .. ","
	json[#json + 1] = '\t\t\t"version": ' .. _VERSION .. ","
	json[#json + 1] = '\t\t\t"lines": ['

	local lines = {}
	for i, record in ipairs(self.coverage.data[source]) do
		lines[#lines + 1] = string.format(
			"\t\t\t\t{"
				.. EOL
				.. '\z
			\t\t\t\t\t"number": %d,'
				.. EOL
				.. '\z
			\t\t\t\t\t"included": %s,'
				.. EOL
				.. '\z
			\t\t\t\t\t"code": %s,'
				.. EOL
				.. '\z
			\t\t\t\t\t"hits": %d'
				.. EOL
				.. "\z
			\t\t\t\t}"
				.. EOL
				.. "",
			i,
			record.included,
			string.format("%q", record.code):gsub("\\9", "\\t"),
			record.hits
		)
	end
	json[#json + 1] = concat(lines, ",")
	json[#json + 1] = "\t\t\t]"
	json[#json + 1] = "\t\t},"
	return json
end

return CoverageJSONReporter
-- coverage: enable
