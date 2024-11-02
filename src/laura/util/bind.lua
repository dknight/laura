---This is no actual bind funcion, maybe not the best wau to do,
---but I am lazy to refactor.
---@param func function
---@param ... any
---@return function
return function(func, ...)
	local args = ...
	return function(b)
		return func(args, b)
	end
end
