---Read version number from file VERSION.
---@return string
return function()
	local fd, err = io.open("VERSION")
	if fd ~= nil then
		local contents = fd:read("*a")
		fd:close()
		return contents
	else
		error(err)
	end
end
