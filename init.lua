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

  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "folke/neodev.nvim",
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
      close_fold_kinds_for_ft = { default = { 'imports', 'comment' } },
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
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          -- vim.lsp.buf.hover()
          vim.cmd [[ Lspsaga hover_doc ]]
        end
      end)
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
          { a = 'c:\\Develop\\app-astudio' },
          { c = 'd:\\cli\\cl17.bat' },
          { d = 'd:\\Develop\\cpp' },
          { i = 'c:\\Users\\Admin\\AppData\\Local\\nvim\\init.lua' },
          { k = 'c:\\Users\\Admin\\Desktop\\NOTES\\knowledge.md' },
          { n = 'c:\\Users\\Admin\\Desktop\\NOTES\\ASTUDIO_MEETING_NOTES.md' },
          { t = 'd:\\Develop\\cpp\\tmp' },
          { p = 'c:\\Users\\Admin\\Artec Studio Python Modules\\demo.py' },
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
    branch = '0.1.x',
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

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-refactor',
    },
    opts = function(_, opts)
      opts.ignore_install = { 'help' }
    end,
    build = ':TSUpdate',
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
vim.keymap.set('n', '<F2>', ':ClangdSwitchSourceHeader<CR>', { silent = true })
vim.keymap.set('n', '<F3>', 'n', { noremap = true })
vim.keymap.set('i', '<F3>', '<C-O>n', { noremap = true })
vim.keymap.set('n', '<S-F3>', 'N', { noremap = true })
vim.keymap.set('i', '<S-F3>', '<C-O>N', { noremap = true })
vim.keymap.set('n', '<F12>', ':noh<CR> :IndentBlanklineRefresh<CR>', { silent = true })
vim.keymap.set('n', '<Esc>', ':noh<CR><Esc>', { silent = true })
vim.keymap.set('n', '<F11>', ':let g:neovide_fullscreen = !g:neovide_fullscreen<CR>')
vim.keymap.set('n', '<leader>cd', ':cd %:p:h<CR>', { noremap = true, desc = 'CD to current file\'s directory' })
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
vim.keymap.set("n", "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end,
  { desc = '[T]oggle Trouble [W]orkspace diagnostics' })
vim.keymap.set("n", "<leader>td", function() require("trouble").toggle("document_diagnostics") end,
  { desc = '[T]oggle Trouble [D]ocument diagnostics' })
vim.keymap.set("n", "<leader>tq", function() require("trouble").toggle("quickfix") end,
  { desc = '[T]oggle Trouble [Q]uickfix' })
vim.keymap.set("n", "<leader>tl", function() require("trouble").toggle("loclist") end,
  { desc = '[T]oggle Trouble [L]oclist' })
vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end,
  { desc = '[T]oggle Trouble LSP references' })
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
vim.keymap.set('n', '<leader>gg', require('git_grep').live_grep, { desc = 'Search [G]it [G]rep' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':Telescope live_grep glob_pattern=*.', { desc = '[S]earch by [G]rep with glob pattern' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'qmldir' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  refactor = {
    refactor = {
      smart_rename = {
        enable = true,
        -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
        keymaps = {
          smart_rename = "<leader>gn",
        },
      },
      -- disable = {"cpp", "lua"}
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>cf', vim.lsp.buf.format, '[C]ode [F]ormat')
  vim.keymap.set('v', '<leader>cf', vim.lsp.buf.format, { buffer = bufnr, desc = 'LSP: [C]ode [F]ormat' })

  nmap('gD', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>td', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, '[T]oggle [D]iagnostic')
  nmap('<leader>ti', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    '[T]oggle [I]nlay hints')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gd', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  -- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
  --   vim.lsp.buf.format()
  -- end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {
    cmd = { 'clangd --inlay_hints=true' }
  },
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true }
    },
  },
}

require("mason").setup()
-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

require('lspconfig').clangd.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { 'clangd', '--header-insertion=never' }
}

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

vim.cmd.source('$VIMRUNTIME/mswin.vim')
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

