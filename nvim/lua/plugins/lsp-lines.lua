return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()
    -- Disable standard virtual text to avoid duplicates
    vim.diagnostic.config({ virtual_text = false })
  end,
  keys = {
    { "<leader>ul", function() require("lsp_lines").toggle() end, desc = "Toggle LSP Lines" },
  },
}
