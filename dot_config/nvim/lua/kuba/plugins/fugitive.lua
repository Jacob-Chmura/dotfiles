return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

		local Kuba_Fugitive = vim.api.nvim_create_augroup("Kuba_Fugitive", {})
		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = Kuba_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local opts = { buffer = bufnr, remap = false }
				vim.keymap.set("n", "<leader>p", function()
					vim.cmd.Git("push")
				end, opts)

				vim.keymap.set("n", "<leader>P", ":Git pull --rebase <CR>", opts)
				vim.keymap.set("n", "<leader>l", ":Git lg<CR>", opts)
				vim.keymap.set("n", "<leader>tr", ":Git tr<CR>", opts)
				vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
			end,
		})
	end,
}
