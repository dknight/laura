---@alias SearchFilter {status: Status, isSuite: boolean}

local Context = require("lib.classes.Context")
local Status = require("lib.classes.Status")
local Queue = require("lib.classes.Queue")

local ctx = Context.global()

---@class Runnable
---@field public children Runnable[]
---@field public description string
---@field public err? Error
---@field public execTime number
---@field public filterOnly fun(root: Runnable)
---@field public func function
---@field public hooks {[HookType]: Hook}
---@field public level number
---@field public parent? Runnable
---@field public status? Status
---@field public traverse fun(suite: Runnable, func: fun(test: Runnable, i?: number))
---@field private _suite boolean
---@field private _only boolean
---@field protected createRootSuiteMaybe function
local Runnable = {
	__debug__ = 0,
}

---Filters only tests. This method modifies context in place.
---@oaram suite Runnable
Runnable.filterOnly = function(suite)
	suite = suite or ctx.root
	for i = #suite.children, 1, -1 do
		local test = suite.children[i]
		if suite:hasOnly() and not test:isOnly() or test:isSkipped() then
			table.remove(suite.children, i)
		end
		Runnable.filterOnly(test)
	end
end

---Traversing tests and suites tree
---@param suite Runnable
---@param func fun(test: Runnable, i?: number)
Runnable.traverse = function(suite, func)
	for i, test in ipairs(suite.children) do
		func(test, i)
		Runnable.traverse(test, func)
	end
end

---Creates root context if not yet exists.
Runnable.createRootSuiteMaybe = function()
	if not ctx.root then
		local root = Runnable:new(ctx.config._rootSuiteKey, function() end)
		ctx.root = root
		ctx.suites[0] = root
		ctx.level = ctx.level + 1
		ctx.current = root
	end
end

---Create a new Runnable instance.
---@param description? string
---@param func? function
---@return Runnable
function Runnable:new(description, func)
	local t = {
		children = {},
		description = description,
		err = nil,
		execTime = 0,
		func = func,
		_only = false,
		_suite = false,
		level = 0,
		parent = nil,
		status = nil,
		hooks = {
			[ctx.config._afterAllName] = {},
			[ctx.config._afterEachName] = {},
			[ctx.config._beforeAllName] = {},
			[ctx.config._beforeEachName] = {},
		},
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
	Runnable.createRootSuiteMaybe()
	self.level = ctx.level
	self.parent = ctx.suites[self.level - 1]
	table.insert(self.parent.children, self)
end

---Runs the all tests.
function Runnable:run()
	Runnable.__debug__ = Runnable.__debug__ + 1
	local tstart = os.clock()
	local parentIsSkipped = false
	self:traverseAncestors(function(parent)
		if parent:isSkipped() then
			parentIsSkipped = true
		end
	end, function(parent)
		return parent ~= ctx.root
	end)

	if parentIsSkipped or self:isSkipped() then
		self.status = Status.skipped
		return
	end
	if type(self.func) ~= "function" then
		self.err = {
			message = "Runnable.it: callback is not a function",
			expected = "function",
			actual = type(self.func),
			debuginfo = debug.getinfo(1),
			traceback = debug.traceback(),
		}
		self.status = Status.failed
		return
	end

	ctx.current = self

	local isFirst = self.parent.children[1] == self
	local isLast = self.parent.children[#self.parent.children] == self
	if isFirst then
		self.parent:runHooks(ctx.config._beforeAllName)
	end
	self.parent:runHooks(ctx.config._beforeEachName)

	local ok, err = pcall(self.func)
	if not ok then
		self.err = err
		self.err.debuginfo = debug.getinfo(self.func, "S")
		self.err.traceback = debug.traceback()
		self.status = Status.failed
	else
		self.status = Status.passed
	end

	self.parent:runHooks(ctx.config._afterEachName)
	if isLast then
		self.parent:runHooks(ctx.config._afterAllName)
	end

	self.execTime = os.clock() - tstart
end

---Skipping the task.
---@param description string
---@param func function
function Runnable:skip(description, func)
	local r = self:new(description, func)
	r:prepare()
	r.status = Status.skipped
end

---Mark test/suite as only to run.
---@param description string
---@param func function
function Runnable:only(description, func)
	local r = self:new(description, func)
	r._only = true
	r:prepare()
	r:traverseAncestors(function(parent)
		---@diagnostic disable-next-line
		parent._only = true
	end)
end

---@return boolean
function Runnable:isOnly()
	return self._only
end

---@return boolean
function Runnable:isSuite()
	return self._suite
end

---@return boolean
function Runnable:isPassed()
	return self.status == Status.passed
end

---@return boolean
function Runnable:isSkipped()
	return self.status == Status.skipped
end

---@return boolean
function Runnable:isFailed()
	return self.status == Status.failed
end

---Traverses ancestors up to the root, or stopped after
---predicate stopper func.
---@param func fun(parent: Runnable)
---@param stop? fun(parent: Runnable): boolean
function Runnable:traverseAncestors(func, stop)
	stop = stop or function()
		return true
	end
	local nextParent = self.parent
	while nextParent ~= nil and stop(nextParent) do
		func(nextParent)
		nextParent = nextParent.parent
	end
end

---@param typ HookType
function Runnable:runHooks(typ)
	for _, hook in ipairs(self.hooks[typ]) do
		local ok, err = pcall(hook.func)
		if not ok then
			self.err = {
				message = err,
			}
			self.status = Status.failed
		end
	end
end

---Checks that test or duite has only cases.
---@return boolean
function Runnable:hasOnly()
	for _, test in ipairs(self.children) do
		if test:isOnly() then
			return true
		end
	end
	return false
end

return Runnable
