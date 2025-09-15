return {
  "dnlhc/glance.nvim",
  dependencies = {
    "rcarriga/nvim-notify",
  },
  config = function()
    local glance = require("glance")

    local function gatherFilteredResults(results)
      local filtered_results = {}
      for _, result in ipairs(results) do
        local resultUri = result.uri:lower() or result.targetUri:lower()
        local testFound = resultUri:find(".test") or resultUri:find("mock")

        if not testFound then
          table.insert(filtered_results, result)
        end

        if require("bdub.lsp_helpers").glanceState.findTests and testFound then
          table.insert(filtered_results, result)
        end
      end

      return filtered_results
    end

    glance.setup({
      height = 50,
      -- your configuration
      detached = true,
      mappings = {
        list = {
          ["<c-v>"] = glance.actions.jump_vsplit,
        },
      },
      hooks = {
        before_open = function(results, open, jump)
          local bufUri = vim.uri_from_bufnr(0):lower()
          local ok, filtered_results = pcall(gatherFilteredResults, results)

          if not ok then
            print("Error gathering filtered results")
            return
          end

          -- if there are no results, return early
          if #filtered_results == 0 then
            require("notify").notify("No results found")
            return
          end

          require("bdub.lsp_helpers").showFilterNotify()

          if #filtered_results == 1 then
            local target_uri = results[1].uri or results[1].targetUri

            if target_uri == bufUri then
              jump(filtered_results[1])
            else
              open(filtered_results)
            end
          else
            open(filtered_results)
          end
        end,
      },
    })
  end,
}
