--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  --'tpope/vim-surround',
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  -- {
  --   -- LSP Configuration & Plugins
  --   'neovim/nvim-lspconfig',
  --   dependencies = {
  --     -- Automatically install LSPs to stdpath for neovim
  --     { 'williamboman/mason.nvim', config = true },
  --     'williamboman/mason-lspconfig.nvim',
  --
  --     -- Useful status updates for LSP
  --     -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
  --     { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
  --
  --     -- Additional lua configuration, makes nvim stuff amazing!
  --     'folke/neodev.nvim',
  --   },
  -- },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>cf', vim.lsp.buf.format, '[C]ode [F]ormat', {'n', 'v'})

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          map('K', function() vim.lsp.buf.hover({ border = "rounded"}) end, 'Hover Documentation')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })





      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    commit = "1e1900b",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- Enhanced f,t, F, T motions
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
      end,
    },
  },

  -- QML syntax highlighting
  { "peterhoeg/vim-qml",    opts = {}, config = function(self, opts) end },
  
  -- JAI syntax highlighting
  { 'rluba/jai.vim' },

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function(_, opts)
      vim.cmd([[
        function OpenMarkdownPreview (url)
          execute "silent ! chrome.lnk --new-window " . a:url
        endfunction
        let g:mkdp_browserfunc = 'OpenMarkdownPreview'
      ]])
    end,
  },

  {
    'ixru/nvim-markdown',
    config = function()
      vim.g.vim_markdown_no_default_key_mappings = 1
    end
  },

  {
    -- Fancy quickfix
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    "junegunn/vim-easy-align",
    event = "VeryLazy",
  },
  
  {
    'sindrets/diffview.nvim',
    config = function()
      require("diffview").setup({
        keymaps = {
          -- Disable the default normal mode mapping for `<tab>`:
          view = {
            { "n", "<tab>", false },
            { "n", "<s-tab>", false },
          },
          file_panel = {
            { "n", "<tab>", false },
            { "n", "<s-tab>", false },
          },
          file_history_panel = {
            { "n", "<tab>", false },
            { "n", "<s-tab>", false },
          },
          option_panel = {
            { "n", "<tab>", false },
            { "n", "<s-tab>", false },
          }
        },
      })
    end
  },

  -- Fancy folding regions
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = "VeryLazy",
    opts = {
      -- INFO: Uncomment to use treeitter as fold provider, otherwise nvim lsp is used
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
      open_fold_hl_timeout = 400,
      -- close_fold_kinds_for_ft = { default = { 'imports', 'comment' } },
      close_fold_kinds_for_ft = { default = {} },
      preview = {
        win_config = {
          border = { "", "─", "", "", "", "─", "", "" },
          -- winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
    },
    init = function()
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      vim.o.foldcolumn = "0" -- '0' is not bad
      vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function(_, opts)
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local totalLines = vim.api.nvim_buf_line_count(0)
        local foldedLines = endLnum - lnum
        local suffix = (" 󰁂 %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        local rAlignAppndx =
            math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
        suffix = (" "):rep(rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end
      opts["fold_virt_text_handler"] = handler
      require("ufo").setup(opts)
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
      -- vim.keymap.set("n", "K", function()
      --   local winid = require("ufo").peekFoldedLinesUnderCursor()
      --   if not winid then
      --     -- vim.lsp.buf.hover()
      --     vim.cmd [[ Lspsaga hover_doc ]]
      --   end
      -- end)
    end,
  },

  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
  },

  {
    'folke/tokyonight.nvim',
  },

  {
    'EdenEast/nightfox.nvim',
  },

  {
    'habamax/vim-gruvbit',
    priority = 1000,
  },

  {
    'beyondmarc/hlsl.vim'
  },

  {
    'tikhomirov/vim-glsl'
  },

  {
    "gbprod/yanky.nvim",
    dependencies = {
      { "kkharji/sqlite.lua" }
    },
    opts = {
    },
    keys = {
      { "<leader>p", function() require("telescope").extensions.yank_history.yank_history({}) end,  desc = "Open Yank History" },
      { "y",         "<Plug>(YankyYank)",                                                           mode = { "n", "x" },                                desc = "Yank text" },
      { "p",         "<Plug>(YankyPutAfter)",                                                       mode = { "n", "x" },                                desc = "Put yanked text after cursor" },
      { "P",         "<Plug>(YankyPutBefore)",                                                      mode = { "n", "x" },                                desc = "Put yanked text before cursor" },
      { "gp",        "<Plug>(YankyGPutAfter)",                                                      mode = { "n", "x" },                                desc = "Put yanked text after selection" },
      { "gP",        "<Plug>(YankyGPutBefore)",                                                     mode = { "n", "x" },                                desc = "Put yanked text before selection" },
      { "<c-p>",     "<Plug>(YankyPreviousEntry)",                                                  desc = "Select previous entry through yank history" },
      { "<c-n>",     "<Plug>(YankyNextEntry)",                                                      desc = "Select next entry through yank history" },
      { "]p",        "<Plug>(YankyPutIndentAfterLinewise)",                                         desc = "Put indented after cursor (linewise)" },
      { "[p",        "<Plug>(YankyPutIndentBeforeLinewise)",                                        desc = "Put indented before cursor (linewise)" },
      { "]P",        "<Plug>(YankyPutIndentAfterLinewise)",                                         desc = "Put indented after cursor (linewise)" },
      { "[P",        "<Plug>(YankyPutIndentBeforeLinewise)",                                        desc = "Put indented before cursor (linewise)" },
      { ">p",        "<Plug>(YankyPutIndentAfterShiftRight)",                                       desc = "Put and indent right" },
      { "<p",        "<Plug>(YankyPutIndentAfterShiftLeft)",                                        desc = "Put and indent left" },
      { ">P",        "<Plug>(YankyPutIndentBeforeShiftRight)",                                      desc = "Put before and indent right" },
      { "<P",        "<Plug>(YankyPutIndentBeforeShiftLeft)",                                       desc = "Put before and indent left" },
      { "=p",        "<Plug>(YankyPutAfterFilter)",                                                 desc = "Put after applying a filter" },
      { "=P",        "<Plug>(YankyPutBeforeFilter)",                                                desc = "Put before applying a filter" },
    },
  },

  {
    'mhinz/vim-startify',
    config = function()
      if vim.fn.has('macunix') == 1 then
        vim.g.startify_bookmarks = {
          { d = '~/Develop/' },
          { i = '~/.config/nvim/init.lua' }
        }
      elseif vim.fn.has('win64') == 1 then
        vim.g.startify_bookmarks = {
          { c = 'D:\\cli\\cl17.bat' },
          { d = 'D:\\Develop\\cpp' },
          -- { i = 'c:\\Users\\Admin\\AppData\\Local\\nvim\\init.lua' },
          { i = '~\\AppData\\Local\\nvim\\init.lua' },
          { p = '~\\Artec Studio Python Modules\\demo.py' },
        }
      end
      vim.g.startify_commands = {
        { l = { 'Lazy', ':Lazy' } },
        { m = { 'Mason', ':Mason' } }
      }
      vim.g.startify_files_number = 10
      vim.g.startify_custom_header = {
        "                                                      ",
        "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                      ",
      }
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_c = { { 'filename', path = 2 } },
      }
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
    config = function()
      vim.g.indent_blankline_filetype_exclude = {
        'lspinfo',
        'packer',
        'checkhealth',
        'help',
        'man',
        'txt',
        '',
        'startify',
        'alpha',
        'markdown'
      }
    end
  },

  -- logs syntax highlighting
  { 'mtdl9/vim-log-highlighting', config = function(self, opts) end },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',      opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    -- branch = '0.1.x',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local filetypes = { 'bash', 'c', 'cpp', 'javascript', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(filetypes)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function() vim.treesitter.start() end,
      })
    end,
  },

  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        --backdrop = 0.9, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        --backdrop_highlight = "Normal",
        --backdrop_color = nil,
        -- height and width can be:
        -- * an absolute number of cells when > 1
        -- * a percentage of the width / height of the editor when <= 1
        -- * a function that returns the width or the height
        width = 90, -- width of the Zen window
        height = 1, -- height of the Zen window
        -- by default, no options are changed for the Zen window
        -- uncomment any of the options below, or add other vim.wo options you want to apply
        options = {
          signcolumn = "no",  -- disable signcolumn
          number = false,     -- disable number column
          -- relativenumber = false, -- disable relative numbers
          -- cursorline = false, -- disable cursorline
          -- cursorcolumn = false, -- disable cursor column
          foldcolumn = "0",  -- disable fold column
          -- list = false, -- disable whitespace characters
        },
      },
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false,   -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
          -- you may turn on/off statusline in zen mode by setting 'laststatus'
          -- statusline will be shown only if 'laststatus' == 3
          laststatus = 0,               -- turn off the statusline in zen mode
        },
        twilight = { enabled = true },  -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = false },     -- disables the tmux statusline
        -- this will change the font size on kitty when in zen mode
        -- to make this work, you need to set the following kitty options:
        -- - allow_remote_control socket-only
        -- - listen_on unix:/tmp/kitty
        kitty = {
          enabled = false,
          font = "+4", -- font size increment
        },
        -- this will change the font size on alacritty when in zen mode
        -- requires  Alacritty Version 0.10.0 or higher
        -- uses `alacritty msg` subcommand to change font size
        alacritty = {
          enabled = false,
          font = "14", -- font size
        },
        -- this will change the font size on wezterm when in zen mode
        -- See alse also the Plugins/Wezterm section in this projects README
        wezterm = {
          enabled = false,
          -- can be either an absolute font size or the number of incremental steps
          font = "+4", -- (10% increase per step)
        },
      },
      -- callback where you can add custom code when the Zen window opens
      on_open = function(win)
        vim.opt.textwidth = 80
      end,
      -- callback where you can add custom code when the Zen window closes
      on_close = function()
      end,
    }
  },

  {
    'davvid/telescope-git-grep.nvim'
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      default_component_configs = {
        icon = {
          default = "",
          highlight = "NeoTreeFileIcon",
        },
      },
      filesystem = {
        bind_to_cwd = false,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
        window = {
          mappings = {
            -- disable fuzzy finder
            ["/"] = "noop"
          }
        }
      },
      window = {
        position = "float",
        popup = {
          size = {
            height = "80%",
            width = "50%",
          },
          border = "rounded",
          show_header = false,
        },
      },
    },
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'no'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- MY CUSTOM  OPTIONS
vim.cmd.language("en_US")
vim.o.wrap = false
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.cursorline = true
vim.opt.listchars = {
  eol = '⤶',
  space = '·',
  trail = '·',
  extends = '◀',
  precedes = '▶',
  tab = '_'
}
vim.g.netrw_keepdir = 0
vim.o.virtualedit = 'onemore'
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.scrolloff = 5
vim.o.showbreak = '↪ '
vim.o.autoread = true

