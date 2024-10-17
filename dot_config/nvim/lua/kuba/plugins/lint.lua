return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				bash = { "bash" },
				c = { "clangtidy" },
				cpp = { "clang-tidy" },
				fish = { "fish" },
				--java = { "checkstyle" },
				json = { "jsonlint" },
				markdown = { "markdownlint" },
				python = { "Ruff" },
				yaml = { "yamllint" },
			}

			-- Create autocommand which carries out the actual linting
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
