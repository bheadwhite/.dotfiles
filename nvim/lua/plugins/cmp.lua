return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "luckasRanarison/tailwind-tools.nvim",
    "onsails/lspkind-nvim",
  },
  config = function()
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
      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({
            select = true,
          })
        else
          fallback()
        end
        fallback()
      end),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "s" }),
      ["<C-e>"] = cmp.mapping.close(),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
      ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
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
        { name = "nvim_lsp" },
      },
      formatting = {
        format = require("lspkind").cmp_format({
          before = require("tailwind-tools.cmp").lspkind_format,
        }),
      },
      sorting = {
        priority_weight = 2,
        comparators = {
          function(entry1, entry2)
            local filetype = vim.bo.filetype
            if filetype == "python" then
              -- Existing kind comparison logic
              local _, entry1_kind = entry1.completion_item.label:find("=$")
              local _, entry2_kind = entry2.completion_item.label:find("=$")

              if entry1_kind and not entry2_kind then
                return true
              elseif not entry1_kind and entry2_kind then
                return false
              end
            end

            return nil
          end,
          cmp.config.compare.score,
          cmp.config.compare.exact,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.recently_used,
          cmp.config.compare.offset,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
    })

    -- disable completion with tab
    -- this helps with copilot setup
    cmp_mappings["<Tab>"] = nil
    cmp_mappings["<S-Tab>"] = nil
    cmp_mappings["<C-M-Tab>"] = nil
  end,
}
