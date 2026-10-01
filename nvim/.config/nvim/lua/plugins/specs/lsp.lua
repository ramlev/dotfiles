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
				"php",
				"phpdoc",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"twig",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
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
				"intelephense",
				"twiggy_language_server",
				-- Formatters
				"stylua",
				"prettier",
				"black",
				"php-cs-fixer",
				"phpcbf",
				-- Linters
				"eslint_d",
				"shellcheck",
				"phpstan",
				"phpcs",
				-- Debug adapters
				"php-debug-adapter",
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
			"saghen/blink.cmp",
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
					if client and client:supports_method("textDocument/documentHighlight") then
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

			-- Completion capabilities from blink.cmp, applied to every server
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- Per-server settings. mason-lspconfig v2 enables installed servers
			-- via vim.lsp.enable(), so settings must go through vim.lsp.config().
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
				intelephense = {
					-- Root at the composer project (nearest vendor/autoload.php), not the
					-- nearest .git: custom module dirs are often separate repos, which would
					-- leave core, contrib and vendor unindexed.
					root_dir = function(bufnr, on_dir)
						local fname = vim.api.nvim_buf_get_name(bufnr)
						for dir in vim.fs.parents(fname) do
							if vim.uv.fs_stat(dir .. "/vendor/autoload.php") then
								return on_dir(dir)
							end
						end
						on_dir(vim.fs.root(bufnr, { "composer.json", ".git" }) or vim.fs.dirname(fname))
					end,
					init_options = {
						-- Accepts the key itself or an absolute path to a file holding it
						licenceKey = vim.fn.expand("~/intelephense/licence.txt"),
					},
					settings = {
						intelephense = {
							files = {
								maxSize = 5000000, -- Drupal core has some large files
								associations = {
									"*.php",
									"*.module",
									"*.inc",
									"*.install",
									"*.theme",
									"*.profile",
									"*.engine",
									"*.test",
								},
								exclude = {
									"**/.git/**",
									"**/node_modules/**",
									"**/web/sites/*/files/**",
									"**/docroot/sites/*/files/**",
									"**/var/cache/**",
								},
							},
						},
					},
				},
				twiggy_language_server = {},
				pyright = {},
				ts_ls = {},
				jsonls = {},
				html = {},
				cssls = {},
				bashls = {},
			}

			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
			end

			-- Full re-index, for when the file watcher misses a big composer install/update
			vim.api.nvim_create_user_command("IntelephenseReindex", function()
				for _, client in ipairs(vim.lsp.get_clients({ name = "intelephense" })) do
					local bufs = vim.tbl_keys(client.attached_buffers)
					local config = vim.deepcopy(client.config)
					config.init_options = vim.tbl_extend("force", config.init_options or {}, { clearCache = true })
					client:stop()
					vim.wait(5000, function()
						return client:is_stopped()
					end)
					for _, buf in ipairs(bufs) do
						vim.lsp.start(config, { bufnr = buf })
					end
				end
			end, { desc = "Clear intelephense cache and re-index the workspace" })

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				automatic_enable = true,
			})
		end,
	},

	-- Linting (things the LSP doesn't cover: phpstan, phpcs)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost" },
		config = function()
			local lint = require("lint")

			-- Only run PHP linters when the project is configured for them,
			-- from the project root so autoloading and config files resolve.
			local php_linters = {
				phpstan = { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" },
				phpcs = { "phpcs.xml", "phpcs.xml.dist", ".phpcs.xml", ".phpcs.xml.dist" },
			}

			local group = vim.api.nvim_create_augroup("Lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
				group = group,
				callback = function(args)
					if vim.bo[args.buf].filetype ~= "php" then
						return
					end
					for linter, markers in pairs(php_linters) do
						local root = vim.fs.root(args.buf, markers)
						if root then
							lint.try_lint(linter, { cwd = root })
						end
					end
				end,
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
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format buffer",
			},
		},
		opts = function()
			local util = require("conform.util")
			local phpcs_markers = { "phpcs.xml", "phpcs.xml.dist", ".phpcs.xml", ".phpcs.xml.dist" }
			local cs_fixer_markers = { ".php-cs-fixer.php", ".php-cs-fixer.dist.php" }
			local drupal_markers = { "web/core/lib/Drupal.php", "docroot/core/lib/Drupal.php", "core/lib/Drupal.php" }

			-- vim.fs.root() only matches plain names, so nested paths are checked by hand
			local function is_drupal(bufnr)
				for dir in vim.fs.parents(vim.api.nvim_buf_get_name(bufnr)) do
					for _, marker in ipairs(drupal_markers) do
						if vim.uv.fs_stat(dir .. "/" .. marker) then
							return true
						end
					end
				end
				return false
			end

			-- Pick the PHP formatter the project is configured for. Drupal projects
			-- without a phpcs config are left alone rather than reformatted to PSR-12.
			local function php_formatters(bufnr)
				if vim.fs.root(bufnr, phpcs_markers) then
					return { "phpcbf" }
				end
				if vim.fs.root(bufnr, cs_fixer_markers) then
					return { "php_cs_fixer" }
				end
				if is_drupal(bufnr) then
					return {}
				end
				return { "php_cs_fixer_psr12" }
			end

			return {
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
					php = php_formatters,
				},
				formatters = {
					-- Run from the project root so phpcs.xml is picked up
					phpcbf = { cwd = util.root_file(phpcs_markers) },
					-- Projects without a php-cs-fixer config: plain PSR-12. Explicit
					-- rules also stop php-cs-fixer from generating a config + .gitignore.
					php_cs_fixer_psr12 = vim.tbl_extend("force", require("conform.formatters.php_cs_fixer"), {
						args = { "fix", "--rules=@PSR12", "--using-cache=no", "$FILENAME" },
					}),
				},
				format_on_save = function(bufnr)
					local ft = vim.bo[bufnr].filetype
					if ft == "php" then
						-- php-cs-fixer/phpcbf are slow; never fall back to intelephense formatting
						return { timeout_ms = 3000, lsp_format = "never" }
					end
					return { timeout_ms = 500, lsp_format = "fallback" }
				end,
			}
		end,
	},
}