-- Create some helpers
local agrp = vim.api.nvim_create_augroup
local acmd = vim.api.nvim_create_autocmd

local _markdown = agrp("_markdown", { clear = true })
acmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.md",
  command = "set textwidth=80",
  group = _markdown,
})

acmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    -- vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', {buffer = args.buf, desc = 'Open [M]arkdown [P]review', silent = true})
    local wk = require("which-key")
    wk.add({
      { "<leader>m",  group = "Markdown" }, -- group
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Open Markdown Preview", buffer = args.buf },
    })

    -- wk.register({
    --   m = {
    --     name = "markdown", -- optional group name
    --     p = { "<cmd>MarkdownPreview<cr>", "Open Markdown Preview", buffer = args.buf }, -- create a binding with label
    --     -- r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File", noremap=false, buffer = 123 }, -- additional options for creating the keymap
    --     -- n = { "New File" }, -- just a label. don't create any mapping
    --     -- e = "Edit File", -- same as above
    --     -- ["1"] = "which_key_ignore",  -- special label to hide it in the popup
    --     -- b = { function() print("bar") end, "Foobar" } -- you can also pass functions!
    --   },
    -- }, { prefix = "<leader>" })

    -- wk.add({
    --       { "<leader>m", group = "markdown" },
    --       { "<leader>mp", "<cmd>MarkdownPreview<cr>", buffer = 13, desc = "Open Markdown Preview" },
    --     },
    --     {}
    -- })
    --
  end
})

