-- =========================
-- LSP + Autocomplete Setup (classic, compatible with older Neovim)
-- =========================

local lspconfig = require("lspconfig")
local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
    return
end
local luasnip = require("luasnip")

-- nvim-cmp setup
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_next_item(),
        ["<C-n>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }),
})

-- LSP keymaps
local on_attach = function(client, bufnr)
    local bufmap = function(mode, lhs, rhs)
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
    end

    bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    bufmap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
    bufmap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
end

-- Pyright setup (classic)
lspconfig.pyright.setup({
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = on_attach,
})

