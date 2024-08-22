---@alias SearchFilter {status: Status, isSuite: boolean}

local context = require("lib.context")
local Status = require("lib.status")

local ctx = context.global()

---@class Runnable
---@field public description string
---@field public fn function
---@field public status Status|nil
---@field public err Error|nil
---@field protected execTime number
---@field protected isSuite boolean
local Runnable = {
	---@return Runnable[]
	getAll = function()
		local t = {}
		for i = 1, #ctx.tests do
			for j = 1, #ctx.tests[i] do
				t[#t + 1] = ctx.tests[i][j]
			end
		end
		return t
	end,

	---@param collection Runnable[]
	---@param filter SearchFilter
	filter = function(collection, filter)
		local t = {}
		for i = 1, #collection do
			local meet = true
			for k in pairs(filter) do
				if filter[k] ~= collection[i][k] then
					meet = false
					break
				end
			end
			if meet then
				t[#t + 1] = collection[i]
			end
		end
		return t
	end,
}

---New runnable instance.
---@param description? string
---@param fn? function
---@return Runnable
function Runnable:new(description, fn)
	local t = {
		execTime = 0,
		isSuite = false,
		description = description,
		err = nil,
		fn = fn,
		status = nil,
	}
	return setmetatable(t, {
		__index = self,
		__call = function(class, d, f)
			class:new(d, f):run()
		end,
	})
end

---Running the test.
function Runnable:run()
	local tstart = os.clock()
	self:appendToContext()

	if type(self.fn) ~= "function" and self.status ~= Status.skipped then
		local err = {
			message = "Runnable.it: callback is not a function",
			expected = "function",
			actual = type(self.fn),
			debuginfo = debug.getinfo(1),
			traceback = debug.traceback(),
		}
		self.err = err
		self.status = Status.actual
		return
	end

	-- Exec
	local ok, err = pcall(self.fn)

	-- not very elegant
	local describeInfo = debug.getinfo(5, "n")

	if self.status == Status.skipped or describeInfo.name == "skip" then
		-- if itInfo.name == "skip" or describeInfo.name == "skip" then
		self.status = Status.skipped
		return
	end

	-- local tdiff = string.format(" (%s)", time.format(os.clock() - tstart))
	local tdiff = os.clock() - tstart
	if not ok then
		err.description = self.description
		err.debuginfo = debug.getinfo(self.fn, "S")
		err.traceback = debug.traceback()

		self.execTime = tdiff
		self.err = err
		self.status = Status.actual
	else
		self.status = Status.expected
	end
end

---Skipping the task.
---@param description string
---@param fn function
function Runnable:skip(description, fn)
	local r = self:new(description, fn)
	r.status = Status.skipped
	r:run()
end

---Running only marked tasks.
---@param description string
---@param fn function
function Runnable:only(description, fn)
	-- TODO implement
end

---Appends current runnable to context.
---@protected
function Runnable:appendToContext()
	ctx.tests[ctx.level] = ctx.tests[ctx.level] or {}
	table.insert(ctx.tests[ctx.level], self)
end

return Runnable
