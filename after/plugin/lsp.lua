local lsp_zero = require("lsp-zero")
local telescope = require("telescope.builtin")
local notify = require("notify")

local function add_desc(description, bufnr)
	local opts = { buffer = bufnr, remap = false }
	opts.desc = description

	return opts
end

lsp_zero.preset("recommended")

-- lsp_zero.ensure_installed({
-- 	"eslint",
-- 	"lua_ls",
-- 	"rust_analyzer",
-- })

-- Fix Undefined global 'vim'
lsp_zero.configure("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
				disable = { "lowercase-global" },
			},
		},
	},
})

local function goToConstructor()
	local found = vim.fn.search("constructor(")

	if found == 0 then
		print("no constructor found")
	else
		vim.cmd([[/constructor]])
		vim.cmd([[nohl| normal ^]])
	end
end

local function jump_to_parent_class()
	--find constructor if none found then notify such and return
	local found = vim.fn.search("constructor(")

	if found == 0 then
		notify.notify("No constructor found", "error", { title = "Jump to Parent", timeout = 200 })
		return
	end

	goToConstructor()
	local current_buf = vim.api.nvim_get_current_buf()
	local params = vim.lsp.util.make_position_params()
	local current_uri = vim.uri_from_bufnr(current_buf)

	-- Ensure the context is set correctly for the references request
	params.context = { includeDeclaration = true }

	vim.lsp.buf_request(0, "textDocument/references", params, function(err, result)
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

-- To use this function, you can map it to a keybinding in your Neovim configuration.
vim.keymap.set("n", "gp", jump_to_parent_class, { noremap = true, silent = true })

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

lsp_zero.extend_cmp()

local cmp_mappings = {
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<CR>"] = cmp.mapping.confirm({ select = true }),
	["<M-Space>"] = cmp.mapping.complete(cmp_select),
	["<M-j>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_next_item()
		else
			fallback()
		end
	end, {
		"i",
		"s",
	}),
	["<M-k>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_prev_item()
		else
			fallback()
		end
	end, {
		"i",
		"s",
	}),
}

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil
cmp_mappings["<C-M-Tab>"] = nil

cmp.setup({
	mapping = cmp_mappings,
})

lsp_zero.set_preferences({
	suggest_lsp_servers = false,
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
	set_lsp_keymaps = false,
})

lsp_zero.on_attach(function(_, bufnr)
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
end)

lsp_zero.setup()

vim.diagnostic.config({
	virtual_text = true,
})
