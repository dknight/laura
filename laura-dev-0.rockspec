rockspec_format = "3.0"
package = "Laura"
version = "dev-0"
source = {
	url = "git+https://github.com/dknight/laura.git",
	branch = "main"
}
description = {
	summary = "Unit-testing framework written purely in Lua.",
	detailed = [[
      Laura is a lightweight unit-testing framework for Lua with simplicity in
      mind. The framework has no dependencies and works with Lua versions
      5.1—5.4 and LuaJIT.
   ]],
	homepage = "https://www.whoop.ee/laura",
	license = "MIT",
	issues_url = "https://github.com/dknight/laura/issues",
	maintainer = "Dmitri Smirnov <https://www.whoop.ee/>",
	labels = { "test", "unit-test" },
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	copy_directories = {
		"tests",
	},
	install = {
		bin = {
			"bin/laura",
		},
	},
}
test = {
	type = "command",
	command = "make test",
}
