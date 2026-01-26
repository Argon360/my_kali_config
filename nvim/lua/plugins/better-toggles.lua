return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Enable beautiful animations
    animate = { enabled = true },
    -- Better notifications
    notifier = { enabled = true },
    -- Beautiful floating terminal
    terminal = { 
      win = { style = "terminal" }
    },
  },
  keys = {
    -- Top Pick: Toggle Floating Terminal with Ctrl+/
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    
    -- Toggle "Zen" (Zoom) Mode for the current window
    { "<leader>z", function() Snacks.toggle.zoom():toggle() end, desc = "Toggle Zoom" },
    
    -- Quick Git Browse
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    
    -- Toggle Inlay Hints (Productivity boost for reading code)
    { "<leader>uh", function() Snacks.toggle.inlay_hints():toggle() end, desc = "Toggle Inlay Hints" },
    
    -- Toggle Dimming of inactive code
    { "<leader>uD", function() Snacks.toggle.dim():toggle() end, desc = "Toggle Dimming" },
  },
}
