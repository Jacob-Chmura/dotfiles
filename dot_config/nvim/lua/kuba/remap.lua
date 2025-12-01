vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>bs", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>")
vim.keymap.set("n", "<leader>bp", "<cmd>bprev<CR>")
vim.keymap.set("n", "<leader>bk", "<cmd>bd<CR>")
vim.keymap.set("n", "<leader>bK", "<cmd>bd!<CR>")
vim.keymap.set("n", "<leader>wq", "<cmd>wq<CR>")
vim.keymap.set("n", "<leader>bq", "<cmd>q!<CR>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux new-window tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Netrw remaps
vim.api.nvim_create_autocmd("filetype", {
	pattern = "netrw",
	desc = "Better mappings for netrw",
	callback = function()
		vim.keymap.set("n", "h", "-^", { remap = true, buffer = true })
		vim.keymap.set("n", "l", "<CR>", { remap = true, buffer = true })
		vim.keymap.set("n", "ff", "%:w<CR>:buffer #<CR>", { remap = true, buffer = true })
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- MoonFly Override background
local custom_highlight = vim.api.nvim_create_augroup("CustomHighlight", {})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "moonfly",
	group = custom_highlight,
	callback = function()
		local bg = "#181818"

		vim.api.nvim_set_hl(0, "Normal", { bg = bg })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = bg })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
		vim.api.nvim_set_hl(0, "LineNr", { bg = bg })
		vim.api.nvim_set_hl(0, "FoldColumn", { bg = bg })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = bg })
		vim.api.nvim_set_hl(0, "CursorColumn", { bg = bg })
	end,
})
