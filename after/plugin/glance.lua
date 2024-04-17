local glance = require("glance")
local notify = require("notify")

local glanceState = {
	findTests = false,
}

glance.setup({
	-- your configuration
	detached = true,
	hooks = {
		before_open = function(results, open, jump)
			local filtered_results = {}
			if not glanceState.findTests then
				notify.notify(
					"Tests, mocks and stories are being filtered [<leader>t to toggle]",
					"info",
					{ title = "Glance", timeout = 200 }
				)
			end
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
	local newState = not glanceState.findTests
	local message = "Tests, mocks and stories are " .. (newState and "not filtered" or "filtered")
	notify.notify(message, "info", { title = "Glance", timeout = 200 })

	glanceState.findTests = newState
end

vim.keymap.set("n", "<leader>t", changeGlanceState, { noremap = true, silent = true })
