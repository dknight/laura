---Binds a value to the function, analogue function in JS .bind().
---@param fn function
---@param ... any
---@return function
return function(fn, ...)
	local args = table.unpack({ ... })
	return function(b)
		return fn(args, b)
	end
end
