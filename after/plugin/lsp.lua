local lsp = require("lsp-zero")
local ts_utils = require("nvim-lsp-ts-utils")
local telescope = require("telescope.builtin")

lsp.preset("recommended")

lsp.ensure_installed({
	"tsserver",
	"eslint",
	"sumneko_lua",
	"rust_analyzer",
})

-- Fix Undefined global 'vim'
lsp.configure("sumneko_lua", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

lsp.configure("tsserver", {
	init_options = {
		preferences = {
			importModuleSpecifierPreference = "non-relative",
		},
		maxTsServerMemory = 4096,
	},
	capabilities = {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	},
	root_dir = vim.loop.cwd,
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<CR>"] = cmp.mapping.confirm({ select = true }),
	["<M-Space>"] = cmp.mapping(
		cmp.mapping.complete({
			config = {
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
				},
			},
		}),
		{ "i", "c" }
	),
	["<C-Space>"] = cmp.mapping(
		cmp.mapping.complete({
			config = {
				sources = {
					{ name = "nvim_lsp_signature_help" },
				},
			},
		}),
		{ "i", "c" }
	),
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
})

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
	sources = {
		{ name = "nvim_lsp_signature_help" },
		{ name = "nvim_lsp" },
		{ name = "path" },
	},
})

local function preview_location_callback(_, result)
	if result == nil or vim.tbl_isempty(result) then
		return nil
	end
	vim.lsp.util.preview_location(result[1])
end

function PeekDefinition()
	local params = vim.lsp.util.make_position_params()
	return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
end

local function add_desc(description, bufnr)
	local opts = { buffer = bufnr, remap = false }
	opts.desc = description

	return opts
end

lsp.set_preferences({
	suggest_lsp_servers = false,
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
	set_lsp_keymaps = false,
})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false

		ts_utils.setup({
			import_all_timeout = 5000,
		})
		ts_utils.setup_client(client)

		vim.keymap.set("n", "<leader>R", ts_utils.rename_file, add_desc("rename file", bufnr))
	end

	vim.keymap.set("n", "gi", function()
		telescope.lsp_definitions({ { show_line = false } })
	end, opts)
	vim.keymap.set("n", "gI", function()
		telescope.lsp_definitions({ show_line = false, jump_type = "vsplit" })
	end, add_desc("implementation", bufnr))
	vim.keymap.set("n", "gr", function()
		telescope.lsp_references({ show_line = false })
	end, add_desc("references", bufnr))
	vim.keymap.set("n", "gR", function()
		telescope.lsp_references({ jump_type = "vsplit", show_line = false })
	end, add_desc("references split", bufnr))
	vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>vs", vim.lsp.buf.workspace_symbol, add_desc("workspace symbols", bufnr))
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, add_desc("view diagnostic", bufnr))
	vim.keymap.set("n", "<M-S-l>", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<M-S-h>", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, add_desc("code action", bufnr))
	vim.keymap.set("n", "<C-A-n>", vim.lsp.buf.rename, add_desc("rename symbol", bufnr))
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "gH", vim.lsp.buf.signature_help, add_desc("signature help", bufnr))
	vim.keymap.set("n", "gp", PeekDefinition, add_desc("peek definition", bufnr))

	vim.keymap.set("n", "gt", function()
		telescope.lsp_type_definitions({ show_line = false })
	end, add_desc("type definition", bufnr))
	vim.keymap.set("n", "gT", function()
		telescope.lsp_type_definitions({ jump_type = "vsplit", show_line = false })
	end, add_desc("type definition split", bufnr))
end)

lsp.setup()

vim.diagnostic.config({
	virtual_text = true,
})
