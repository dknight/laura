---@alias SearchFilter {status: Status, isSuite: boolean}

local context = require("lib.context")
local Status = require("lib.status")
local tablex = require("lib.tablex")

local ctx = context.global()

---@class Runnable
---@field public description string
---@field public fn function
---@field public status Status|nil
---@field public err Error|nil
---@field public level number
---@field protected execTime number
---@field protected isOnly boolean
---@field protected isSuite boolean
local Runnable = {
	---@param collection Runnable[][]
	---@param f SearchFilter
	---@return Runnable[][], number
	filter = function(collection, f)
		local n = 0
		local t = {}
		for i = 1, #collection do
			t[i] = tablex.filter(collection[i], function(v)
				for key in pairs(f) do
					if f[key] ~= v[key] then
						return false
					end
				end
				n = n + 1
				return true
			end)
		end
		return t, n
	end,

	---Get only tests.
	---
	---FIXME: The logic is as bit overkill here, definitely building trees is
	---most preferable solution here. Refactoring needed.
	---
	---@param collection Runnable[][]
	---@return Runnable[][], number
	getOnly = function(collection)
		local hasOnly = function(t)
			for _, v in pairs(t) do
				if v.isOnly then
					return true
				end
			end
			return false
		end

		local n = 0
		local t = {}
		local parent = nil
		for i = 1, #collection do
			local hasOnlyChildren = hasOnly(collection[i])
			t[i] = tablex.filter(collection[i], function(v)
				if v.isSuite then
					parent = v
				end
				if
					(parent.isOnly or not hasOnlyChildren)
					or (not v.isSuite and v.isOnly and hasOnlyChildren)
					or (v.isSuite and not v.isOnly and hasOnlyChildren)
				then
					if not v.isSuite then
						n = n + 1
					end
					return true
				else
				end
				return false
			end)
		end
		return t, n
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
		status = nil,
	}
	return setmetatable(t, {
		__index = self,
		__call = function(class, d, f)
			class:new(d, f):prepare()
		end,
	})
end

---Prepares the test case.
function Runnable:prepare()
	self.level = ctx.level
	self:appendToContext()
end

---Runs the test case.
function Runnable:run()
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
	local tstart = os.clock()
	local ok, err = pcall(self.fn)

	local tdiff = os.clock() - tstart
	if not ok then
		print(type(err), err)
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
	ctx.tests[ctx.level] = ctx.tests[ctx.level] or {}
	table.insert(ctx.tests[ctx.level], self)
end

return Runnable
