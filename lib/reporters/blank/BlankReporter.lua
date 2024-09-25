local Reporter = require("lib.reporters.Reporter")

---@class BlankReporter : Reporter
local BlankReporter = {}

---@param results RunResults
---@return RunResults
function BlankReporter:new(results)
	setmetatable(results, { __index = BlankReporter })
	setmetatable(BlankReporter, { __index = Reporter })
	return results
end

---Prints a single test report.
function BlankReporter:reportTest()
	-- noop
end

return BlankReporter
