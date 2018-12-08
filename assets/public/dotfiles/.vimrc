:set shiftwidth=2
:set expandtab
:syntax on
:colorscheme afterglow
:let g:javascript_plugin_jsdoc=1

:set number
:set relativenumber
" https://stackoverflow.com/questions/5728259/how-to-clear-the-line-number-in-vim-when-copying
" :se mouse+=a

" Remember position of last edit and return on reopen
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
