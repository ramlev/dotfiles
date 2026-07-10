return {
	-- Treesitter: better syntax highlighting and text objects.
	-- Uses the `main` branch (rewrite) — required for Neovim 0.12; the archived
	-- `master` branch does not support 0.12. Needs the `tree-sitter` CLI on PATH.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- main branch does not support lazy-loading
		build = ":TSUpdate",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
		},
		config = function()
			local ensure_installed = {
				"bash",
				"c",
				"css",
				"diff",
				"html",
				"javascript",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}
			-- Async, no-op for already-installed parsers.
			require("nvim-treesitter").install(ensure_installed)

			-- Highlighting and (experimental) indentation are not automatic on
			-- the main branch — start them per buffer when a parser exists.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
				callback = function(args)
					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- Text objects (main branch API: setup + manual keymaps).
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			local function sel(key, obj)
				vim.keymap.set({ "x", "o" }, key, function()
					select.select_textobject(obj, "textobjects")
				end, { desc = "TS select " .. obj })
			end
			sel("af", "@function.outer")
			sel("if", "@function.inner")
			sel("ac", "@class.outer")
			sel("ic", "@class.inner")
			sel("aa", "@parameter.outer")
			sel("ia", "@parameter.inner")

			local function mv(key, fn, obj)
				vim.keymap.set({ "n", "x", "o" }, key, function()
					fn(obj, "textobjects")
				end, { desc = "TS move " .. obj })
			end
			mv("]f", move.goto_next_start, "@function.outer")
			mv("]c", move.goto_next_start, "@class.outer")
			mv("]F", move.goto_next_end, "@function.outer")
			mv("]C", move.goto_next_end, "@class.outer")
			mv("[f", move.goto_previous_start, "@function.outer")
			mv("[c", move.goto_previous_start, "@class.outer")
			mv("[F", move.goto_previous_end, "@function.outer")
			mv("[C", move.goto_previous_end, "@class.outer")
		end,
	},

	-- Mason: LSP/formatter/linter installer
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ui = { border = "rounded" },
		},
	},

	-- Bridge mason ↔ lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true,
		opts = {},
	},

	-- Auto-install tools via mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
		opts = {
			ensure_installed = {
				-- LSP servers
				"lua_ls",
				"ts_ls",
				"pyright",
				"jsonls",
				"html",
				"cssls",
				"bashls",
				-- Formatters
				"stylua",
				"prettier",
				"black",
				-- Linters
				"eslint_d",
				"shellcheck",
			},
		},
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} }, -- LSP progress indicator
		},
		config = function()
			-- Diagnostic display
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			-- LSP attach: set keybindings only when an LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					local tb = require("telescope.builtin")

					map("gd", tb.lsp_definitions, "Go to definition")
					map("gr", tb.lsp_references, "Go to references")
					map("gI", tb.lsp_implementations, "Go to implementation")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("<leader>D", tb.lsp_type_definitions, "Type definition")
					map("<leader>ds", tb.lsp_document_symbols, "Document symbols")
					map("<leader>ws", tb.lsp_workspace_symbols, "Workspace symbols")
					map("K", vim.lsp.buf.hover, "Hover docs")
					map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")

					-- Highlight references on cursor hold
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method("textDocument/documentHighlight") then
						local hl_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = hl_group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd("CursorMoved", {
							buffer = event.buf,
							group = hl_group,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})

			-- Capabilities (extended by blink.cmp / nvim-cmp if present)
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- Per-server settings
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = { checkThirdParty = false },
							diagnostics = { globals = { "vim" } },
							telemetry = { enable = false },
						},
					},
				},
				pyright = {},
				ts_ls = {},
				jsonls = {},
				html = {},
				cssls = {},
				bashls = {},
			}

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				handlers = {
					function(server_name)
						local config = servers[server_name] or {}
						config.capabilities = capabilities
						require("lspconfig")[server_name].setup(config)
					end,
				},
			})
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				jsx = { "prettier" },
				tsx = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
			},
			format_on_save = { timeout_ms = 500, lsp_fallback = true },
		},
	},
}
