--Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
	-- FZF for fuzzy finding
	--{
	--	'junegunn/fzf.vim',
	--	dependencies = { 'junegunn/fzf' },
	--},

	-- Syntax highlighting
	-- after installation, do :TSInstall javascript python go
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup({
	ensure_installed = {
		"javascript", "typescript", "python", "lua",
		"go", "html", "css", "json", "markdown"
	},
	highlight = { enable = true },
	indent = { enable = true }
			})
		end
	},

  -- Color scheme github light
	{
		'projekt0n/github-nvim-theme',
		config = function()
			vim.cmd('colorscheme github_light')
		end
	},

  -- Show git change indications on sidebar
  {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup({
      signs = {
        add          = { text = '▊' },
        change       = { text = '▊' },
        delete       = { text = '▁' },
        topdelete    = { text = '▁' },
        changedelete = { text = '▊' },
        untracked    = { text = '▊' },
      },
    })
    end
  },

  -- Language server protocol
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Show diagnostics in sign column
      vim.diagnostic.config({
        signs = true,
        virtual_text = false,  -- Hide inline text
        update_in_insert = false,
      })

      -- Define diagnostic signs
      local signs = {
        Error = "●",
        Warn = "●",
        Hint = "●",
        Info = "●"
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end
  },

  -- Add Mason
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end
  },

  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Setup completion capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Setup language servers
      require('lspconfig').gopls.setup({}) -- Golang
      require('lspconfig').ts_ls.setup({}) -- TypeScript / Javascript

      -- For additional JS / TS features
      -- require('lspconfig').eslint.setup({})

      -- Go to definition, implementation, usage etc.
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local opts = { buffer = ev.buf }

          -- Go to definition
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

          -- Go to implementation
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

          -- Find references/usages
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

          -- Go to type definition
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)

          -- Hover documentation
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        end,
      })

      -- Auto-close references list after selection
      --vim.keymap.set('n', 'gr', function()
      --  vim.lsp.buf.references()
      --  vim.cmd('copen')
      --end, opts)

      -- Diagnostics configuration
      vim.diagnostic.config({
        signs = true,
        virtual_text = false,
        update_in_insert = false,
      })

      -- Diagnostic signs
      local signs = {
        Error = "●",
        Warn = "●",
        Hint = "●",
        Info = "●"
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end
  },

  -- Language servers
  {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright', 'typescript-language-server', 'gopls' }
      })

      -- Auto-setup LSP servers
      require('mason-lspconfig').setup_handlers({
        function(server_name)
          local servers = {
            ['typescript-language-server'] = 'ts_ls',
            -- ['eslint-lsp'] = 'eslint'  -- Add this mapping
          }
          local lsp_name = servers[server_name] or server_name

          require('lspconfig')[server_name].setup({})
        end,
      })
    end
  },

  -- Go diagnostics, auto-imports, formatting, specific tooling
  {
    'ray-x/go.nvim',
    dependencies = {'ray-x/guihua.lua'},
    config = function()
      require('go').setup()
    end,
    ft = {'go', 'gomod'},
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',    -- LSP completions
      'hrsh7th/cmp-buffer',      -- Buffer completions
      'hrsh7th/cmp-path',        -- File path completions
      'L3MON4D3/LuaSnip',       -- Snippet engine
      'saadparwaiz1/cmp_luasnip', -- Snippet completions
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },    -- LSP completions
          { name = 'luasnip' },     -- Snippet completions
        }, {
          { name = 'buffer' },      -- Buffer completions
          { name = 'path' },        -- File path completions
        })
      })
    end
  },

  -- Auto pairs for quotes, brackets, etc.
  {
    'windwp/nvim-autopairs',
    config = function()
      local autopairs = require('nvim-autopairs')
      autopairs.setup({
        check_ts = true,  -- Use treesitter for smarter pairing
      })

      -- Integrate with nvim-cmp if you added it
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end
  },

  -- Better search with count display
  {
    'kevinhwang91/nvim-hlslens',
    config = function()
      require('hlslens').setup()

      -- Fixed keymaps
      vim.keymap.set('n', 'n', function()
        vim.cmd('normal! n')
        require('hlslens').start()
      end)

      vim.keymap.set('n', 'N', function()
        vim.cmd('normal! N')
        require('hlslens').start()
      end)
    end
  },

  -- Search across project
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup()
    end
  },

  -- Smart commenting with Ctrl+/
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
      
      -- Map Ctrl+/ for normal mode (single line)
      vim.keymap.set('n', '<C-_>', function()
        require('Comment.api').toggle.linewise.current()
      end)
      
      -- Map Ctrl+/ for visual mode (multiple lines)
      vim.keymap.set('v', '<C-_>', function()
        local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
        vim.api.nvim_feedkeys(esc, 'nx', false)
        require('Comment.api').toggle.linewise(vim.fn.visualmode())
      end)
    end
  },
})

-- Keybinding for Ctrl+P
-- vim.keymap.set('n', '<C-p>', ':Files<CR>')
-- Show most recently used files first
--vim.keymap.set('n', '<C-p>', ':History<CR>')
vim.keymap.set('n', '<C-p>', ':Telescope oldfiles<CR>')

-- Scroll while keeping cursor in place
vim.keymap.set('n', '<C-e>', '<C-e>j')
vim.keymap.set('n', '<C-y>', '<C-y>k')

-- Absolute line numbers
vim.opt.number = true

-- Indentation width
vim.opt.shiftwidth = 2

-- Tab display width
vim.opt.tabstop = 2

-- Use spaces instead of tabs (looks identical across editors, cleaner git diffs, convention)
vim.opt.expandtab = true

-- Git branch in status line
vim.cmd([[
  function! GitBranch()
    return system("git branch --show-current 2>/dev/null | tr -d '\n'")
  endfunction
  set statusline=%f\ %m\ %r%=[%{GitBranch()}]\ %l,%c\ %P
]])

-- Hide command line when unused
vim.opt.cmdheight = 0

-- Auto-save on text change
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
  callback = function()
    if vim.bo.modified then
      vim.cmd("silent! write")
    end
  end,
})

-- Auto-reload files changed externally (for example by claude code)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorMoved"}, {
  callback = function()
    vim.cmd("checktime")
  end,
})

-- Highlight search results
vim.opt.hlsearch = true

-- Show matches as you type
vim.opt.incsearch = true 

-- Case insensitive search
vim.opt.ignorecase = true

-- Case sensitive if uppercase used
vim.opt.smartcase = true

-- Clear search highlight with Esc
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>')

-- Search text
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
-- Find files
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')

-- Ensure line numbers stay on
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
  callback = function()
    vim.opt_local.number = true
  end,
})

-- Move up the list of fzf results
--vim.env.FZF_DEFAULT_OPTS = '--bind=ctrl-o:down'

-- TODO
-- when finding usages of function, then clicking one of the items, list pane should Auto-close
-- when finding usages of function, it should exclude definition?
-- when selecting text, then hitting / , the selected text should be in the search field
-- telesope file search for 'page.tsx' doesn't list all page.tsx files, only three
-- file explorer (rarely)
-- slightly more space between line numbers and rest of editor text
-- ability to revert changes line by line, looking at the change indications in the sidebar

