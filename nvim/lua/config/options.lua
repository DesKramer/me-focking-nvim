-- General Neovim settings and options

local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.colorcolumn = "80"
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of word
opt.iskeyword:append("-")

-- Disable swapfile
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Undo
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

-- Update time
opt.updatetime = 50

-- Completion
opt.completeopt = "menuone,noselect"

-- Mouse support
opt.mouse = "a"

-- Show mode
opt.showmode = false

-- Command line height
opt.cmdheight = 1

-- File encoding
opt.fileencoding = "utf-8"

-- Always show tabline
opt.showtabline = 2

-- Popup menu height
opt.pumheight = 10

-- Concealing
opt.conceallevel = 0

-- Session options
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"