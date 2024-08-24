---@alias SearchFilter {status: Status, isSuite: boolean}

local Context = require("lib.classes.Context")
local Status = require("lib.classes.Status")
local tablex = require("lib.ext.tablex")

local ctx = Context.global()

---@class Runnable
---@field public description string
---@field public fn function
---@field public status Status|nil
---@field public err Error|nil
---@field public level number
---@field public parent Runnable | nil
---@field public isOnly boolean
---@field public isSuite boolean
---@field private execTime number
local Runnable = {
	__debug__ = 0,
	---@param collection Runnable[]
	---@param f SearchFilter
	---@return Runnable[]
	filter = function(collection, f)
		local newt = tablex.filter(collection, function(v)
			for k in pairs(f) do
				if f[k] ~= v[k] then
					return false
				end
			end
			return true
		end)
		return newt
	end,

	---@param collection  Runnable[]
	---@param cb function(runnable: Runnable)
	traverse = function(collection, cb)
		for i = 1, #collection do
			cb(collection[i])
		end
	end,

	---Get only tests.
	---
	---FIXME: The logic is as bit overkill here, definitely building trees is
	---most preferable solution here. Refactoring needed.
	---
	---@param collection Runnable[]
	---@return Runnable[], number
	getOnly = function(collection)
		local n = 0
		local newt = {}
		for i = 1, #collection do
			local test = collection[i]
			local hasOnlyChildren = test:hasOnly()
			if
				(test.isSuite and hasOnlyChildren)
				or (not test.isSuite and test.isOnly)
				or (test.parent ~= nil and test.parent.isOnly)
			then
				newt[#newt + 1] = test
			end
		end
		return newt, n
	end,
}

---New runnable instance.
---@param description? string
---@param fn? function
---@return Runnable
function Runnable:new(description, fn)
	local t = {
		description = description,
		err = nil,
		execTime = 0,
		fn = fn,
		isOnly = false,
		isSuite = false,
		level = 0,
		parent = nil,
		status = nil,
	}
	return setmetatable(t, {
		__index = self,
		__call = function(_, d, f)
			self:new(d, f):prepare()
		end,
	})
end

---Prepares the test case.
function Runnable:prepare()
	Runnable.__debug__ = Runnable.__debug__ + 1
	self.level = ctx.level
	self:appendToContext()
end

---Runs the test case.
function Runnable:run()
	local tstart = os.clock()
	if self.level == 0 then
		self.parent = nil
	end
	if self.parent ~= nil and self.parent.status == Status.skipped then
		self.status = Status.skipped
		return
	end
	if self.status == Status.skipped then
		return
	end
	if type(self.fn) ~= "function" then
		self.err = {
			message = "Runnable.it: callback is not a function",
			expected = "function",
			actual = type(self.fn),
			debuginfo = debug.getinfo(1),
			traceback = debug.traceback(),
		}
		self.status = Status.failed
		return
	end

	-- Exec
	local ok, err = pcall(self.fn)

	local tdiff = os.clock() - tstart
	if not ok then
		self.err = err
		self.err.debuginfo = debug.getinfo(self.fn, "S")
		self.err.traceback = debug.traceback()
		self.status = Status.failed
	else
		self.status = Status.passed
	end
	self.execTime = tdiff
end

---Skipping the task.
---@param description string
---@param fn function
function Runnable:skip(description, fn)
	local r = self:new(description, fn)
	r.status = Status.skipped
	r:prepare()
end

---Running only marked tasks.
---@param description string
---@param fn function
function Runnable:only(description, fn)
	local r = self:new(description, fn)
	r.isOnly = true
	r:prepare()
end

---Appends current runnable to context.
---@protected
function Runnable:appendToContext()
	ctx.tests[#ctx.tests + 1] = self
end

function Runnable:hasOnly()
	if self.parent == nil then
		return false
	end
	local found = tablex.filter(ctx.tests, function(test)
		return test.parent ~= nil and test.parent == self.parent and test.isOnly
	end)
	return #found > 0
end

return Runnable
