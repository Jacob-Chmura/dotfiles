return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"lua",
				"markdown",
				"python",
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		},
	},
	{
		"fei6409/log-highlight.nvim",
		config = function()
			require("log-highlight").setup({})
		end,
	},
}
