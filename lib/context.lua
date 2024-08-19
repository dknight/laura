---@alias Context table{
---passed: number,
---failed: number,
---total: number,
---skipped: number,
---level: number,
---errors: Error[]
---}

---@alias Results {aura: Context}
---@type table {global: fun(): Results}
return {
	---@return Results
	global = function()
		return _G
	end,
}
