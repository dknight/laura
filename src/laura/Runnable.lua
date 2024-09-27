---@alias SearchFilter {status: Status, isSuite: boolean}

local Context = require("laura.Context")
local Status = require("laura.Status")
local Labels = require("laura.Labels")
local errorx = require("laura.ext.errorx")

---@class Runnable
---@field public children Runnable[]
---@field public description string
---@field public error? Error
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
---@field protected _ctx Context
local Runnable = {
	_ctx = Context.global(),
}

---Filters only tests. This method modifies context in place.
---@oaram suite Runnable
Runnable.filterOnly = function(suite)
	suite = suite or Runnable._ctx.root
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
	if not Runnable._ctx.root then
		local root = Runnable:new(
			Runnable._ctx.config._rootSuiteKey,
			function() end
		)
		Runnable._ctx.root = root
		Runnable._ctx.suites[0] = root
		Runnable._ctx.level = Runnable._ctx.level + 1
		Runnable._ctx.current = root
	end
end

---Create a new Runnable instance.
---@param description? string
---@param func? function
---@return Runnable
function Runnable:new(description, func)
	local t = {
		_only = false,
		_suite = false,
		children = {},
		description = description,
		error = nil,
		execTime = 0,
		func = func,
		level = 0,
		parent = nil,
		status = nil,
		hooks = {
			[Runnable._ctx.config._afterAllName] = {},
			[Runnable._ctx.config._afterEachName] = {},
			[Runnable._ctx.config._beforeAllName] = {},
			[Runnable._ctx.config._beforeEachName] = {},
		},
	}
	return setmetatable(t, {
		__index = self,
		__call = function(class, d, f)
			class.new(class, d, f):prepare()
		end,
	})
end

---Prepares the tests before running.
function Runnable:prepare()
	Runnable.createRootSuiteMaybe()
	self.level = self._ctx.level
	self.parent = self._ctx.suites[self.level - 1]
	table.insert(self.parent.children, self)
end

---Runs the all tests.
function Runnable:run()
	local tstart = os.clock()
	local parentIsSkipped = false
	self:traverseAncestors(function(parent)
		if parent:isSkipped() then
			parentIsSkipped = true
		end
	end, function(parent)
		return parent ~= self._ctx.root
	end)

	if parentIsSkipped or self:isSkipped() then
		self.status = Status.Skipped
		return
	end
	if type(self.func) ~= "function" then
		self.error = errorx.new({
			title = string.format(
				"Runnable.Test: %s",
				Labels.ErrorCallbackNotFunction
			),
			actual = "function",
			expected = type(self.func),
			getinfo = debug.getinfo(1),
			traceback = debug.traceback(),
		})
		self.status = Status.Failed
		return
	end

	self._ctx.current = self

	local isFirst = self.parent.children[1] == self
	local isLast = self.parent.children[#self.parent.children] == self
	if isFirst then
		self.parent:runHooks(self._ctx.config._beforeAllName)
	end
	self.parent:runHooks(self._ctx.config._beforeEachName)

	local ok, err = pcall(self.func)
	if not ok then
		self.error = err
		self.error.title = self.description
		self.error.debuginfo = debug.getinfo(self.func, "SL")
		self.error.traceback = debug.traceback()
		self.status = Status.Failed
	else
		self.status = Status.Passed
	end

	self.parent:runHooks(self._ctx.config._afterEachName)
	if isLast then
		self.parent:runHooks(self._ctx.config._afterAllName)
	end

	self.execTime = os.clock() - tstart
end

---Skipping the task.
---@param description string
---@param func function
function Runnable:skip(description, func)
	local r = self:new(description, func)
	r:prepare()
	r.status = Status.Skipped
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
	return self.status == Status.Passed
end

---@return boolean
function Runnable:isSkipped()
	return self.status == Status.Skipped
end

---@return boolean
function Runnable:isFailed()
	return self.status == Status.Failed
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
			self.error = {
				title = err,
			}
			self.status = Status.Failed
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
