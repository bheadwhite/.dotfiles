local lsp_zero = require("lsp-zero")
local ts_utils = require("nvim-lsp-ts-utils")
local telescope = require("telescope.builtin")
local lsp_selection_range = require("lsp-selection-range")
local lsp_status = require("lsp-status")

local function add_desc(description, bufnr)
	local opts = { buffer = bufnr, remap = false }
	opts.desc = description

	return opts
end

require("neodev").setup()

lsp_zero.preset("recommended")

lsp_zero.ensure_installed({
	"tsserver",
	"eslint",
	"lua_ls",
	"rust_analyzer",
})

-- Fix Undefined global 'vim'
lsp_zero.configure("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

lsp_zero.configure("tsserver", {
	init_options = {
		preferences = {
			importModuleSpecifierPreference = "non-relative",
		},
	},
	settings = {
		diagnostics = {
			ignoredCodes = { 2311, 80006 }, -- https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
		},
	},
	capabilities = vim.tbl_extend("force", lsp_status.capabilities, {
		textDocument = {
			selectionRange = {
				dynamicRegistration = true,
			},
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	}),
	on_attach = function(client, bufnr)
		lsp_status.register_client(client)
		lsp_status.on_attach(client)
		client.server_capabilities.documentFormattingProvider = false

		-- require("nvim-navbuddy").attach(client, bufnr)

		-- require("lsp_signature").on_attach({
		-- 	bind = true,
		-- 	handler_opts = {
		-- 		border = "single",
		-- 	},
		-- 	floating_window = false,
		-- 	virtual_text = true,
		-- }, bufnr)

		ts_utils.setup({
			import_all_timeout = 5000,
		})
		ts_utils.setup_client(client)

		vim.keymap.set("n", "<leader>r", ts_utils.rename_file, add_desc("rename file", bufnr))
		vim.keymap.set("n", "<C-M-o>", lsp_selection_range.trigger, add_desc("selection range", bufnr))
		vim.keymap.set("v", "<C-M-o>", lsp_selection_range.expand, add_desc("expand range", bufnr))
	end,
	root_dir = vim.loop.cwd,
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

local cmp_mappings = lsp_zero.defaults.cmp_mappings({
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
	-- ["<C-Space>"] = cmp.mapping(
	-- 	cmp.mapping.complete({
	-- 		config = {
	-- 			sources = {
	-- 				{ name = "nvim_lsp_signature_help" },
	-- 			},
	-- 		},
	-- 	}),
	-- 	{ "i", "c" }
	-- ),
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
cmp_mappings["<C-M-Tab>"] = nil

lsp_zero.setup_nvim_cmp({
	mapping = cmp_mappings,
	sources = {
		-- { name = "nvim_lsp_signature_help" },
		{ name = "nvim_lsp" },
		{ name = "path" },
	},
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

lsp_zero.on_attach(function(client, bufnr)
	local function goToDefinition()
		telescope.lsp_definitions({ show_line = false })
	end

	local function goToSplitDefinition()
		telescope.lsp_definitions({ show_line = false, jump_type = "vsplit" })
	end

	local function goToTabDefinition()
		telescope.lsp_definitions({ show_line = false, jump_type = "tab" })
	end

	local function goToReferences()
		telescope.lsp_references({ show_line = false, include_declaration = false })
	end

	local function goToSplitReferences()
		telescope.lsp_references({ show_line = false, jump_type = "vsplit", include_declaration = false })
	end

	local function goToTypeDefinition()
		telescope.lsp_type_definitions({ show_line = false })
	end

	local function goToSplitTypeDefinition()
		telescope.lsp_type_definitions({ show_line = false, jump_type = "vsplit" })
	end

	local normal_keymaps = {
		{ "gi", goToDefinition, "go to defintion" },
		{ "gI", goToSplitDefinition, "go to defintion v_split" },
		{ "gr", goToReferences, "go to references" },
		{ "gR", goToSplitReferences, "go to references v_split" },
		{ "gt", goToTypeDefinition, "go to type definition" },
		{ "gT", goToSplitTypeDefinition, "go to type definition v_split" },
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

	vim.keymap.set("v", "gi", goToTabDefinition, add_desc("go to defintion tab", bufnr))
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, add_desc("signature help", bufnr))
end)

lsp_zero.setup()

vim.diagnostic.config({
	virtual_text = true,
})
