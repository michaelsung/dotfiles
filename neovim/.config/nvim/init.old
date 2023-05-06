set scrolloff=8
set number
set relativenumber
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'folke/which-key.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'sudormrfbin/cheatsheet.nvim'
Plug 'nvim-lua/popup.nvim'
call plug#end()

lua require('nvim-tree').setup()
lua require('which-key').setup()

" setting correct colour appearance in tmux - https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
" You might have to force true color when using regular vim inside tmux as the
" colorscheme can appear to be grayscale with "termguicolors" option enabled.
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

syntax on
set termguicolors
colorscheme catppuccin_mocha

let mapleader = " "
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>

" open fzf for git files + all files
nnoremap <C-p> :GFiles<CR> 
nnoremap <leader>ff :Files<CR>

" quickfix navigation
nnoremap <C-k> :cnext<CR>
nnoremap <C-j> :cprev<CR>

" nvim tree
nnoremap <leader>pv :NvimTreeToggle<CR>

" which-key
nnoremap <leader>h :WhichKey<CR>