local _help = agrp("help_window_right", {})
acmd("BufWinEnter", {
  group = _help,
  callback = function()
    if vim.o.filetype == 'help' or vim.o.filetype == 'text' then
      vim.cmd.wincmd("L")
    end

    -- local ft = vim.o.filetype
    -- if ((ft ~= 'NvimTree') and (ft ~= 'Lazy') and (ft == 'mason')) then vim.cmd.wincmd("L") end
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "jai",
  callback = function()
    vim.keymap.set("n", "<F5>", function()
          local filepath = vim.fn.expand("%:p")         -- полный путь к текущему файлу
          local exename = vim.fn.expand("%:r") .. ".exe" -- тот же путь, но без расширения + .exe
          vim.cmd("write");
          vim.cmd("!jai.bat " .. filepath .. "&& ".. exename)
    end, { buffer = true })
    vim.keymap.set("n", "<F7>", function()
          local filepath = vim.fn.expand("%:p")         -- полный путь к текущему файлу
          vim.cmd("write");
          vim.cmd("!jai.bat " .. filepath)
    end, { buffer = true })
  end,
})


-- Custom filetypes mappings
vim.filetype.add({
  extension = {
    vcxproj = 'xml',
    props = 'xml',
    wsb = 'xml',
    props = 'xml',
    desc = 'xml',
  }
})


