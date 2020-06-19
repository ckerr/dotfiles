:syntax on

:set background=dark
:colorscheme vividchalk

" :set number
" :set relativenumber
" https://stackoverflow.com/questions/5728259/how-to-clear-the-line-number-in-vim-when-copying
" :se mouse+=a

" Remember position of last edit and return on reopen
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
