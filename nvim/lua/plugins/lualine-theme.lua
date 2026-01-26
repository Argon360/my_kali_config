return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    opts.options.component_separators = '|'
    opts.options.section_separators = { left = '', right = '' }
    
    -- Add nice padding to the mode section
    opts.sections.lualine_a = {
      { "mode", separator = { left = "", right = "" }, right_padding = 2 },
    }
    opts.sections.lualine_z = {
      { "location", separator = { left = "", right = "" }, left_padding = 2 },
    }
  end,
}
