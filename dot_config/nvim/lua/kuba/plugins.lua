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
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
				},
			},
		},
		{ "Bilal2453/luvit-meta", lazy = true },
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
				"williamboman/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				{ "j-hui/fidget.nvim", opts = {} },
				"hrsh7th/cmp-nvim-lsp",
			},
			config = function()
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
					callback = function(event)
						local map = function(keys, func, desc, mode)
							mode = mode or "n"
							vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
						end

						--  To jump back, press <C-t>.
						map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
						map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
						map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
						map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
						map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
						map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

						-- The following two autocommands are used to highlight references of the
						-- word under your cursor when your cursor rests there for a little while.
						-- When you move your cursor, the highlights will be cleared (the second autocommand).
						local client = vim.lsp.get_client_by_id(event.data.client_id)
						if
							client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
						then
							local highlight_augroup =
								vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
							vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.document_highlight,
							})

							vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.clear_references,
							})

							vim.api.nvim_create_autocmd("LspDetach", {
								group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
								callback = function(event2)
									vim.lsp.buf.clear_references()
									vim.api.nvim_clear_autocmds({
										group = "kickstart-lsp-highlight",
										buffer = event2.buf,
									})
								end,
							})
						end
					end,
				})

				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities =
					vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
				require("mason").setup()
				require("mason-tool-installer").setup({
					ensure_installed = { "bashls", "clangd", "ruff", "pyright", "lua_ls", "stylua" },
				})
				require("mason-lspconfig").setup()
				require("lspconfig").bashls.setup({})
				require("lspconfig").clangd.setup({ cmd = { "clangd", "--background-index", "--clang-tidy" } })
				require("lspconfig").pyright.setup({})
				require("lspconfig").lua_ls.setup({ settings = { Lua = { completion = { callSnippet = "Replace" } } } })
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
