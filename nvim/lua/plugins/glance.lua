return {
  "dnlhc/glance.nvim",
  cond = not vim.g.vscode,
  dependencies = {
    "rcarriga/nvim-notify",
  },
  config = function()
    local glance = require("glance")

    -- LSP servers always return the declaration itself in the reference list
    -- (glance hardcodes includeDeclaration = true), so drop the occurrence the
    -- cursor is already sitting on -- for gp that is the definition.
    local function isUnderCursor(result, bufUri, cursorLine, cursorCol)
      local resultUri = (result.uri or result.targetUri or ""):lower()
      if resultUri ~= bufUri then
        return false
      end

      local range = result.range or result.targetSelectionRange or result.targetRange
      if not range then
        return false
      end

      local afterStart = cursorLine > range.start.line
        or (cursorLine == range.start.line and cursorCol >= range.start.character)
      local beforeEnd = cursorLine < range["end"].line
        or (cursorLine == range["end"].line and cursorCol < range["end"].character)

      return afterStart and beforeEnd
    end

    local function gatherFilteredResults(results, bufUri, cursorLine, cursorCol)
      local filtered_results = {}
      for _, result in ipairs(results) do
        local resultUri = (result.uri or result.targetUri or ""):lower()
        local testFound = resultUri:find(".test") or resultUri:find("mock")

        if isUnderCursor(result, bufUri, cursorLine, cursorCol) then
          goto continue
        end

        if not testFound then
          table.insert(filtered_results, result)
        end

        if require("bdub.lsp_helpers").glanceState.findTests and testFound then
          table.insert(filtered_results, result)
        end

        ::continue::
      end

      return filtered_results
    end

    glance.setup({
      height = 50,
      -- your configuration
      detached = true,
      mappings = {
        list = {
          ["<C-M-F14>"] = glance.actions.jump_vsplit,
        },
      },
      hooks = {
        before_open = function(results, open, jump)
          local bufUri = vim.uri_from_bufnr(0):lower()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local ok, filtered_results = pcall(gatherFilteredResults, results, bufUri, cursor[1] - 1, cursor[2])

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

          -- one result left after filtering -- go straight there, in this file
          -- or any other. show_document handles the cross-file case.
          if #filtered_results == 1 then
            jump(filtered_results[1])
          else
            open(filtered_results)
          end
        end,
      },
    })
  end,
}
