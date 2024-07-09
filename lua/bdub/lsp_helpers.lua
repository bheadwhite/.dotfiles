local notify = require("notify")
local telescope = require("telescope.builtin")

local function add_desc(description, bufnr)
	local opts = { buffer = bufnr, remap = false }
	opts.desc = description

	return opts
end

local M = {}

M.cursorToParent = function()
	--find constructor if none found then notify such and return
	local found = vim.fn.search("constructor(")

	if found == 0 then
		local exportFound = vim.fn.search("export", "bW")
		vim.cmd("normal! ww")

		if exportFound == 0 then
			notify.notify("No constructor, or export found", "error", { title = "Jump to Parent", timeout = 200 })
			return
		end
	end
end

M.jump_to_parent_class = function()
	M.cursorToParent()

	local current_buf = vim.api.nvim_get_current_buf()
	local params = vim.lsp.util.make_position_params()
	local current_uri = vim.uri_from_bufnr(current_buf)

	-- Ensure the context is set correctly for the references request
	params.context = { includeDeclaration = true }

	vim.lsp.buf_request(0, "textDocument/references", params, function(err, result)
		--sort results by line number
		table.sort(result, function(a, b)
			return a.range.start.line > b.range.start.line
		end)

		if err ~= nil then
			print("Error during references request: " .. err.message)
			return
		end

		-- Filter out unwanted references and the current file's URI
		local filtered_result = {}
		local added_uris = {}
		for _, ref in ipairs(result or {}) do
			local uri = ref.uri or ""
			if
				not added_uris[uri]
				and uri ~= current_uri
				and not (string.find(uri, "%.test%.") or string.find(uri, "stories") or string.find(uri, "mock"))
			then
				table.insert(filtered_result, ref)
				added_uris[uri] = true
			end
		end

		if filtered_result and #filtered_result == 1 then
			local uri = filtered_result[1].uri
			local bufnr = vim.uri_to_bufnr(uri)
			local range = filtered_result[1].range

			-- Jump to the location of the single reference
			vim.lsp.util.jump_to_location({ uri = uri, range = range })
			vim.api.nvim_set_current_buf(bufnr)
		elseif result then
			vim.cmd("Glance references")
		else
			print("No references found.")
		end
	end)
end

M.on_attach = function(bufnr)
	local function goToDefinition()
		telescope.lsp_definitions({ show_line = false })
	end

	local function goToSplitDefinition()
		telescope.lsp_definitions({ show_line = false, jump_type = "vsplit" })
	end

	local function goToTabDefinition()
		telescope.lsp_definitions({ show_line = false, jump_type = "tab" })
	end

	local function lspFinder()
		--dont fire events BufLeave or WinLeave
		vim.cmd("Glance references")
	end

	local function goToSplitReferences()
		telescope.lsp_references({ show_line = false, jump_type = "vsplit", include_declaration = false })
	end

	local function goToTypeDefinition()
		telescope.lsp_type_definitions({ show_line = false })
	end

	local function openTypeInSplit()
		telescope.lsp_type_definitions({ show_line = false, jump_type = "vsplit" })
	end

	local function goToTabTypeDefinition()
		telescope.lsp_type_definitions({ show_line = false, jump_type = "tab" })
	end

	local normal_keymaps = {
		{ "gi", goToDefinition, "go to defintion" },
		{ "gI", goToSplitDefinition, "open definition in split" },
		{ "g<tab>i", goToTabDefinition, "go to definition in new tab" },
		{ "gr", lspFinder, "lsp finder" },
		{ "gR", goToSplitReferences, "go to references v_split" },
		{ "gt", goToTypeDefinition, "go to type definition" },
		{ "gT", openTypeInSplit, "open type in split" },
		{ "g<tab>t", goToTabTypeDefinition, "go to type definition in new tab" },
		{ "<M-S-l>", vim.diagnostic.goto_next, "next diagnostic" },
		{ "<M-S-h>", vim.diagnostic.goto_prev, "prev diagnostic" },
		{ "<leader>vd", vim.diagnostic.open_float, "view diagnostic" },
		{ "<leader>vs", vim.lsp.buf.workspace_symbol, "workspace symbols" },
		{ "<leader>.", vim.lsp.buf.code_action, "code action" },
		{ "<C-A-n>", vim.lsp.buf.rename, "rename symbol" },
		{ "gh", vim.lsp.buf.hover, "hover" },
		{ "gH", vim.lsp.buf.signature_help, "signature help" },
	}

	for _, value in ipairs(normal_keymaps) do
		vim.keymap.set("n", value[1], value[2], add_desc(value[3], bufnr))
	end

	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, add_desc("signature help", bufnr))

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("TSFormat", { clear = true }),
		desc = "Format buffer on save",
		pattern = { "*.ts", "*.tsx" },
		callback = function()
			vim.lsp.buf.format()
		end,
	})

	vim.cmd([[augroup _lsp
    autocmd!
    autocmd BufWritePre * lua vim.lsp.buf.format()
  augroup end]])
end

return M
