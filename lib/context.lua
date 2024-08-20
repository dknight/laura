---@alias Context{aura: {passed: number, failed: number, total: number, skipped: number, level: number, errors: Error[]}}

---@return Context
local function global()
	-- TODO return _G['aura'] ?
	return _G
end

return {
	global = global,
}
