return {
	------------------------ MASON ------------------------
	{
		"williamboman/mason.nvim",
		cmd = "Mason", -- Define a command to open Mason's UI
		opts = {}, -- Empty table for default options, or add custom configurations
	},
	{
		"williamboman/mason-lspconfig.nvim",
		-- Ensure this loads after mason.nvim and before nvim-lspconfig
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright" },
				-- Handlers for setting up LSP servers with nvim-lspconfig
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

			-- Make it clearly visible which argument we're at.
			local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
			vim.api.nvim_set_hl(
				0,
				"LspSignatureActiveParameter",
				{ fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true }
			)
		end,
	},

	------------------------ FUGITIVE ------------------------
	{
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
	},

	------------------------ HARPOON ------------------------
	{
		"theprimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
		end,
		keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
			},
			{
				"<C-e>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
			},
			{
				"<leader>1",
				function()
					require("harpoon"):list():select(1)
				end,
			},
			{
				"<leader>2",
				function()
					require("harpoon"):list():select(2)
				end,
			},
			{
				"<leader>3",
				function()
					require("harpoon"):list():select(3)
				end,
			},
			{
				"<leader>4",
				function()
					require("harpoon"):list():select(4)
				end,
			},
			{
				"<leader>5",
				function()
					require("harpoon"):list():select(5)
				end,
			},
		},
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
				sh = { "/snap/bin/beautysh" },
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
					--cpp = { "clangtidy" },
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
				-- Setup language servers.

				-- Rust
				vim.lsp.config("rust_analyzer", {
					-- Server-specific settings. See `:help lspconfig-setup`
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

				-- Global mappings.
				-- See `:help vim.diagnostic.*` for documentation on any of the below functions
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
						-- See `:help vim.lsp.*` for documentation on any of the below functions
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

						local client = vim.lsp.get_client_by_id(ev.data.client_id)

						-- TODO: find some way to make this only apply to the current line.
						if client.server_capabilities.inlayHintProvider then
							vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
						end

						-- None of this semantics tokens business.
						-- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
						client.server_capabilities.semanticTokensProvider = nil
					end,
				})
			end,
		},

		{
			"saghen/blink.cmp",
			-- optional: provides snippets for the snippet source
			dependencies = { "rafamadriz/friendly-snippets" },

			-- use a release tag to download pre-built binaries
			version = "1.*",

			---@module 'blink.cmp'
			---@type blink.cmp.Config
			opts = {
				-- All presets have the following mappings:
				-- C-space: Open menu or open docs if already open
				-- C-n/C-p or Up/Down: Select next/previous item
				-- C-e: Hide menu
				-- C-k: Toggle signature help (if signature.enabled = true)
				keymap = { preset = "default" },
				appearance = {
					-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
					nerd_font_variant = "mono",
				},

				-- (Default) Only show the documentation popup when manually triggered
				completion = { documentation = { auto_show = false } },

				-- Default list of enabled providers defined so that you can extend it
				-- elsewhere in your config, without redefining it, due to `opts_extend`
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},

				-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
				-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
				-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
				fuzzy = { implementation = "prefer_rust_with_warning" },
			},
			opts_extend = { "sources.default" },
		},
		{
			"ray-x/lsp_signature.nvim",
			event = "VeryLazy",
			opts = {},
			config = function(_, opts)
				-- Get signatures (and _only_ signatures) when in argument lists.
				require("lsp_signature").setup({
					doc_lines = 0,
					handler_opts = {
						border = "none",
					},
				})
			end,
		},

		-- toml / yaml
		"cespare/vim-toml",
		{
			"cuducos/yaml.nvim",
			ft = { "yaml" },
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
		},
		-- markdown
		{
			"plasticboy/vim-markdown",
			ft = { "markdown" },
			dependencies = {
				"godlygeek/tabular",
			},
			config = function()
				-- never ever fold!
				vim.g.vim_markdown_folding_disabled = 1
				-- support front-matter in .md files
				vim.g.vim_markdown_frontmatter = 1
				-- 'o' on a list item should insert at same level
				vim.g.vim_markdown_new_list_item_indent = 0
				-- don't add bullets when wrapping:
				-- https://github.com/preservim/vim-markdown/issues/232
				vim.g.vim_markdown_auto_insert_bullets = 0
			end,
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
				ensure_installed = {
					"bash",
					"cpp",
					"markdown",
					"python",
				},
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
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			dependencies = { "hrsh7th/nvim-cmp" },
			config = function()
				require("nvim-autopairs").setup({})
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				local cmp = require("cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end,
		},
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
			config = function()
				require("todo-comments").setup()
			end,
		},
		{ -- Collection of various small independent plugins/modules
			"echasnovski/mini.nvim",
			config = function()
				-- Better Around/Inside textobjects
				require("mini.ai").setup({ n_lines = 500 })
				require("mini.surround").setup()
			end,
		},
	},
}
