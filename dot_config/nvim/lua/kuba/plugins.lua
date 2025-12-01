return {
	------------------------ COLORS ------------------------
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("moonfly")
		end,
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
			notify_on_error = false,
			format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
			formatters_by_ft = {
				sh = { "beautysh" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				lua = { "stylua" },
				python = { "ruff_format" },
			},
		},
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
				vim.lsp.enable("ruff")

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
						vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
						vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
						vim.keymap.set("n", "<leader>wl", function()
							print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
						end, opts)
						--vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
						vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
						vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)
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

						-- format on save for Rust
						if client.server_capabilities.documentFormattingProvider then
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = vim.api.nvim_create_augroup("RustFormat", { clear = true }),
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({ bufnr = bufnr })
								end,
							})
						end
					end,
				})
			end,
		},

		{ -- Autocompletion
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				{
					"L3MON4D3/LuaSnip",
					build = (function()
						-- Build Step is needed for regex support in snippets.
						if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
							return
						end
						return "make install_jsregexp"
					end)(),
					dependencies = {},
				},
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-path",
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")
				luasnip.config.setup({})

				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					completion = { completeopt = "menu,menuone,noinsert" },
					mapping = cmp.mapping.preset.insert({
						["<C-n>"] = cmp.mapping.select_next_item(),
						["<C-p>"] = cmp.mapping.select_prev_item(),
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-y>"] = cmp.mapping.confirm({ select = true }),
						["<C-Space>"] = cmp.mapping.complete({}),
					}),
					sources = {
						{
							name = "lazydev",
							group_index = 0,
						},
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "path" },
					},
				})
			end,
		},

		{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			-- Get signatures (and _only_ signatures) when in argument lists.
			require "lsp_signature".setup({
				doc_lines = 0,
				handler_opts = {
					border = "none"
				},
			})
		end
	},
	},

	------------------------ TELESCOPE ------------------------
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		keys = {
			{
				"<leader>sf",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "[S]earch [F]iles",
			},
			{
				"<leader>sg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "[S]earch by [G]rep",
			},
			{
				"<leader>sd",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "[S]earch [D]iagnostics",
			},
			{
				"<leader>s.",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = '[S]earch Recent Files ("." for repeat)',
			},
			{
				"<leader><leader>",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "[ ] Find existing buffers",
			},
			{
				"<leader>/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					}))
				end,
				desc = "[/] Fuzzily search in current buffer",
			},
			{
				"<leader>s/",
				function()
					require("telescope.builtin").live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end,
				desc = "[S]earch [/] in Open Files",
			},
		},

		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			"nvim-telescope/telescope-ui-select.nvim",
		},

		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Load extensions safely
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
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
