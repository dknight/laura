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

---@class CoverageHTMLReporter : CoverageReporter
---@field private coverage Coverage
local CoverageHTMLReporter = {}

---@param coverage CoverageData
---@return CoverageHTMLReporter
function CoverageHTMLReporter:new(coverage)
	local t = {
		coverage = coverage,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
end

---@private
---@param pct number
---@return string
function CoverageHTMLReporter:resolveCSSClass(pct)
	local c = "not-covered"
	if pct >= self.coverage.points.High then
		c = "covered"
	elseif
		pct >= self.coverage.points.Average
		and pct < self.coverage.points.High
	then
		c = "partially-covered"
	end
	return c
end

---Reports coverage in the html file.
function CoverageHTMLReporter:report()
	self:prepare()
	local data = self.coverage.data
	local path = config.Coverage.Dir

	local tplPath = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
		.. "template.html"
	local tfp = io.open(tplPath, "r")
	if tfp == nil then
		error(string.format(Labels.ErrorCannotReadFile, tplPath))
	end
	local contents = tfp:read("*a")
	tfp:close()
	local reportFileName = string.format(
		"%s%s%s-%s.html",
		path,
		PathSep,
		config.Coverage.ReportName,
		os.date("%Y-%m-%d")
	)
	local fp = io.open(reportFileName, "w")
	if fp == nil then
		error(string.format(Labels.ErrorCannotWriteFile, reportFileName))
	end
	local rows = {}
	for src in spairs(data) do
		local pct = self.coverage:getCoveredPercent(src)
		rows[#rows + 1] = self:buildRow(src, pct, self:resolveCSSClass(pct))
	end

	local avgPct = self.coverage:calculateTotalAveragePercent()
	contents = string.gsub(contents, "%$(%u+)%$", {
		CONTENT = concat(rows, EOL),
		DATE = os.date(config.DateFormat),
		AVG = string.format("%.1f&#37;", avgPct),
		AVGSTATUS = self:resolveCSSClass(avgPct),
	})
	fp:write(contents)
	fp:close()
	print(string.format(Labels.ReportWrittenTo, reportFileName))
end

---@private
---@param source string
---@param percent number
---@param status string
---@return string
function CoverageHTMLReporter:buildRow(source, percent, status)
	local pct = string.format("%.1f" .. "&#37;", percent)
	local id = string.gsub(source, "%p", "-")

	local html = {}
	html[#html + 1] = '<details id="' .. id .. '">'
	html[#html + 1] = '<summary class="' .. status .. '">'
	html[#html + 1] = '<span class="filename">' .. source .. "</span>"
	html[#html + 1] = '<span class="percent">' .. pct .. "</span>"
	html[#html + 1] = "</summary>"
	html[#html + 1] = '<ol class="listing">'

	for _, record in ipairs(self.coverage.data[source]) do
		local cssClass
		if not record.included then
			cssClass = "excluded"
		elseif record.hits == 0 then
			cssClass = "not-covered"
		elseif record.hits > 0 then
			cssClass = "covered"
		end
		record.code = string.gsub(record.code, "[><]", {
			["<"] = "&lt;",
			[">"] = "&gt;",
		})
		html[#html + 1] = string.format(
			[[<li class="%s"><code>
					<span>%s</span>
					<span class="hits">&times;%d</span>
				</code>
			</li>]],
			cssClass,
			record.code,
			record.hits
		)
	end

	html[#html + 1] = "</ol>"
	html[#html + 1] = "</details>"
	return concat(html)
end

return CoverageHTMLReporter
-- coverage: enable
