local Constants = require("lib.util.constants")
local Hook = require("lib.classes.Hook")

return {
	[Constants.AfterAllName] = Hook.new(Constants.AfterAllName),
	[Constants.AfterEachName] = Hook.new(Constants.AfterEachName),
	[Constants.BeforeAllName] = Hook.new(Constants.BeforeAllName),
	[Constants.BeforeEachName] = Hook.new(Constants.BeforeEachName),
}
