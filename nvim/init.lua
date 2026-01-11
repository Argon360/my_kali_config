-- ============================================================================
-- Neovim Configuration Entry Point
-- ============================================================================
-- This file is the starting point for Neovim's configuration.
-- It bootstraps the 'lazy.nvim' package manager and loads the rest of the
-- configuration from the 'lua/config/' directory.

-- Bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
