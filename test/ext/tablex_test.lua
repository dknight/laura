local laura = require("laura")
local describe = laura.describe
local expect = laura.expect
local it = laura.it
local tablex = require("laura.ext.tablex")

describe("tablex module", function()
	it("should import tablex as standalone module", function()
		expect(function()
			require(table.concat({ "src", "laura", "ext", "tablex" }, "."))
		end).notToFail()
	end)

	describe("diff", function()
		local t1 = {
			a = "foo",
			b = {
				c = "bar",
			},
			d = 12,
		}
		local t2 = {
			a = "foo",
			b = {
				c = "bar",
				e = "ef",
				g = {
					h = "i",
					j = "k",
				},
			},
			d = 12,
		}
		it("should count diffs", function()
			local res, counts = tablex.diff(t1, t2)
			expect(counts.added).toEqual(1)
			expect(counts.removed).toEqual(3)
			expect(res.mod).toBeNil()
			expect(res.del).toBeNil()
			expect(res.sub).toHaveLength(0)
		end)

		it("should create a polygon", function()
			local poly = {
				{ x = 0, y = 100 },
				{ x = 100, y = 100 },
				{ x = 0, y = 200 },
			}
			expect(poly).toBe({
				{ x = 0, y = 100 },
				{ x = 100, y = 100 },
				{ x = 0, y = 200 }
			})
		end)
	end)

	describe("equal", function()
		local t1 = { a = 1 }
		local t2 = { a = 2 }
		it("should have equal tables", function()
			local t3 = t1
			expect(tablex.equal(t1, t3)).toBe(true)
		end)

		it("should not have equal tables", function()
			expect(tablex.equal(t1, t2)).toBe(false)
		end)
	end)

	describe("diffToString", function()
		local t1 = { a = 1 }
		local t2 = { a = 2 }

		it("should compare string difference", function()
			local diff = tablex.diff(t1, t2)
			expect(tablex.diffToString(t1, diff, 0, false)).toBe([=[{
	-["a"] = 2
	+["a"] = 1
}
]=])
		end)

		it("should compare empty tabls difference", function()
			local t3 = {}
			local t4 = {}
			local diff = tablex.diff(t3, t4)
			expect(tablex.diffToString(t3, diff, 0, false)).toBe([[{
}
]])
		end)
	end)

	describe("inline", function()
		it("should print table inline values", function()
			local t = { a = 1, b = "foo" }
			expect(tablex.inline(t)).toBe([[{ 1, "foo" }]])
		end)

		it("should print table inline values with keys", function()
			local t = { ["a"] = 1, b = "foo" }
			expect(tablex.inline(t, true)).toBe([[{ a = 1, b = "foo" }]])
		end)
	end)

	describe("patch", function()
		it("should patch a table", function()
			local t1 = { a = 1, b = "foo" }
			local t2 = { c = "bar" }
			local diff = tablex.diff(t1, t2)
			local p = tablex.patch(t1, diff)
			expect(p).toBe({
				a = 1,
				b = "foo",
				c = "bar",
			})
		end)

		it("should patch an empty table", function()
			local t1 = {}
			local t2 = {}
			local diff = tablex.diff(t1, t2)
			local p = tablex.patch(t1, diff)
			expect(p).toBe({})
		end)

		it("should patch a table with removals", function()
			local t1 = { a = 1, b = "foo" }
			local t2 = { a = nil, b = "boo" }
			local diff = tablex.diff(t1, t2)
			local p = tablex.patch(t1, diff)
			expect(p).toBe({ a = 1, b = "boo" })
		end)
	end)
end)
