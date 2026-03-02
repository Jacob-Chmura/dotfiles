return {
	------------------------ MASON ------------------------
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		-- Ensure this loads after mason.nvim and before nvim-lspconfig
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "bashls", "rust_analyzer", "clangd" },
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
				},
			})
		end,
	},
	------------------------ COLORS ------------------------
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("moonfly")

			local bg = "#181818"
			local groups = { "Normal", "NormalNC", "SignColumn", "LineNr", "FoldColumn", "CursorLine", "CursorColumn" }
			for _, group in ipairs(groups) do
				vim.api.nvim_set_hl(0, group, { bg = bg })
			end

			local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
			vim.api.nvim_set_hl(
				0,
				"LspSignatureActiveParameter",
				{ fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true }
			)
		end,
	},

	------------------------ HARPOON ------------------------
	{
		"theprimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = function()
			local keys = {
				{
					"<leader>a",
					function()
						require("harpoon"):list():add()
					end,
				},
				{
					"<C-e>",
					function()
						local h = require("harpoon")
						h.ui:toggle_quick_menu(h:list())
					end,
				},
			}
			for i = 1, 5 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						require("harpoon"):list():select(i)
					end,
				})
			end
			return keys
		end,
		config = true,
	},

	------------------------ FORMAT ------------------------
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
			},
		},
		opts = {
			notify_on_error = true,
			format_on_save = { timeout_ms = 300, lsp_format = "fallback" },
			formatters_by_ft = {
				sh = { "/usr/bin/beautysh" },
				c = { "/usr/bin/clang-format" },
				cpp = { "/usr/bin/clang-format" },
				lua = { "stylua" },
				python = { "ruff", "ruff_fix" },
			},
		},
	},

	------------------------ LINTING ------------------------
	{
		{
			"mfussenegger/nvim-lint",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				local lint = require("lint")
				lint.linters_by_ft = {
					bash = { "bash" },
					cpp = { "clangtidy" },
					python = { "ruff" },
					yaml = { "yamllint" },
				}

				local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
				vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
					group = lint_augroup,
					callback = function()
						lint.try_lint()
					end,
				})
			end,
		},
	},

	------------------------ LSP ------------------------
	{
		{
			"neovim/nvim-lspconfig",
			config = function()
				-- Rust
				vim.lsp.config("rust_analyzer", {
					settings = {
						["rust-analyzer"] = {
							cargo = {
								features = "all",
							},
							checkOnSave = {
								enable = true,
							},
							check = {
								command = "clippy",
							},
							imports = {
								group = {
									enable = false,
								},
							},
							completion = {
								postfix = {
									enable = false,
								},
							},
						},
					},
				})
				vim.lsp.enable("rust_analyzer")
				vim.lsp.enable("bashls")
				vim.lsp.enable("pyright")
				vim.lsp.config("clangd", {
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--header-insertion=never",
						"--query-driver=/usr/bin/c++",
						"--compile-commands-dir=build",
					},
				})
				vim.lsp.enable("clangd")

				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
				vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

				-- Use LspAttach autocommand to only map the following keys
				-- after the language server attaches to the current buffer
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("UserLspConfig", {}),
					callback = function(ev)
						-- Enable completion triggered by <c-x><c-o>
						vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

						-- Buffer local mappings.
						local opts = { buffer = ev.buf }
						vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
						vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
						vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
						vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
						vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
						vim.keymap.set({ "n", "v" }, "<leader>b", vim.lsp.buf.code_action, opts)
						vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
						vim.keymap.set("n", "<leader>f", function()
							vim.lsp.buf.format({ async = true })
						end, opts)
					end,
				})
			end,
		},

		{
			"saghen/blink.cmp",
			dependencies = { "rafamadriz/friendly-snippets" },
			version = "1.*",
			opts = {
				-- C-space: Open menu or open docs if already open
				-- C-n/C-p or Up/Down: Select next/previous item
				-- C-e: Hide menu
				-- C-k: Toggle signature help (if signature.enabled = true)
				keymap = { preset = "default" },
				appearance = {
					nerd_font_variant = "mono",
				},
				signature = { enabled = true },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" },
		},
	},

	------------------------ FZF_LUA ------------------------
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("fzf-lua").setup({
				winopts = {
					split = "belowright 10new",
					preview = { hidden = true },
				},
				files = {
					file_icons = false, -- file icons are distracting
					git_icons = true, -- git icons are nice
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
					rg_opts = "--color=always --smart-case --line-number --hidden --glob '!.git/*'",
					fzf_opts = {
						["--layout"] = "default",
					},
				},
			})

			-- Quick file open with C-p and proximity-sort
			vim.keymap.set("", "<C-p>", function()
				local opts = {}
				opts.cmd = "fd --color=never --hidden --type f --type l --exclude .git"
				local base = vim.fn.fnamemodify(vim.fn.expand("%"), ":h:.:S")
				if base ~= "." then
					opts.cmd = opts.cmd .. (" | proximity-sort %s"):format(vim.fn.shellescape(vim.fn.expand("%")))
				end
				opts.fzf_opts = {
					["--scheme"] = "path",
					["--tiebreak"] = "index",
					["--layout"] = "default",
				}
				require("fzf-lua").files(opts)
			end)

			-- Buffer search
			vim.keymap.set("n", "<leader>;", function()
				require("fzf-lua").buffers({
					-- just show the buffer names
					fzf_opts = {
						["--layout"] = "default",
						["--prompt"] = "Buffers> ",
					},
					-- show all buffers, even hidden
					all_buffers = true,
					-- preview can be turned off if distracting
					previewer = false,
				})
			end)

			-- Live grep / content search with rg
			vim.keymap.set("n", "<leader>sg", function()
				require("fzf-lua").grep_project({
					prompt = "Rg> ",
				})
			end)

			-- Search in current buffer
			vim.keymap.set("n", "<leader>/", function()
				require("fzf-lua").grep_curbuf({
					fzf_opts = { ["--layout"] = "default" },
				})
			end)
		end,
	},

	------------------------ TREESITTER ------------------------
	{
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			main = "nvim-treesitter.configs",
			opts = {
				ensure_installed = { "bash", "cpp", "markdown", "python", "toml", "yaml", "json", "lua" },
				auto_install = false,
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
	},

	------------------------ MISC ------------------------
	{
		"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
		{
			"notjedi/nvim-rooter.lua",
			config = function()
				require("nvim-rooter").setup()
			end,
		},
		{
			"folke/todo-comments.nvim",
			event = "VeryLazy",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = { signs = false },
		},
		{
			"echasnovski/mini.nvim",
			config = function()
				require("mini.ai").setup({ n_lines = 500 })
				require("mini.surround").setup()
				require("mini.pairs").setup()
			end,
		},
	},
}
