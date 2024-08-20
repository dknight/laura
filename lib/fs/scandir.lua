local sys = require("lib.util.sys")

---@param directory string
---@return table{[number]: string}
return function(directory)
	local cmd
	--- TODO better test on windows
	if sys.isWindows() then
		cmd = "DIR /S/B/O:n *_test.lua"
	else
		cmd = "find '%s' -type f -name '*_test.lua' -print0 | sort"
	end
	local i, t = 0, {}
	local fd = assert(io.popen((cmd):format(directory), "r"))
	local list = fd:read("*a")
	fd:close()

	for filename in list:gmatch("[^\0]+") do
		i = i + 1
		t[i] = filename
	end
	return t
end
