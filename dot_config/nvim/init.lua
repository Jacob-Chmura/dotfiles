vim.opt.foldenable = false
vim.opt.foldmethod = "manual"
vim.opt.foldlevelstart = 88

vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.signcolumn = "yes"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.inccommand = "split"
vim.opt.showmode = false
vim.opt.timeoutlen = 300

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", ";", ":")
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<up>", "<nop>")
vim.keymap.set("n", "<down>", "<nop>")
vim.keymap.set("i", "<up>", "<nop>")
vim.keymap.set("i", "<down>", "<nop>")
vim.keymap.set("i", "<left>", "<nop>")
vim.keymap.set("i", "<right>", "<nop>")
vim.keymap.set("n", "<left>", ":bp<cr>")
vim.keymap.set("n", "<right>", ":bn<cr>")

vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<leader>y", ":w !xclip -in -selection clipboard<CR><CR>", { noremap = true, silent = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Jump to last edit position on opening file
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
            -- except for in git commit messages
            -- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
            if not vim.fn.expand("%:p"):find(".git", 1, true) then
                vim.cmd('exe "normal! g\'\\""')
            end
        end
    end,
})

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup({
    columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
    },
    watch_for_changes = true,
    keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["l"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        ["h"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
    },
    view_options = { show_hidden = true },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.pack.add({
    { src = "https://github.com/bluz71/vim-moonfly-colors", name = "moonfly" },
})

vim.cmd.colorscheme("moonfly")
local highlights = { "Normal", "NormalNC", "NormalFloat", "FloatBorder", "Pmenu", "SignColumn", "LineNr", "CursorLineNr",
    "EndOfBuffer" }
for _, group in ipairs(highlights) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end

vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
require("nvim-treesitter.install").update("all")
require("nvim-treesitter.config").setup({
    auto_install = true, -- autoinstall languages that are not installed yet
})

vim.pack.add({
    { src = 'https://github.com/vieitesss/miniharp.nvim' }
})
require('miniharp').setup()

local marks = require("miniharp")
local state = require("miniharp.state")
local function jump_to_index(target)
    if #state.marks == 0 then return end
    state.idx = target - 1
    if state.idx < 0 then state.idx = #state.marks end
    marks.next()
end

for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, function()
        jump_to_index(i)
    end, { desc = "Jump to mark " .. i })
end

vim.keymap.set('n', '<leader>m', require('miniharp').toggle_file, { desc = 'miniharp: toggle file mark' })
vim.keymap.set('n', '<C-n>', require('miniharp').next, { desc = 'miniharp: next file mark' })
vim.keymap.set('n', '<C-p>', require('miniharp').prev, { desc = 'miniharp: prev file mark' })
vim.keymap.set('n', '<leader>l', require('miniharp').show_list, { desc = 'miniharp: list marks' })

vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
require('gitsigns').setup()

vim.pack.add({
    { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('1.*') }
})
require("blink.cmp").setup({
    completion = { documentation = { auto_show = true, }, },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
})

-- INFO: lsp server installation and configuration
local lsp_servers = {
    lua_ls = {
        -- https://luals.github.io/wiki/settings/ | `:h nvim_get_runtime_file`
        Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) }, },
    },
    clangd = {},
    rust_analyzer = {},
    pyright = {},
    bashls = {},
}

vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",                    -- default configs for lsps
    "https://github.com/mason-org/mason.nvim",                     -- package manager
    "https://github.com/mason-org/mason-lspconfig.nvim",           -- lspconfig bridge
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" -- auto installer
}, { confirm = false })

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
    ensure_installed = vim.tbl_keys(lsp_servers),
})

for server, config in pairs(lsp_servers) do
    vim.lsp.config(server, {
        settings = config,
        -- only create the keymaps if the server attaches successfully
        on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = bufnr })
            vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = bufnr })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = bufnr })
            vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = bufnr })
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr })
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = bufnr })
            vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
            vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
        end,
    })
end

vim.pack.add({
    {
        src = "https://github.com/mfussenegger/nvim-lint",
        on = { "BufReadPre", "BufNewFile" },
    },
})

local lint = require("lint")
lint.linters_by_ft = {
    bash = { "bash" },
    cpp = { "clangtidy" },
    python = { "ruff" },
    yaml = { "yamllint" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "TextChanged" }, {
    group = lint_augroup,
    callback = function()
        lint.try_lint()
    end,
})

vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
require("mini.pairs").setup()

vim.pack.add({
    {
        src = "https://github.com/ibhagwan/fzf-lua",
        on = { "VeryLazy" }, -- load once UI is ready
    },
})

local fzf = require("fzf-lua")
fzf.setup({
    winopts = {
        split = "belowright 10new",
        preview = { hidden = true },
    },
    files = {
        file_icons = false,
        git_icons = true,
        _fzf_nth_devicons = true,
    },
    buffers = {
        file_icons = false,
        git_icons = true,
    },
    fzf_opts = {
        ["--layout"] = "default",
    },
    grep = {
        rg_opts = "--color=always --smart-case --line-number --column --hidden --glob '!.git/*'",
        fzf_opts = {
            ["--layout"] = "default",
        },
    },
})

vim.keymap.set("", "<C-p>", function()
    local opts = {}
    opts.cmd = "fd --color=never --hidden --type f --type l --exclude .git"
    local current = vim.fn.expand("%")
    local base = vim.fn.fnamemodify(current, ":h:.:S")

    if base ~= "." then
        opts.cmd = opts.cmd
            .. (" | proximity-sort %s"):format(vim.fn.shellescape(current))
    end

    opts.fzf_opts = {
        ["--scheme"] = "path",
        ["--tiebreak"] = "index",
        ["--layout"] = "default",
    }

    fzf.files(opts)
end)

vim.keymap.set("n", "<leader>;", function()
    fzf.buffers({
        fzf_opts = {
            ["--layout"] = "default",
            ["--prompt"] = "Buffers> ",
        },
        all_buffers = true,
        previewer = false,
    })
end)

vim.keymap.set("n", "<leader>sg", function()
    fzf.grep_project({
        prompt = "Rg> ",
    })
end)

vim.keymap.set("n", "<leader>/", function()
    fzf.grep_curbuf({
        fzf_opts = { ["--layout"] = "default" },
    })
end)
