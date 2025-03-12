---@alias Status {[key: string]: number}
---
---@enum (key) Status
local Status = {
	Common = 0,
	Failed = 1,
	Passed = 2,
	Skipped = 4,
	Unchanged = 8,
	Warning = 16,
}

return Status
