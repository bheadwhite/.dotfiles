function R(name)
  require("plenary.reload").reload_module(name)
end

return {
  -- Emitted by the caps+space chord (verified via i_CTRL-V). Bound in
  -- lua/plugins/claudecode.lua (n/x -> point Claude here) and lua/plugins/copilot.lua (i).
  hyper_space_key = "<C-S-F15>",
}
