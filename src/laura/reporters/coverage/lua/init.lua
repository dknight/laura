local CoverageReporter = require("laura.reporters.coverage.CoverageReporter")
local Context = require("laura.Context")
local fs = require("laura.util.fs")
local helpers = require("laura.util.helpers")
local Labels = require("laura.Labels")
local tablex = require("laura.ext.tablex")

local ctx = Context.global()
local config = ctx.config

local concat = table.concat
local spairs = helpers.spairs
local PathSep = fs.PathSep
local EOL = fs.EOL

---@class CoverageLuaReporter : CoverageReporter
---@field private coverage Coverage
---@field private threshold number
local CoverageLuaReporter = {}

---@param coverage CoverageData
---@param threshold number
---@return CoverageTerminalReporter
function CoverageLuaReporter:new(coverage, threshold)
	local t = {
		coverage = coverage,
		threshold = threshold,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---Reports coverage in the html file.
function CoverageLuaReporter:report()
	self:prepare()
	local data = self.coverage.data
	local path = config.Coverage.Dir

	local reportFileName = string.format(
		"%s%s%s-%s.lua",
		path,
		PathSep,
		config.Coverage.ReportName,
		os.date("%Y-%m-%d")
	)
	local fp = io.open(reportFileName, "w")
	if fp == nil then
		error(string.format(Labels.ErrorCannotWriteFile, reportFileName))
	end

	local info = {
		coverage = self.coverage:calculateTotalAveragePercent(),
		date = os.date(config.Coverage.DateFormat),
		software = "Laura",
	}

	local result = {
		info = info,
		files = data,
	}

	fp:write("results = " .. tablex.dump(result))
	fp:close()
	print(string.format(Labels.ReportWrittenTo, reportFileName))
end

---@private
---@param source string
---@param percent number
---@return table
function CoverageLuaReporter:buildRow(source, percent)
	local json = {}
	json[#json + 1] = "\t\t{"
	json[#json + 1] = '\t\t\t"source": "' .. source .. '",'
	json[#json + 1] = '\t\t\t"coverage": ' .. percent .. ","
	json[#json + 1] = '\t\t\t"lines": ['

	local lines = {}
	for i, record in ipairs(self.coverage.data[source]) do
		lines[#lines + 1] = string.format(
			'\t\t\t\t{\n\z
			\t\t\t\t\t"number": %d,\n\z
			\t\t\t\t\t"included": %s,\n\z
			\t\t\t\t\t"code": %s,\n\z
			\t\t\t\t\t"hits": %d\n\z
			\t\t\t\t}\n',
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

return CoverageLuaReporter
