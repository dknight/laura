---@alias SearchFilter {status: Status, isSuite: boolean}

local Context = require("lib.classes.Context")
local Status = require("lib.classes.Status")
local tablex = require("lib.ext.tablex")

local ctx = Context.global()

---@class Runnable
---@field public children Runnable[]
---@field public description string
---@field public err Error | nil
---@field public execTime number
---@field public fn function
---@field public isOnly boolean
---@field public isSuite boolean
---@field public level number
---@field public parent Runnable | nil
---@field public status Status | nil'
---@field public filter fun(collection: Runnable[], fn: SearchFilter): Runnable[]
---@field public traverse fun(collection: Runnable[], cb: fun(suite: Runnable, index?: number))
---@field public filterOnly fun(root: Runnable)
local Runnable = {
	__debug__ = 0,
}

Runnable.filter = function(collection, fn)
	local newt = tablex.filter(collection, function(v)
		for k in pairs(fn) do
			if fn[k] ~= v[k] then
				return false
			end
		end
		return true
	end)
	return newt
end

Runnable.traverse = function(collection, cb)
	for i, test in ipairs(collection) do
		cb(test, i)
	end
end

Runnable.filterOnly = function(root)
	for _, child in ipairs(root.children) do
		-- root children
		if child.isOnly then
			table.insert(ctx.onlyTests, child)
		end

		if not child:hasOnly() then
			for _, test in ipairs(child.children) do
				table.insert(ctx.onlyTests, test)
			end
		end

		Runnable.filterOnly(child)
	end
end

---Create a new Runnable instance.
---@param description? string
---@param fn? function
---@return Runnable
function Runnable:new(description, fn)
	local t = {
		children = {},
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

---Prepares the tests before running.
function Runnable:prepare()
	self.level = ctx.level
	self.parent = ctx.suitesLevels[self.level - 1]
	table.insert(self.parent.children, self)
	table.insert(ctx.tests, self)
end

---Runs the all tests.
function Runnable:run()
	Runnable.__debug__ = Runnable.__debug__ + 1
	local tstart = os.clock()
	local parentIsSkipped = false
	local nxt = self.parent
	while nxt ~= nil and nxt ~= ctx.root do
		if nxt.status == Status.Skipped then
			parentIsSkipped = true
			break
		end
		nxt = nxt.parent
	end
	if parentIsSkipped then
		self.status = Status.Skipped
	end
	if parentIsSkipped or self.status == Status.Skipped then
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
		self.status = Status.Failed
		return
	end

	-- Exec
	local ok, err = pcall(self.fn)
	if not ok then
		self.err = err
		self.err.debuginfo = debug.getinfo(self.fn, "S")
		self.err.traceback = debug.traceback()
		self.status = Status.Failed
	else
		self.status = Status.Passed
	end
	self.execTime = os.clock() - tstart
end

---Skipping the task.
---@param description string
---@param fn function
function Runnable:skip(description, fn)
	local r = self:new(description, fn)
	r:prepare()
	r.status = Status.Skipped
end

---Running only marked tasks.
---@param description string
---@param fn function
function Runnable:only(description, fn)
	local r = self:new(description, fn)
	r:prepare()
	r.isOnly = true
	r.parent.isOnly = true
end

---Checks that test or duite has only cases.
---@return boolean
function Runnable:hasOnly()
	for _, test in ipairs(self.children) do
		if test.isOnly then
			return true
		end
	end
	return false
end

return Runnable
