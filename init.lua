vim.cmd("language en_US")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.scrolloff = 6

vim.opt.breakindent = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.undofile = true
vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", lazyrepo, lazypath })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
	spec = {
		{
			"rebelot/kanagawa.nvim",
			config = function()
				require("kanagawa").setup()
				vim.cmd("colorscheme kanagawa")
			end
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				delay = 0,
				spec = {
					{ "<leader>f", group = "[F]ind" },
				},
			}
		},
		{
			"mrjones2014/smart-splits.nvim",
			config = function()
				local smart_splits = require("smart-splits")
				smart_splits.setup()

				vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left)
				vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right)
				vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up)
				vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down)

				vim.keymap.set("n", "<C-M-h>", smart_splits.resize_left)
				vim.keymap.set("n", "<C-M-l>", smart_splits.resize_right)
				vim.keymap.set("n", "<C-M-k>", smart_splits.resize_up)
				vim.keymap.set("n", "<C-M-j>", smart_splits.resize_down)
			end
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			main = "nvim-treesitter.configs",
			opts = {
				ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "odin" },
				highlight = { enable = true },
				indent = { enable = true },
			}
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
			config = function()
				local context = require("treesitter-context")
				context.setup()
				vim.keymap.set("n", "[c", function() context.go_to_context(vim.v.count1) end, { desc = "Jump to [c]ontext" })
			end,
		},
		{
			"saghen/blink.cmp",
			version = "*", -- release tags with pre-built fuzzy-matching binaries
			opts = {
				signature = { enabled = true },
			},
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"saghen/blink.cmp",
				"nvim-telescope/telescope.nvim",
			},
			opts = {
				servers = {
					ols = {
						cmd = { "c:/Code/ols/ols.exe" },
						init_options = {
							enable_references = true
						}
					}
				},
			},
			config = function(_, opts)
				local lspconfig = require("lspconfig")
				local blinkcmp = require("blink.cmp")
				for server, config in pairs(opts.servers) do
					config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
					lspconfig[server].setup(config)
				end

				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("on-lsp-attach", { clear = true }),
					callback = function(event)
						function map(keys, func, desc, mode)
							mode = mode or "n"
							vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
						end

						local telescope = require("telescope.builtin")
						map("gd", telescope.lsp_definitions, "[G]o to [d]efinition")
						map("gr", telescope.lsp_references, "[G]o to [r]eferences")
						map("<leader>r", vim.lsp.buf.rename, "[R]ename")
					end
				})
			end
		},
		{
			"nvim-telescope/telescope.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" },
				"nvim-telescope/telescope-ui-select.nvim",
			},
			config = function()
				local telescope = require("telescope")
				local builtin = require("telescope.builtin")
				local themes = require("telescope.themes")
				telescope.setup({
					extensions = {
						["ui-select"] = {
							themes.get_dropdown()
						}
					}
				})
				telescope.load_extension("fzf")
				telescope.load_extension("ui-select")

				vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [f]iles" })
				vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [b]uffers" })
				vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [g]rep" })
			end
		},
		{
			"echasnovski/mini.nvim",
			config = function()
				require("mini.icons").setup()
				require("mini.ai").setup({ n_lines = 500 })
				require("mini.surround").setup({ n_lines = 500 })
				require("mini.move").setup()
				require("mini.pairs").setup()

				local indentscope = require("mini.indentscope")
				indentscope.setup({
					draw = {
						delay = 0,
						animation = indentscope.gen_animation.none()
					},
				})

				local notify = require("mini.notify")
				notify.setup()
				vim.notify = notify.make_notify()

				require("mini.statusline").setup()
				vim.opt.showmode = false

				local trailspace = require("mini.trailspace")
				trailspace.setup()
				vim.keymap.set("n", "<leader>t", trailspace.trim, { desc = "[T]rim trailing whitespace" })
			end
		},
		{
			"folke/flash.nvim",
			event = "VeryLazy",
			opts = {},
		},
		"tpope/vim-sleuth",
		{
			'stevearc/oil.nvim',
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			lazy = false,
			config = function()
				local oil = require("oil")
				local util = require("oil.util")
				local actions = require("oil.actions")

				oil.setup()

				vim.keymap.set("n", "-", function()
					oil.open_float()
					util.run_after_load(0, function() oil.open_preview() end)
				end, { desc = "Open parent directory" })

				vim.api.nvim_create_autocmd("User", {
					group = vim.api.nvim_create_augroup("OilFloatCustom", {}),
					pattern = "OilEnter",
					callback = function()
						if util.is_floating_win() then
							vim.keymap.set("n", "<Esc>", actions.close.callback, { buffer = true })
							vim.keymap.set("n", "q", actions.close.callback, { buffer = true })
						end
					end,
				})

			end
		},
		{
			"rmagatti/auto-session",
			lazy = false,
			keys = {
				{ "<leader>fs", "<cmd>SessionSearch<CR>", desc = "[F]ind [s]ession" },
			},
			opts = {
				suppressed_dirs = { "c:/Code/", "c:/" },
			}
		}
	}
})
