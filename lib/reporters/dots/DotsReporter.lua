local Reporter = require("lib.reporters.Reporter")
local Terminal = require("lib.Terminal")
local Status = require("lib.Status")

local dot = "."

---@class DotsReporter : Reporter
local DotsReporter = {}

---@param results RunResults
---@return DotsReporter
function DotsReporter:new(results)
	setmetatable(results, { __index = DotsReporter })
	setmetatable(DotsReporter, { __index = Reporter })
	return results
end

---Print failed test message.
---@private
---@param status Status
function DotsReporter:printDot(status)
	io.write(Terminal.setColor(status) .. dot)
end

---Report the tests
---@param test Runnable
function DotsReporter:reportTest(test)
	if test:isSkipped() then
		self:printDot(Status.Skipped)
	elseif test:isFailed() then
		self:printDot(Status.Failed)
	elseif test:isPassed() then
		self:printDot(Status.Passed)
	end
	io.write(Terminal.reset())
end

return DotsReporter
