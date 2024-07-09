local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

local handleDown = function(fallback)
	if cmp.visible() then
		cmp.select_next_item()
	else
		fallback()
	end
end

local handleUp = function(fallback)
	if cmp.visible() then
		cmp.select_prev_item()
	else
		fallback()
	end
end

local cmp_mappings = {
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<CR>"] = cmp.mapping.confirm({ select = true }),
	["<M-Space>"] = cmp.mapping.complete(cmp_select),
	["<Up>"] = cmp.mapping.select_prev_item(cmp_select),
	["<Down>"] = cmp.mapping.select_next_item(cmp_select),
	["<M-j>"] = cmp.mapping(handleDown, { "i", "s" }),
	["<M-k>"] = cmp.mapping(handleUp, {
		"i",
		"s",
	}),
}

cmp.setup({
	mapping = cmp_mappings,
	sources = {
		{
			name = "nvim_lsp",
		},
	},
})
-- disable completion with tab
-- this helps with copilot setup
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil
cmp_mappings["<C-M-Tab>"] = nil
