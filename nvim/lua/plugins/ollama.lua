return {
  "David-Kunz/gen.nvim",
  opts = {
    model = "dolphin-mistral:latest", -- Using your preferred uncensored model
    display_mode = "split",           -- Results appear in a split window
    show_prompt = true,               -- Let you see the prompt before sending
    show_model = true,                -- Display which model is responding
    no_auto_close = true,             -- Keep the window open after generation
  },
}
