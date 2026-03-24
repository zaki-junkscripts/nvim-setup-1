
-- Define/override Pyright config

vim.lsp.config('pyright', {

    cmd = { 'pyright-langserver', '--stdio' },

    filetypes = { 'python' },

    root_dir = vim.fs.dirname(vim.fs.find({'pyproject.toml','setup.py','setup.cfg','requirements.txt','.git'}, { upward = true })[1]),

    settings = {},

})




vim.lsp.enable('pyright')




require("config.lazy")

require("lsp")

require("options")

--require("keychanges")



-- This is made by Zaki to make personal key changes for Neovim


vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })


vim.opt.scrolloff = 8



-- Cycle buffers only (one-directional)

vim.keymap.set("n", "<C-Tab>", ":bnext<CR>", { silent = true })       -- Tab → next buffer


-- Function to open/create any file in a new tab

function OpenFileTab()

  local filename = vim.fn.input("Filename: ", "", "file")

  if filename == "" then return end

  vim.cmd("e " .. filename)

end


-- Ctrl+t → prompt for filename and open/create it in a new tab

vim.keymap.set("n", "<C-t>", OpenFileTab, { silent = true })


-- Alt+number → jump to specific tab (1–9)

for i = 1, 9 do

  vim.keymap.set("n", "<A-" .. i .. ">", i .. "gt", { silent = true })

end







-- Ctrl+w c → close current buffer

vim.keymap.set("n", "<C-q>", ":bd<CR>", { silent = true })


-- Jump to NEXT cell

vim.keymap.set("n", "]c", "/# %%<CR>:noh<CR>jzz", { desc = "Next Code Cell", silent = true })


-- Jump to PREVIOUS cell

vim.keymap.set("n", "[c", "k?# %%<CR>:noh<CR>jzz", { desc = "Prev Code Cell", silent = true })



vim.keymap.set("n", "<leader>cc", "o# %%<CR><Esc>", { desc = "New cell below" })

vim.keymap.set("n", "<leader>cs", "O# %%<CR><Esc>", { desc = "New cell above" })

-- Delete current cell (from the # %% above the cursor to the next # %%)

vim.keymap.set("n", "<leader>cx", [[:?^# %%?+0,/^# %%/--1 d<CR>]], { silent = true, desc = "Delete current cell" })



-- Normal Mode: Run current cell

vim.keymap.set("n", "<S-CR>", function()

  require("iron.core").send_code_block()

end, { desc = "Run code block (Shift+Enter)" }) 


-- Force the Caps/Esc swap whenever Neovim starts
if vim.fn.executable("setxkbmap") == 1 then
    vim.fn.system("setxkbmap -option caps:escape")
end

_G.open_neorg_journal = function()
    -- Pull the numbers directly from Vimscript to avoid userdata errors
    local day   = vim.fn.eval("b:calendar.day().get_day()")
    local month = vim.fn.eval("b:calendar.day().get_month()")
    local year  = vim.fn.eval("b:calendar.day().get_year()")
    
    -- Format: YYYY-MM-DD
    local date_str = string.format("%04d-%02d-%02d", year, month, day)
    
    -- Open Neorg
    vim.cmd("Neorg journal custom " .. date_str)
end

-- Re-bind the key in the calendar buffer
vim.api.nvim_create_autocmd("FileType", {
    pattern = "calendar",
    callback = function()
        vim.keymap.set("n", "<CR>", "<cmd>lua _G.open_neorg_journal()<CR>", { 
            buffer = true, 
            silent = true 
        })
    end,
})
