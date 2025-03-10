local Context = require("laura.Context")
local LineScanner = require("laura.LineScanner")
local fs = require("laura.util.fs")

local PathSep = fs.PathSep

---@alias CoverageRecord {hits: number, code: string, included: boolean}
---@alias CoverageData {[string]: {[string]: CoverageRecord}}

---@class Coverage
---@field public data CoverageData
---@field public reporters CoverageReporter[]
---@field public scanner LineScanner
---@field public ctx Context
---@field public points {Low: number, Average: number, High: number}
local Coverage = {
	ctx = Context.global(),
}
Coverage.__index = Coverage

---@return Coverage
function Coverage:new()
	local t = {
		data = {},
		reporters = {},
		scanner = LineScanner:new(),
		points = Coverage.ctx.config.Coverage.ThresholdPoints,
	}

	-- load coverage reporters
	if Coverage.ctx.config.Coverage.Enabled then
		for _, name in ipairs(Coverage.ctx.config.Coverage.Reporters) do
			t.reporters[#t.reporters + 1] =
				require("laura.reporters.coverage." .. name):new(t)
		end
	end

	return setmetatable(t, self)
end

---@param record CoverageRecord
---@return boolean
function Coverage:isRecordIncluded(record)
	local ae, enc = self.scanner:consume(record.code)
	return not ae and (not enc or record.hits > 0)
end

---Creates coverage hook function that collects coverad lines.
---@param level? number
---@return function
function Coverage:createHookFunction(level)
	return function(_, lineno, lvl)
		lvl = lvl or level or 2
		-- FIXME try to optimize
		local info = debug.getinfo(lvl, "S")
		local source = info.source

		local path = string.match(source, "^@(.*)")
		if path then
			path = path:gsub("^%.[/\\]", ""):gsub("[/\\]", PathSep)
			-- else
			-- skip raw strings
		end

		if not self:isFileIncluded(path) then
			return
		end

		if not self.data[path] then
			self.data[path] = {}
			local n = 1

			for line in io.lines(path) do
				local rec = {
					hits = 0,
					code = line,
				}
				rec.included = self:isRecordIncluded(rec)
				self.data[path][n] = rec
				n = n + 1
			end
		end

		local record = self.data[path][lineno]
		record.hits = record.hits + 1
	end
end

---@private
---@param path string
---@return boolean
function Coverage:isFileIncluded(path)
	-- skip mask for coverage
	if not path:match(Coverage.ctx.config.Coverage.IncludePattern) then
		return false
	end

	-- skip test pattern files and exec
	local isLibTesting = os.getenv("LAURA_DEV_TEST")
	local matchPattern = path:match("." .. Coverage.ctx.config.TestPattern)
	local matchExec =
		path:match(string.format("^.*%s$", Coverage.ctx.config._execName))
	local includeFile = matchPattern == nil and matchExec == nil

	-- skipping lib hits to print from testing outside the lib.
	if
		not isLibTesting
		and path:match(PathSep .. "laura" .. PathSep) ~= nil
	then
		includeFile = false
	end
	return includeFile
end

---@private
---@param src string
---@return number
function Coverage:countTotalCoverableLines(src)
	local n = 0
	for _, record in pairs(self.data[src]) do
		if record.included then
			n = n + 1
		end
	end
	return n
end

---@private
---@param src string
---@return number
function Coverage:countCoveredLines(src)
	local n = 0
	for _, record in pairs(self.data[src]) do
		if record.included and record.hits > 0 then
			n = n + 1
		end
	end
	return n
end

---@param src string
---@return number
function Coverage:getCoveredPercent(src)
	local total = self:countTotalCoverableLines(src)
	local covered = self:countCoveredLines(src)
	if total == 0 and covered == 0 then
		return 100
	end
	return ((covered / total) * 100)
end

---@return number
function Coverage:calculateTotalAveragePercent()
	local total = 0
	local n = 0
	for src in pairs(self.data) do
		total = total + self:getCoveredPercent(src)
		n = n + 1
	end

	if n == 0 then
		return 0
	end

	return (total / n)
end

return Coverage
