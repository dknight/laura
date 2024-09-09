local Reporter = require("lib.reporters.Reporter")

---@class BlankReporter : Reporter
local BlankReporter = {}

---@param results RunResults
function BlankReporter:new(results)
	setmetatable(results, { __index = BlankReporter })
	setmetatable(BlankReporter, { __index = Reporter })
	return results
end

---Report the tests
---@param suite? Runnable
function BlankReporter:reportTests(suite)
	-- noop
end

return BlankReporter
