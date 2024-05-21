local glance = require("glance")
local notify = require("notify")

local glanceState = {
	findTests = false,
}

local function showFilterNotify(shouldFindTests)
	local message = ""
	if shouldFindTests then
		message = "Showing ALL ([leader+t] to filter)"
	else
		message = "Filtering Tests, Mocks and Stories ([leader+t] to clear)"
	end

	notify.notify(message, (shouldFindTests and "info" or "warn"), { title = "Filter References", timeout = 200 })
end

glance.setup({
	-- your configuration
	detached = true,
	hooks = {
		before_open = function(results, open, jump)
			local filtered_results = {}
			showFilterNotify(glanceState.findTests)
			local bufUri = vim.uri_from_bufnr(0):lower()

			for _, result in ipairs(results) do
				local resultUri = result.uri:lower() or result.targetUri:lower()
				local testFound = resultUri:find(".test") or resultUri:find("mock") or resultUri:find(".stories")

				if not testFound then
					table.insert(filtered_results, result)
				end

				if glanceState.findTests and testFound then
					table.insert(filtered_results, result)
				end
			end

			if #filtered_results == 1 then
				local target_uri = results[1].uri or results[1].targetUri

				if target_uri == bufUri then
					jump(results[1])
				else
					open(filtered_results)
				end
			else
				open(filtered_results)
			end
		end,
	},
})

changeGlanceState = function()
	local shouldFindTests = not glanceState.findTests
	showFilterNotify(shouldFindTests)

	glanceState.findTests = shouldFindTests
end

vim.keymap.set("n", "<leader>t", changeGlanceState, { noremap = true, silent = true })