-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- MY CUSTOM KEYMAPS
vim.keymap.set('n', '<Tab>', ':wincmd w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':wincmd W<CR>', { silent = true })
-- vim.keymap.set('n', '<F1>', ':Alpha<CR>', { silent = true })
vim.keymap.set('n', '<F1>', ':Startify<CR>', { silent = true })
vim.keymap.set('n', '<A-Left>', '<C-O>', { noremap = true })
vim.keymap.set('n', '<A-Right>', '<C-I>', { noremap = true })
vim.keymap.set('n', '<End>', '<End>l', { noremap = true })
vim.keymap.set('n', '<F2>', ':LspClangdSwitchSourceHeader<CR>', { silent = true })
vim.keymap.set('n', '<F3>', 'n', { noremap = true })
vim.keymap.set('i', '<F3>', '<C-O>n', { noremap = true })
vim.keymap.set('n', '<S-F3>', 'N', { noremap = true })
vim.keymap.set('i', '<S-F3>', '<C-O>N', { noremap = true })
vim.keymap.set('n', '<F12>', ':noh<CR> :IndentBlanklineRefresh<CR>', { silent = true })
vim.keymap.set('n', '<Esc>', ':noh<CR><Esc>', { silent = true })
vim.keymap.set('n', '<F11>', ':let g:neovide_fullscreen = !g:neovide_fullscreen<CR>')
vim.keymap.set('n', '<leader>cd', ':tcd %:p:h<CR>', { noremap = true, desc = 'CD to current file\'s directory' })
-- vim.keymap.set('v', '<leader>cf', vim.lsp.buf.format)
vim.keymap.set({ 'n', 'i' }, '<C-s>', ':w<CR>', { silent = true })
vim.keymap.set('n', '<C-ы>', ':w<CR>', { silent = true })
vim.keymap.set('n', '<C-к>', '<C-r>', { silent = true })
vim.keymap.set('n', '<C-D>', 'viw<C-g>')
vim.keymap.set('n', '<F9>', ':Inspect<CR>')
vim.keymap.set('n', '<F10>', ':set list!<CR>', { silent = true })
vim.keymap.set('i', '<F10>', '<C-O>:set list!<CR>', { silent = true })
-- vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle!<CR>', {silent = true})
vim.keymap.set('n', '<leader>e', ':Neotree position=float reveal dir=%:p:h<CR>', { silent = true })
vim.keymap.set('v', '<A-Down>', ':m \'>+1<CR>gv=gv', { noremap = true })
vim.keymap.set('v', '<A-Up>', ':m \'<-2<CR>gv=gv', { noremap = true })
vim.keymap.set('n', '<A-Down>', '}', { noremap = true })
vim.keymap.set('n', '<A-Up>', '{', { noremap = true })
vim.keymap.set('n', '<S-Del>', 'dd', { noremap = true })
vim.keymap.set('i', '<S-Del>', '<C-O>dd', { noremap = true })
vim.keymap.set('', '<Del>', '"_x', { noremap = true })
vim.keymap.set('n', 'd', '"_d', { noremap = true })
vim.keymap.set('v', 'd', '"_d', { noremap = true })
vim.keymap.set('n', 'dd', '"_dd', { noremap = true })
vim.keymap.set('v', 'dd', '"_dd', { noremap = true })
--vim.keymap.set('n', '<A-q>', '<C-W>q', { noremap = true})
vim.keymap.set('n', '<A-q>', ':close<CR>', { noremap = true })
vim.keymap.set('n', '<F8>', ':match NvimInternalError /\\s\\+$/<CR>', { noremap = true })
vim.keymap.set('n', '<S-F8>', ':match<CR>', { noremap = true })

if vim.fn.has('win64') == 1 then
  -- C++ compiler stuff
  vim.keymap.set('n', '<F7>', ':w <bar> !cl17.bat %<CR>')
  vim.keymap.set('i', '<F7>', '<C-O><F7>', { remap = true })

  vim.keymap.set('n', '<F5>',
    ':w <bar> :execute expand("!cl17.bat " .. \'%:p\' .. " && " .. "start remedybg.exe "  .. \'%:p:r\' .. ".exe")<CR>')
  vim.keymap.set('i', '<F5>', '<C-O><F5>', { remap = true })

  vim.keymap.set('n', '<C-F5>', ':w <bar> :execute expand("!cl17.bat " .. \'%:p\' .. " && " .. \'%:p:r\' .. ".exe")<CR>')
  vim.keymap.set('i', '<C-F5>', '<C-O><C-F5>', { remap = true })
elseif vim.fn.has('macunix') == 1 then
  -- TODO
end

local function initBuildBat(_)
  vim.keymap.set('n', '<leader>bb', ':wa <bar> !build.bat compile<CR>')
  vim.keymap.set('n', '<leader>br', ':wa <bar> !build.bat<CR>')
  vim.keymap.set('n', '<leader>bR', ':wa <bar> !build.bat run<CR>')
  vim.keymap.set('n', '<leader>bm', ':wa <bar> !build.bat meta<CR>')
  vim.keymap.set('n', '<leader>bd', ':wa <bar> !start /B build.bat debug<CR>')

  -- vim.cmd("set makeprg=build.bat")
  -- vim.keymap.set('n', '<leader>bq', ':wa <bar> :make compile<CR> :Trouble quickfix<CR>')
  --vim.keymap.set('n', '<leader>br', ':w <bar> :make<CR> :cw<CR>')



  vim.cmd("set makeprg=compile-file-in-visual-studio.bat\\ %")
  vim.cmd("set errorformat=%*\\\\d>%f(%l\\\\\\,%c):\\ %m")

  vim.keymap.set('n', '<leader>bv', ':wa <bar> !compile-file-in-visual-studio.bat %<CR>')
  vim.keymap.set('n', '<leader>bq', ':wa <bar> :make <CR> :Trouble quickfix<CR>')
end

-- vim.api.nvim_create_user_command('InitBuildBat', initBuildBat, {})
initBuildBat(nil)

vim.api.nvim_create_user_command('TelescopeColorschemePreview', function(_)
  require("telescope.builtin").colorscheme({ enable_preview = true })
end, {})

vim.keymap.set("n", "<leader>tt", function() require("trouble").toggle() end, { desc = '[T]oggle Trouble' })
vim.keymap.set("n", "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = '[T]oggle Trouble [W]orkspace diagnostics' })
vim.keymap.set("n", "<leader>td", function() require("trouble").toggle("document_diagnostics") end, { desc = '[T]oggle Trouble [D]ocument diagnostics' })
vim.keymap.set("n", "<leader>tq", function() require("trouble").toggle("quickfix") end, { desc = '[T]oggle Trouble [Q]uickfix' })
vim.keymap.set("n", "<leader>tl", function() require("trouble").toggle("loclist") end, { desc = '[T]oggle Trouble [L]oclist' })
vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end, { desc = '[T]oggle Trouble LSP references' })
vim.keymap.set("n", "<leader>tz", ':ZenMode<CR>', { desc = '[T]oggle [Z]en mode' })

--vim.keymap.set('v', '<C-C>', '"+y', { noremap = true });
--vim.keymap.set('v', '<C-C>', '"+y', { noremap = true });
--vim.keymap.set('v', '<C-X>', '"+x', { noremap = true });
--vim.keymap.set('c', '<C-V>', '<C-R>+');

--vim.cmd("set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯЖ;ABCDEFGHIJKLMNOPQRSTUVWXYZ:,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz")
--vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"
-- Comfigure langmap (https://github.com/Wansmer/langmapper.nvim#settings)
local function escape(str)
  -- You need to escape these characters to work correctly
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end

-- Recommended to use lua template string
local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмить]]
local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ]]

