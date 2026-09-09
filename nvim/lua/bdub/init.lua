function R(name)
  require("plenary.reload").reload_module(name)
end

return {
  -- Emitted by the caps+space chord (verified via i_CTRL-V). Bound in
  -- lua/plugins/sidekick.lua (n/x -> Ask Claude) and lua/plugins/copilot.lua (i).
  hyper_space_key = "<C-S-F15>",
}
