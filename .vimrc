set nocompatible
filetype off

"Vundle start
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

"vundle additional bundles start
Plugin 'altercation/vim-colors-solarized'
Plugin 'bling/vim-airline'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'Raimondi/delimitMate'
Plugin 'jez/vim-superman'
Plugin 'blueyed/vim-diminactive'
"Source youcompleteme to be able to use an own build handler
source $HOME/.vimrc_youcompleteme
Plugin 'chase/vim-ansible-yaml'
Plugin 'tomasr/molokai'
""vundle additional bundles end

call vundle#end()
filetype plugin indent on
"Vundle end

"General settings
set number
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
set fileformat=unix
set laststatus=2
set modeline
set splitright
set synmaxcol=160
syntax on

"Keymap related settings
""This allows to move by display line instead of actual line
""If you still want to move by actual line, this can be achieved using f{k,j}
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

"Colorscheme related settings
set background=dark
set t_Co=256
let g:rehash256 = 1
silent! colorscheme monokai

"vim-airline related settings
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_buffers=0
let g:airline#extensions#tabline#tab_nr_type=1
let g:airline_theme='lucius'
hi clear SignColumn
let g:airline#extensions#hunks#non_zero_only=1

"delimitMate related settings
let delimitMate_expand_cr = 1
augroup mydelimitMate
  au!
  au FileType markdown let b:delimitMate_nesting_quotes = ["`"]
  au FileType tex let b:delimitMate_quotes = ""
  au FileType tex let b:delimitMate_matchpairs = "(:),[:],{:},`:'"
  au FileType python let b:delimitMate_nesting_quotes = ['"', "'"]
augroup END

"Ansible related settings
"Dont indent after a blank line
let g:ansible_options = {'ignore_blank_lines': 0}
""Automatically set Ansible highlighting for *.yml
autocmd BufRead,BufNewFile *.yml set filetype=ansible

"Hightlight current line
:set cursorline 
