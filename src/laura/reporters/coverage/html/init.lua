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
---@field private threshold number
local CoverageHTMLReporter = {
	---@param pct number
	---@return string
	resolveCSSClass = function(pct)
		local c = "not-covered"
		if pct >= 90 then
			c = "covered"
		elseif pct >= 75 and pct < 90 then
			c = "partially-covered"
		end
		return c
	end,
}

---@param coverage CoverageData
---@param threshold number
---@return CoverageTerminalReporter
function CoverageHTMLReporter:new(coverage, threshold)
	local t = {
		coverage = coverage,
		threshold = threshold,
	}
	setmetatable(t, { __index = self })
	setmetatable(self, { __index = CoverageReporter })
	return t
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
		"%s%s" .. config.Coverage.ReportName .. "-%s.html",
		path,
		PathSep,
		os.date("%Y-%m-%d")
	)
	local fp = io.open(reportFileName, "w")
	if fp == nil then
		error(string.format(Labels.ErrorCannotWriteFile, reportFileName))
	end
	local rows = {}
	for src in spairs(data) do
		local pct = self.coverage:getCoveredPercent(src)
		rows[#rows + 1] = self:buildRow(src, pct, self.resolveCSSClass(pct))
	end

	local avgPct = self.coverage:calculateTotalAveragePercent()
	contents = string.gsub(contents, "%$(%u+)%$", {
		CONTENT = concat(rows, EOL),
		DATE = os.date(config.Coverage.DateFormat),
		AVG = string.format("%.1f&#37;", avgPct),
		AVGSTATUS = self.resolveCSSClass(avgPct),
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
	-- local threshold = config.Coverage.Threshold

	local pct = string.format("%.1f" .. "&#37;", percent)
	local id = string.gsub(source, "%p", "-")

	local html = {}
	html[#html + 1] = '<details id="' .. id .. '">'
	html[#html + 1] = '<summary class="' .. status .. '">'
	html[#html + 1] = '<span class="filename">' .. source .. "</span>"
	html[#html + 1] = '<span class="percent">' .. pct .. "</span>"
	html[#html + 1] = "</summary>"
	html[#html + 1] = '<ol class="listing">'

	for i, record in ipairs(self.coverage.data[source]) do
		local cssClass
		if not record.included then
			cssClass = "excluded"
		elseif record.calls == 0 then
			cssClass = "not-covered"
		elseif record.calls > 0 then
			cssClass = "covered"
		end
		record.code = string.gsub(record.code, "[><]", {
			["<"] = "&lt;",
			[">"] = "&gt;",
		})
		html[#html + 1] = string.format(
			'<li class="%s">\z
				<code>\z
					<span>%s</span>\z
					<span class="calls">&times;%d</span>\z
				</code>\z
			</li>',
			cssClass,
			record.code,
			record.calls
		)
	end

	html[#html + 1] = "</ol>"
	html[#html + 1] = "</details>"
	return concat(html)
end

return CoverageHTMLReporter
