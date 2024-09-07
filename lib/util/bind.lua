---Binds a value to the function, analogue function in JS .bind().
---@param func function
---@param ... any
---@return function
return function(func, ...)
	local args = table.unpack({ ... })
	return function(b)
		return func(args, b)
	end
end
