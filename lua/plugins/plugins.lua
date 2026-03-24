return {
  -- LSP Config
  { "neovim/nvim-lspconfig" },

  -- Which key
  {
    "folke/which-key.nvim",
    config = function()
      local wk = require("which-key")
      wk.setup {}
      wk.add({
        { "<leader>g", group = "Git" },
        { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit (Status)" },
        { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Commit Changes" },
        { "<leader>gp", "<cmd>Neogit push<CR>", desc = "Push to GitHub" },
        { "<leader>gl", "<cmd>Neogit pull<CR>", desc = "Pull from GitHub" },
        { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Blame" },
        { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "View Diff (Side-by-Side)" },
      })
    end
  },

  -- edgy.nvim
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    opts = {
      animate = { enabled = false },
      exit_when_last = true,
      -- Exclude all calendar buffers from edgy layouts
      filter = function(bufnr, winid)
        local ft = vim.bo[bufnr].filetype
        return ft ~= "calendar"
      end,
      left = {
        { title = "Nvim Tree", ft = "NvimTree", size = { 30, min = 10, max = 50 } },
      },
      bottom = {
        { title = "Iron REPL", ft = "iron", size = 12 },
      },
    },
  },

  -- bufferline.nvim
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          offsets = {
            { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", separator = true },
          },
        },
      })

      -- Hide bufferline in calendar buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "calendar",
        callback = function()
          vim.opt.showtabline = 0
        end,
      })

      -- Restore bufferline when no calendar buffers remain
      vim.api.nvim_create_autocmd({ "BufWinLeave", "BufDelete" }, {
        pattern = "*",
        callback = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "calendar" then
              return
            end
          end
          vim.opt.showtabline = 2
        end,
      })
    end,
  },

  -- Hardtime.nvim
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      -- Disable Hardtime for calendar buffers
      disabled_filetypes = { "calendar" },
    },
  },
  --

  -- -- Autopairs
  -- {
  --   "windwp/nvim-autopairs",
  --   config = function()
  --     local npairs = require("nvim-autopairs")
  --     npairs.setup({
  --       check_ts = true,
  --       fast_wrap = {},
  --     })
  --
  --     local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  --     local cmp = require("cmp")
  --     cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  --   end
  -- },
  --
  -- File explorer


  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {
        view = {
          centralize_selection = true,
        },
        filters = {
          dotfiles = true,
          custom = { "^%.env$", "^%.config$"},
        },
      }
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },

  -- -- Edgy.nvim
  -- {
  --   "folke/edgy.nvim",
  --   event = "VeryLazy",
  --   init = function()
  --     vim.opt.laststatus = 3
  --     vim.opt.splitkeep = "screen"
  --   end,
  --   opts = {
  --     animate = { enabled = false },
  --     exit_when_last = true,
  --     left = {
  --       { title = "Nvim Tree", ft = "NvimTree", size = { 30, min = 10, max = 50 } },
  --     },
  --     bottom = {
  --       { title = "Iron REPL", ft = "iron", size = 12 },
  --     },
  --   },
  -- },
  --
  -- Jupytext.nvim
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, 
    config = function()
      require("jupytext").setup({
        style = "hydrogen",        
        output_extension = "auto", 
        force_ft = nil,            
      })
    end,
  },

  -- LSP installer
  { "williamboman/mason.nvim", opts = {} },
  { "williamboman/mason-lspconfig.nvim", opts = {} },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "Exafunction/codeium.nvim", -- Added dependency
    },
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
          :sub(col, col)
          :match("%s") == nil
      end

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end
        },
        completion = { autocomplete = false },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "codeium" }, -- Added codeium source
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "obsidian" }, -- Added obsidian source
        }
      })
    end
  },

  -- Snippets
  { "L3MON4D3/LuaSnip", opts = {} },
  { "saadparwaiz1/cmp_luasnip" },

  -- Diagnostics UI
  { "folke/trouble.nvim", opts = {} },

  -- iron.nvim REPL
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")
      local common = require("iron.fts.common")

      iron.setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = { command = { "zsh" } },
            python = {
              command = { "python3" },
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
              env = { PYTHON_BASIC_REPL = "1" },
            },
          },
          repl_filetype = function(bufnr, ft)
            if ft ~= "python" then
              return nil
            end
            return ft
          end,
          dap_integration = true,
          repl_open_cmd = "vertical botright 60 split",
          ignore_blank_lines = true,
        },
        keymaps = {
          toggle_repl = "<space>rr",
          restart_repl = "<space>rR",
          send_motion = "<space>sc",
          visual_send = "<space>sc",
          send_file = "<space>sf",
          send_line = "<space>sl",
          send_paragraph = "<space>sp",
          send_until_cursor = "<space>su",
          send_mark = "<space>sm",
          send_code_block = "<space>sb",
          send_code_block_and_move = "<space>sn",
          mark_motion = "<space>mc",
          mark_visual = "<space>mc",
          remove_mark = "<space>md",
          cr = "<space>s<cr>",
          interrupt = "<space>s<space>",
          exit = "<space>sq",
          clear = "<space>cl",
        },
        highlight = { italic = true },
      }
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
        auto_install = false,
        highlight = { enable = true,
                      disable = { "calendar", "vim"},
                      additional_vim_regex_highlighting = false },
      })
    end
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      local green = "#008000"
      local red = "#BA221F"
      local light_red = "#FF6347"
      local purple = "#AA23FF"
      local gold = "#DEB343"
      local white = "#FFFFFF"
      local dark_bg = "#2B2A2A"
      local light_green = "#B0CF93"
      local blue = "#087AD4"
      local bright_red = "#FF0000"

      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = { mocha = { base = dark_bg, mantle = dark_bg, crust = dark_bg } },
        custom_highlights = {
          Normal = { fg = white, bg = dark_bg },
          Comment = { fg = "#5C787E", italic = true },
          Identifier = { fg = white },
          Keyword = { fg = green, bold = true },
          Conditional = { fg = green, bold = true },
          Repeat = { fg = green, bold = true },
          Statement = { fg = green, bold = true },
          Include = { fg = green, bold = true },
          Operator = { fg = purple, bold = true },
          Function = { fg = blue, bold = true },
          pythonBuiltin = { fg = green, bold = true },
          Type = { fg = gold, bold = true },
          Constant = { fg = gold },
          Number = { fg = gold, bold = true },
          Boolean = { fg = green, bold = true },
          String = { fg = light_red },
          Delimiter = { fg = purple },
          Special = { fg = light_red, bold = true },
          Headline = { bg = "#4a1010", fg = bright_red, bold = true },
        },
        highlight_overrides = {
          mocha = function(cp)
            return {
              ["@keyword"] = { fg = green, bold = true },
              ["@keyword.python"] = { fg = green, bold = true },
              ["@keyword.function.python"] = { fg = green, bold = true },
              ["@keyword.conditional.python"] = { fg = green, bold = true },
              ["@keyword.repeat.python"] = { fg = green, bold = true },
              ["@keyword.control.import.python"] = { fg = green, bold = true },
              ["@keyword.control.flow.python"] = { fg = green, bold = true },
              ["@keyword.control.repeat.python"] = { fg = green, bold = true },
              ["@keyword.control.conditional.python"] = { fg = green, bold = true },
              ["@keyword.control.return.python"] = { fg = green, bold = true },
              ["@keyword.operator.python"] = { fg = purple, bold = true },
              ["@conditional"] = { fg = green, bold = true },
              ["@repeat"] = { fg = green, bold = true },
              ["@include"] = { fg = green, bold = true },
              ["@exception"] = { fg = green, bold = true },
              ["@function"] = { fg = red, bold = true },
              ["@function.call"] = { fg = green, bold = true },
              ["@method"] = { fg = blue, bold = true },
              ["@method.call"] = { fg = blue, bold = true },
              ["@function.builtin"] = { fg = green, bold = true },
              ["@variable.builtin"] = { fg = green, bold = true },
              ["@type"] = { fg = gold, bold = true },
              ["@constant"] = { fg = gold },
              ["@number"] = { fg = light_green },
              ["@boolean"] = { fg = green, bold = true },
              ["@string"] = { fg = light_red },
              ["@string.documentation"] = { fg = light_red },
              ["@operator"] = { fg = purple },
              ["@punctuation.delimiter"] = { fg = white },
              ["@punctuation.bracket"] = { fg = white },
              ["@special"] = { fg = light_red },
            }
          end,
        },
      })
      vim.cmd.colorscheme("catppuccin")
      
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
        pattern = "python",
        callback = function()
          vim.fn.matchadd("Headline", "^# %%.*")
        end,
      })
    end,
  },

  -- -- Bufferline
  -- {
  --   "akinsho/bufferline.nvim",
  --   version = "*",
  --   dependencies = "nvim-tree/nvim-web-devicons",
  --   config = function()
  --     require("bufferline").setup({
  --       options = {
  --         mode = "buffers",
  --         diagnostics = "nvim_lsp",
  --         separator_style = "slant",
  --         offsets = { { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", separator = true } },
  --       },
  --     })
  --   end,
  -- },
  --
  {
   'hat0uma/csvview.nvim',
   config = function()
     require('csvview').setup()
   end
  }, 

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
      })
    end,
  },

  -- Obsidian.nvim
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false, -- Changed to false to avoid "Not Loaded" issues
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("obsidian").setup({
        workspaces = {
          {
            name = "personal",
            path = vim.fn.expand("~/Documents/ObsidianVault"), -- Updated path
          },
        },
        completion = {
          nvim_cmp = true,
          min_chars = 2,
        },
        detect_cwd = false,
        note_id_func = function(title)
          if title ~= nil then
            return title:gsub(" ", "-"):gsub("[^%w%-]", ""):lower()
          end
          return tostring(os.time())
        end,
      })

      local wk = require("which-key")
      wk.add({
        { "<leader>o", group = "Obsidian" },
        { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "New Note" },
        { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Search Notes (Grep)" },
        { "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", desc = "Find Note (Files)" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Show Backlinks" },
        { "<leader>ot", "<cmd>ObsidianTags<CR>", desc = "Search Tags" },
        { "<leader>ol", "<cmd>ObsidianFollowLink<CR>", desc = "Follow Link" },
        { "<leader>op", "<cmd>ObsidianPasteImg<CR>", desc = "Paste Image from Clipboard" },
        { "<leader>oo", "<cmd>ObsidianOpen<CR>", desc = "Open in Obsidian App" },
      })
    end,
  },

  -- Codeium AI Assistant
  {
    "Exafunction/codeium.nvim",
    event = "BufEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<C-g>", 
            next = "<M-]>",   
            prev = "<M-[>",   
          },
        },
      })
    end,
  },
}