vim.opt.langmap = vim.fn.join({
  -- | `to` should be first     | `from` should be second
  escape(ru_shift) .. ';' .. escape(en_shift),
  escape(ru) .. ';' .. escape(en),
}, ',')
--- End langmap config


-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local trouble = require("trouble.providers.telescope")
require('telescope').setup {
  defaults = {
    layout_config = {
      width = 0.9,
      height = 0.9,
    },
    mappings = {
      --      i = {
      --        ['<C-u>'] = false,
      --        ['<C-d>'] = false,
      --      },
      i = {
        ["<c-t>"] = require('trouble.sources.telescope').open,
        ["<c-w>"] = require('trouble.sources.telescope').open,
        ["<PageDown>"] = require('telescope.actions').preview_scrolling_down,
        ["<PageUp>"] = require('telescope.actions').preview_scrolling_up,
        ["<c-p>"] = require('telescope.actions.layout').toggle_preview,
        ["<c-l>"] = require('telescope.actions.layout').cycle_layout_next,
      },
      n = {
        ["<c-t>"] = require('trouble.sources.telescope').open,
      },
    },
  },
  extensions = {
    git_grep = {
      cwd = '%:h:p',
      regex = nil,
      skip_binary_files = true,
      use_git_root = true
    }
  },
}

