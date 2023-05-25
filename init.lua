--------------- Basical Set---------------------------
local set = vim.o
local cmd = vim.cmd
local g = vim.g
-- Set Line Number and Relative number
set.number = true
set.relativenumber = true
-- Globle Clipboard and Highlight use xclip
set.clipboard = "unnamedplus"
--[[
vim.api.nvim_create_autocmd({"TextYankPost"},{
	pattern = {"*"},
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})
--]]
---------------- Keybindings --------------------------
local opt = { noremap = true, silent = true }
-- set Leader key is Space
vim.g.mapleader = " "
-- new bindings of <C-w>
vim.keymap.set("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set("n", "<Leader>s", "<C-w>s", opt)
vim.keymap.set("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set("n", "<Leader>n", "<C-w>n", opt)
vim.keymap.set("n", "<Leader>c", "<C-w>c", opt)
-- jump visual line
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })

----------------- Lazy Nvim ----------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- Plugins
require("lazy").setup({
	{
		"RRethy/nvim-base16",
		lazy = true,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({})
		end,
		dependencies = {
			'kyazdani42/nvim-web-devicons'
		},
		opts = {},
	},
	{
		keys = {
			{ "<leader>t", ":NERDTreeToggle<CR>", desc = "toggle nerdtree" },
			{ "<leader>l", ":NERDTreeFind<CR>",   desc = "find this file" },
		},
		cmd = { "NERDTreeToggle", "NERDTree", "NERDTreeFind" },
		config = function()
			vim.cmd([[
			let NERDTreeShowLineNumbers=1
			autocmd FileType nerdtree setlocal relativenumber
			]])
		end,
		"preservim/nerdtree",
	},
	{
		event = "VeryLazy",
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
	{
		event = "VeryLazy",
		"williamboman/mason-lspconfig.nvim",
	},
	{
		event = "VeryLazy",
		"neovim/nvim-lspconfig",
	},
	{
		event = "VeryLazy",
		"hrsh7th/nvim-cmp",
		dependencies = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/nvim-cmp',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/vim-vsnip',
		}
	},
	{
		event = "VeryLazy",
		"dcampos/nvim-snippy",
	},
	{
		event = "VeryLazy",
		"folke/neodev.nvim",
		opts = {},
	},
	{
		event = "VeryLazy",
		"windwp/nvim-autopairs",
	},
	{
		event = "VeryLazy",
		"tpope/vim-fugitive",
		cmd = "Git",
	},
	{
		event = "VeryLazy",
		"mfussenegger/nvim-dap",
	},
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
	},
})
-- ColorTheme
local current_theme_name = os.getenv('BASE16_THEME')
if current_theme_name and g.colors_name ~= 'base16-' .. current_theme_name then
	cmd('let base16colorspace=256')
	cmd('colorscheme base16-' .. current_theme_name)
end
-- Require Setup for Plugins
require("mason").setup()
require("mason-lspconfig").setup()
require("neodev").setup({
	-- add any options here, or leave empty to use the default settings
})
require("nvim-autopairs").setup({})
--------------------- nvim cmp --------------------------------------
local cmp = require('cmp')

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local snippy = require("snippy")
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif snippy.can_expand_or_advance() then
				snippy.expand_or_advance()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif snippy.can_jump(-1) then
				snippy.previous()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = 'buffer' },
	})
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
	}, {
		{ name = 'buffer' },
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})
cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)
-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
--   require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--     capabilities = capabilities
--   }

---------------------- Setup language servers ------------------------------------
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {
	capabilities = capabilities,
	completion = {
		callSnippet = "Replace"
	},
}
lspconfig.html.setup {
	capabilities = capabilities,
}
lspconfig.marksman.setup {
	capabilities = capabilities,
}
lspconfig.lua_ls.setup {
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { 'vim' },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
			completion = {
				callSnippet = "Replace"
			},
		},
	},
	capabilities = capabilities,
}
lspconfig.yamlls.setup {
	capabilities = capabilities,
}


---------------------- Lspconfig Keymap -------------------------
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})
--------------------------- DAP --------------------------------
local dap = require('dap')
local dapui = require('dapui')
dapui.setup()
dap.adapters.codelldb = {
	type = 'server',
	host = '127.0.0.1',
	port = 13000 -- 💀 Use the port printed out or specified with `--port`
}
dap.adapters.codelldb = {
	type = 'server',
	port = "${port}",
	executable = {
		-- CHANGE THIS to your path!
		command = '/home/sun/.software/codelldb/extension/adapter/codelldb',
		args = { "--port", "${port}" },

		-- On windows you may have to uncomment this:
		-- detached = false,
	}
}
dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
	},
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

vim.keymap.set("n", "<leader>dr", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<leader>dn", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<leader>di", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<leader>do", function()
	require("dap").step_out()
end)
vim.keymap.set("n", "<leader>ds", function()
	require("dap").disconnect()
end)
