-- TODO coverage
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

---@class CoverageXMLReporter : CoverageReporter
---@field private coverage Coverage
local CoverageXMLReporter = {}

---@param coverage CoverageData
---@return CoverageTerminalReporter
function CoverageXMLReporter:new(coverage)
	local t = {
		coverage = coverage,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports coverage in the html file.
function CoverageXMLReporter:report()
	self:prepare()
	local data = self.coverage.data
	local path = config.Coverage.Dir
	local xml = { '<?xml version="1.0" encoding="UTF-8"?>' }
	xml[#xml + 1] = "<report>"
	local reportFileName = string.format(
		"%s%s%s-%s.xml",
		path,
		PathSep,
		config.Coverage.ReportName,
		os.date("%Y-%m-%d")
	)
	local fp = io.open(reportFileName, "w")
	if fp == nil then
		error(string.format(Labels.ErrorCannotWriteFile, reportFileName))
	end

	xml[#xml + 1] = "\t<info>"
	local avgPct = self.coverage:calculateTotalAveragePercent()
	xml[#xml + 1] = "\t\t<date>"
		.. os.date(config.Coverage.DateFormat)
		.. "</date>"
	xml[#xml + 1] = "\t\t<average>" .. avgPct .. "</average>"
	xml[#xml + 1] = "\t\t<software>Laura</software>"
	xml[#xml + 1] = "\t\t<version>" .. _VERSION .. "</version>"
	xml[#xml + 1] = "\t</info>"
	xml[#xml + 1] = "\t<files>"
	for src in spairs(data) do
		local pct = self.coverage:getCoveredPercent(src)
		for _, rec in ipairs(self:buildRow(src, pct)) do
			xml[#xml + 1] = rec
		end
	end
	xml[#xml + 1] = "\t</files>"
	xml[#xml + 1] = "</report>"

	fp:write(concat(xml, EOL))
	fp:close()
	print(string.format(Labels.ReportWrittenTo, reportFileName))
end

---@private
---@param source string
---@param percent number
---@return table
function CoverageXMLReporter:buildRow(source, percent)
	local pct = string.format("%.1f" .. "&#37;", percent)

	local xml = {}
	xml[#xml + 1] = "\t\t<file>"
	xml[#xml + 1] = "\t\t\t<source>" .. source .. "</source>"
	xml[#xml + 1] = "\t\t\t<coverage>" .. pct .. "</coverage>"

	for i, record in ipairs(self.coverage.data[source]) do
		record.code = string.gsub(record.code, "[><]", {
			["<"] = "&lt;",
			[">"] = "&gt;",
		})
		xml[#xml + 1] = string.format(
			"\t\t\t<line>"
				.. EOL
				.. "\z
			\t\t\t\t<number>%d</number>"
				.. EOL
				.. "\z
			\t\t\t\t<included>%s</included>"
				.. EOL
				.. "\z
			\t\t\t\t<code><![CDATA[%s]]></code>"
				.. EOL
				.. "\z
			\t\t\t\t<hits>%d</hits>"
				.. EOL
				.. "\z
			\t\t\t</line>"
				.. EOL
				.. "\z",
			i,
			tostring(record.included),
			record.code,
			record.hits
		)
	end

	xml[#xml + 1] = "\t\t</file>"
	return xml
end

return CoverageXMLReporter
-- coverage: enable