require('kanagawa').setup({
  compile = true,    -- enable compiling the colorscheme
  undercurl = true,   -- enable undercurls
  commentStyle = { italic = false },
  functionStyle = {},
  keywordStyle = { italic = false },
  statementStyle = { bold = true },
  typeStyle = {},
  transparent = false,      -- do not set background color
  dimInactive = false,      -- dim inactive window `:h hl-NormalNC`
  terminalColors = false,   -- define vim.g.terminal_color_{0,17}
  colors = {                -- add/modify theme and palette colors
    palette = {},
    theme = {
      wave = {},
      lotus = {},
      dragon = {},
      all = {}
    },
  },
  overrides = function(colors)   -- add/modify highlights
    return {
      -- Normal = { fg ="#d3b58d", bg = "#072626", italic = false},
      -- Comment = { fg = "#ffff10", italic = false },
    }
  end,
  theme = "wave",      -- Load "wave" theme when 'background' option is not set
  background = {       -- map the value of 'background' option to a theme
    dark = "wave",     -- try "dragon" !
    light = "lotus"
  },
})



-- setup must be called before loading
--vim.cmd("colorscheme custom_nvim_colorscheme_harmonized")
vim.cmd("colorscheme kanagawa")
-- vim.cmd("colorscheme naysayer")

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
    layout_config = {
      height = 0.9,
      width = 0.9
    }
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', function() require('telescope.builtin').git_files({ recurse_submodules = true }) end, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>gg', function() require('git_grep').live_grep({additional_args={'--ignore-case','--recurse-submodules'}}) end, { desc = 'Search [G]it [G]rep' })
vim.keymap.set('n', '<leader>gG', function() require('git_grep').live_grep({additional_args={'--ignore-case','--', vim.fn.getcwd()}}) end, { desc = 'Search [G]it [G]rep in cwd' })
vim.keymap.set('n', '<leader>ge', function()
  vim.ui.input({ prompt = "Git grep arguments: " }, function(input)
    if input then -- and vim.fn.isdirectory(input) == 1 then
      require('git_grep').live_grep({additional_args={'--ignore-case', '--recurse-submodules', '--', input }})
    end
    end)
end, { desc = 'Search [G]it Grep with [E]xplicit arguments' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':Telescope live_grep glob_pattern=*.', { desc = '[S]earch by [G]rep with glob pattern' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

vim.keymap.set("n", "<leader>st", function()
  local search = vim.fn.getreg('/')
  if not search or search == '' then
    return
  end

  vim.fn.setqflist({})
  vim.cmd("vimgrep /" .. search .. "/j %")
  require("trouble").open("quickfix")
end, { desc = "Send search to Trouble" })

-- example how to pass additional arguments to git grep
-- lua require('git_grep').live_grep({additional_args={'--', 'astudio/source/Panels/FillHoles'}})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-S>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_locally_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.locally_jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),

    -- ['<CR>'] = cmp.mapping(function(fallback)
    --     if cmp.visible() then
    --         if luasnip.expandable() then
    --             luasnip.expand()
    --         else
    --             cmp.confirm({
    --                 select = true,
    --             })
    --         end
    --     else
    --         fallback()
    --     end
    -- end),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),


  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

vim.cmd.source('$VIMRUNTIME/scripts/mswin.vim')
--vim.cmd.behave('mswin')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

vim.o.diffopt = "internal,closeoff"

if vim.g.neovide and vim.fn.has('win64') == 1 then
  --vim.opt.guifont = 'CaskaydiaMono Nerd Font Mono:h13'
  vim.opt.guifont = 'Consolas NF:h11'
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  -- vim.g.neovide_floating_shadow = true
  -- vim.g.neovide_floating_z_height = 10
  -- vim.g.neovide_light_angle_degrees = 45
  -- vim.g.neovide_light_radius = 5
  vim.keymap.set({ "n", "v" }, "<C-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>")
  vim.keymap.set({ "n", "v" }, "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>")
  vim.keymap.set({ "n", "v" }, "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>")
end

if vim.g.nvy == 1 then
  vim.opt.guifont = 'CaskaydiaMono Nerd Font:h11.5'
  -- vim.opt.guifont = 'Consolas NF:h11'
end

function CenterAllPipeSections()
  local pos = vim.fn.getpos("'<")
  local line_num = pos[2]
  local line = vim.fn.getline(line_num)

  local result = ""
  local i = 1

  while i < #line do
    local start_pipe = string.find(line, "|", i)
    if not start_pipe then
      result = result .. string.sub(line, i)
      break
    end

    local end_pipe = string.find(line, "|", start_pipe + 1)
    if not end_pipe then
      result = result .. string.sub(line, start_pipe)
      break
    end

    -- Добавляем текст до первого '|'
    result = result .. string.sub(line, i, start_pipe)

    -- Центрируем содержимое между двумя '|'
    local content = string.sub(line, start_pipe + 1, end_pipe - 1)
    local trimmed = vim.fn.trim(content)
    local total_space = end_pipe - start_pipe - 1
    local padding = total_space - #trimmed
    local left_pad = math.floor(padding / 2)
    local right_pad = padding - left_pad
    local centered = string.rep(" ", left_pad) .. trimmed .. string.rep(" ", right_pad)

    result = result .. centered
    i = end_pipe
  end

  result = result .. '|'

  vim.fn.setline(line_num, result)
end

vim.keymap.set("x", "<leader>cp", ":lua CenterAllPipeSections()<CR>", { desc = "Центрировать между |", silent = true })

