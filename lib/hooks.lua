local constants = require("lib.util.constants")
local Hook = require("lib.classes.Hook")

return {
	[constants.AfterAllName] = Hook.new(constants.AfterAllName),
	[constants.AfterEachName] = Hook.new(constants.AfterEachName),
	[constants.BeforeAllName] = Hook.new(constants.BeforeAllName),
	[constants.BeforeEachName] = Hook.new(constants.BeforeEachName),
}
