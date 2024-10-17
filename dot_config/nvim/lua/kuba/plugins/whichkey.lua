return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		icons = {
			mappings = vim.g.have_nerd_font,
			keys = vim.g.have_nerd_font and {},
		},
	},
}
