return {
	"mfussenegger/nvim-lint",
	config = function()
		require("lint").linters_by_ft = {
			python = { "flake8" },
		}

		vim.api.nvim_create_autocmd({
			"BufEnter",
			"WinEnter",
			"BufWritePost",
			"TextChanged",
			"InsertLeave",
		}, {
			callback = function()
				require("lint").try_lint()
			end,
		})

		local function run_flake8()
			-- Change to the project directory (assumes .flake8 is in the project root)
			local project_root = vim.fn.finddir(".git", ".;") -- Look for the .git directory to determine the project root
			if project_root == "" then
				print("Project root not found")
				return
			end

			local project_dir = vim.fn.fnamemodify(project_root, ":h")

			-- Run flake8 from the project root and capture the output
			local flake8_command = "cd " .. project_dir .. " && flake8 --format=default"
			local handle = io.popen(flake8_command)
			if not handle then
				return
			end

			local result = handle:read("*a")
			handle:close()

			if result == "" then
				print("No errors found by flake8")
				return
			end

			-- Check if there are any errors

			-- Parse the flake8 output into a quickfix list
			local qf_list = {}
			for line in result:gmatch("[^\r\n]+") do
				local filename, lnum, col, message = line:match("([^:]+):(%d+):(%d+): (.+)")
				if filename and lnum and col and message then
					table.insert(qf_list, {
						filename = filename,
						lnum = tonumber(lnum),
						col = tonumber(col),
						text = message,
					})
				end
			end

			-- Populate the quickfix list
			vim.fn.setqflist({}, " ", {
				title = "Flake8",
				items = qf_list,
			})

			-- Open the quickfix list
			vim.cmd("copen")
		end

		-- Create a global command to run flake8 and populate the quickfix list
		vim.api.nvim_create_user_command("RunFlake8", run_flake8, {})
	end,
}
