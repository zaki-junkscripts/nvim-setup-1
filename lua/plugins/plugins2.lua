return {
  {
    "gutsavgupta/nvim-gemini-companion",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      require("gemini").setup()
    end,
    keys = {
      { "<leader>gg", "<cmd>GeminiToggle<cr>", desc = "Toggle Gemini sidebar" },
      { "<leader>gc", "<cmd>GeminiSwitchToCli<cr>", desc = "Spawn or switch to AI session" },
      { "<leader>gS", "<cmd>GeminiSend<cr>", mode = { "x" }, desc = "Send selection to Gemini" },
    },
  },

  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  {
    "nvim-neorg/neorg",
    lazy = false,
    priority = 1000,
    build = ":Neorg sync-parsers",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim", "itchyny/calendar.vim" },
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.journal"] = {
            config = { strategy = "flat", workspace = "notes" },
          },
          ["core.dirman"] = {
            config = {
              workspaces = { notes = "~/Documents/dailyroutine" },
              default_workspace = "notes",
            },
          },
        },
      })
    end,
  },

  -- Telescope keybinds
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
      local builtin = require("telescope.builtin")
      local wk = require("which-key")

      -- Keymaps
      wk.register({
        ["<leader>f"] = {
          name = "Telescope",
          f = { 
            function() 
              builtin.find_files({ hidden = false }) 
            end, 
            "Find Files" 
          },
          a = { 
            function() 
              builtin.find_files({ 
                no_ignore = true, 
                hidden = true, 
                prompt_title = "Find All (Hidden)",
              }) 
            end, 
            "Find All Files" 
          },
          g = { builtin.live_grep, "Live Grep" },
          b = { builtin.buffers, "Buffers" },
          h = { builtin.help_tags, "Help Tags" },
        },
      })
    end,
  },
} -- <--- This final brace was the missing piece!
