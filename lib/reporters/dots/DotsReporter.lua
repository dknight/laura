local Context = require("lib.classes.Context")
local labels = require("lib.labels")
local Reporter = require("lib.reporters.Reporter")
local Terminal = require("lib.classes.Terminal")
local Status = require("lib.classes.Status")

local ctx = Context.global()
local dot = "."

---@class DotsReporter : Reporter
local DotsReporter = {}

---@param results RunResults
function DotsReporter:new(results)
	setmetatable(results, { __index = DotsReporter })
	setmetatable(DotsReporter, { __index = Reporter })
	return results
end

---Print suite title.
---@param suite Runnable
function DotsReporter:printSuiteTitle(suite)
	-- noop
end

---Print failed test message.
---@private
---@param status Status
function DotsReporter:printDot(status)
	io.write(Terminal.setColor(status) .. dot)
end

---Report the tests
---@param suite? Runnable
function DotsReporter:reportTests(suite)
	if self.total == 0 then
		Terminal.printStyle(labels.noTests)
		return
	end
	suite = suite or ctx.root
	if suite == nil then
		error(labels.errorNoRoot)
	end
	for _, test in ipairs(suite.children) do
		if test:isSkipped() then
			self:printDot(Status.skipped)
		elseif test:isFailed() then
			self:printDot(Status.failed)
		elseif test:isPassed() then
			self:printDot(Status.passed)
		end
		self:reportTests(test)
	end
	io.write(Terminal.resetColor())
end

return DotsReporter
