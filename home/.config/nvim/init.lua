-- ==============================================================================
-- Requirements & Dependencies
-- ==============================================================================
-- Editor:       Neovim >= 0.12
-- Nix/Binaries: ripgrep, fd, proximity-sort, xclip
-- LSP Server Binaries (installed via Nix/PATH):
--   - clang-tools (C/C++ - clangd)
--   - rust-analyzer (Rust)
--   - pyright / ruff (Python)
--   - bash-language-server (Bash)

-- ==============================================================================
-- Leader Key & Basics
-- ==============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==============================================================================
-- Options & Editor Behavior
-- ==============================================================================

-- Persistence & Clipboard
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

-- Visual Defaults
vim.opt.cursorline = true
vim.opt.foldenable = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

-- Line Numbers & Searching
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Search & Key Responsiveness
vim.opt.inccommand = "split"
vim.opt.timeoutlen = 300

-- ==============================================================================
-- Keymaps (Core Editing)
-- ==============================================================================

vim.keymap.set("n", ";", ":")

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search/Replace word" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<left>", "<cmd>bp<CR>")
vim.keymap.set("n", "<right>", "<cmd>bn<CR>")

vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("i", "<up>", "<nop>")
vim.keymap.set("i", "<down>", "<nop>")
vim.keymap.set("i", "<left>", "<nop>")
vim.keymap.set("i", "<right>", "<nop>")
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- ==============================================================================
-- Aesthetics & Autocommands
-- ==============================================================================

vim.cmd.colorscheme("catppuccin")

local function enforce_transparency()
  local hl_groups = { "Normal", "NormalFloat", "SignColumn", "NormalNC" }
  for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

enforce_transparency()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = enforce_transparency,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      if not vim.fn.expand("%:p"):find(".git", 1, true) then
        vim.cmd('exe "normal! g\'\\\""')
      end
    end
  end,
})

-- -- ==============================================================================
-- Plugin Management & Packages (`vim.pack`)
-- ==============================================================================

-- File Explorer (Oil)
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup({
  columns = { "icon", "permissions", "size", "mtime" },
  watch_for_changes = true,
  keymaps = {
    ["l"] = "actions.select",
    ["h"] = { "actions.parent", mode = "n" },
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-p>"] = false,
    ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-r>"] = "actions.refresh",
  },
  view_options = { show_hidden = true },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })

-- Treesitter
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Git Signs
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
require("gitsigns").setup()

-- Text-object & Surround Helpers (mini.nvim)
vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
require("mini.pairs").setup()

-- Fuzzy Finder (fzf-lua)
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
local fzf = require("fzf-lua")
fzf.setup({
  winopts = {
    split = "belowright 10new",
    preview = { hidden = true },
  },
  files = { file_icons = false, git_icons = true },
  buffers = { file_icons = false, git_icons = true },
  grep = {
    rg_opts = "--color=always --smart-case --line-number --column --hidden --glob '!.git/*'",
  },
})

vim.keymap.set("", "<C-p>", function()
  local opts = {
    cmd = "fd --color=never --hidden --type f --type l --exclude .git",
  }
  local current = vim.fn.expand("%")
  local base = vim.fn.fnamemodify(current, ":h:.:S")

  if base ~= "." then
    opts.cmd = opts.cmd .. (" | proximity-sort %s"):format(vim.fn.shellescape(current))
  end

  opts.fzf_opts = {
    ["--scheme"] = "path",
    ["--tiebreak"] = "index",
  }

  fzf.files(opts)
end, { desc = "Fuzzy find files" })

vim.keymap.set("n", "<leader>sg", function()
  fzf.grep_project({ prompt = "Rg> " })
end, { desc = "Grep project" })

vim.keymap.set("n", "<leader>/", function()
  fzf.grep_curbuf({ prompt = "Rg> " })
end, { desc = "Grep current buffer" })

-- Completion (blink.cmp)
vim.pack.add({
  {
    src = "https://github.com/Saghen/blink.cmp",
    version = vim.version.range("1.*"),
  },
})
require("blink.cmp").setup({
  completion = {
    documentation = { auto_show = true },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- Harpoon alternative (miniharp)
vim.pack.add({ "https://github.com/vieitesss/miniharp.nvim" })
require("miniharp").setup()

local marks = require("miniharp")
local state = require("miniharp.state")
local function jump_to_index(target)
  if #state.marks == 0 then return end
  state.idx = target - 1
  if state.idx < 0 then state.idx = #state.marks end
  marks.next()
end

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function() jump_to_index(i) end, { desc = "Jump to mark " .. i })
end

vim.keymap.set("n", "<leader>m", require("miniharp").toggle_file, { desc = "miniharp: toggle file mark" })
vim.keymap.set("n", "<C-n>", require("miniharp").next, { desc = "miniharp: next file mark" })
vim.keymap.set("n", "<C-m>", require("miniharp").prev, { desc = "miniharp: prev file mark" })
vim.keymap.set("n", "<leader>l", require("miniharp").show_list, { desc = "miniharp: list marks" })

-- ==============================================================================
-- Language Server Protocol (Native Neovim Setup)
-- ==============================================================================

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Global LSP keymaps attached dynamically per buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "LSP Definition" })
    vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "LSP Implementation" })
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = bufnr, desc = "LSP References" })
    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = bufnr, desc = "Format Buffer" })
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename Symbol" })
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = bufnr, desc = "Diagnostic Float" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { buffer = bufnr, desc = "Prev Diagnostic" })
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { buffer = bufnr, desc = "Next Diagnostic" })
  end,
})

-- Declared language servers (binaries provided via Nix or PATH)
local servers = {
  clangd = {},
  rust_analyzer = {},
  pyright = {},
  bashls = {},
}

-- Apply settings and enable native server configurations
for server, config in pairs(servers) do
  if next(config) ~= nil then
    vim.lsp.config(server, config)
  end
  vim.lsp.enable(server)
end
