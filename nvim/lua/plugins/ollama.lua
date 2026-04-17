return {
  "David-Kunz/gen.nvim",
  opts = {
    model = "llama3:8b-instruct-q4_K_M", -- Using your preferred llama3 model
    display_mode = "split",           -- Results appear in a split window
    show_prompt = true,               -- Let you see the prompt before sending
    show_model = true,                -- Display which model is responding
    no_auto_close = true,             -- Keep the window open after generation
  },
}
