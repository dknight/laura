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
---@field private _suite boolean
---@field private _only boolean
---@field protected ctx Context
local Runnable = {
	ctx = Context.global(),
}

---@oaram suite Runnable
Runnable.filterOnly = function(suite)
	suite = suite or Runnable.ctx.root
	for i = #suite.children, 1, -1 do
		local test = suite.children[i]
		if suite:hasOnly() and not test:isOnly() or test:isSkipped() then
			table.remove(suite.children, i)
		end
		Runnable.filterOnly(test)
	end
end

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
	if not Runnable.ctx.root then
		local root = Runnable:new(Runnable.ctx.config._rootKey, function() end)
		Runnable.ctx.root = root
		Runnable.ctx.suites[0] = root
		Runnable.ctx.level = Runnable.ctx.level + 1
		Runnable.ctx.current = root
	end
end

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
			[Runnable.ctx.config._afterAllName] = {},
			[Runnable.ctx.config._afterEachName] = {},
			[Runnable.ctx.config._beforeAllName] = {},
			[Runnable.ctx.config._beforeEachName] = {},
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
	self.level = self.ctx.level
	self.parent = self.ctx.suites[self.level - 1]
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
		return parent ~= self.ctx.root
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

	self.ctx.current = self

	local isFirst = self.parent.children[1] == self
	local isLast = self.parent.children[#self.parent.children] == self
	if isFirst then
		self.parent:runHooks(self.ctx.config._beforeAllName)
	end
	self.parent:runHooks(self.ctx.config._beforeEachName)

	local ok, err = pcall(self.func)
	if not ok then
		if type(err) == "string" then
			self.error = errorx.new({
				title = err,
				actual = nil,
				expected = err,
			})
		else
			self.error = err
			self.error.title = self.description
			self.error.debuginfo = debug.getinfo(self.func, "SL")
			self.error.traceback = debug.traceback()
		end

		self.status = Status.Failed
	else
		self.status = Status.Passed
	end

	self.parent:runHooks(self.ctx.config._afterEachName)
	if isLast then
		self.parent:runHooks(self.ctx.config._afterAllName)
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

---Traverses ancestors up to the root, or stopped after predicate stopper func.
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
	-- Maybe use grandparents, etc, go up to tree.
	local hooks = {}
	if #self.hooks[typ] > 0 then
		hooks = self.hooks[typ]
	elseif self.parent ~= nil and #self.parent.hooks[typ] > 0 then
		hooks = self.parent.hooks[typ]
	end
	for _, hook in ipairs(hooks) do
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
