:syntax on

:set background=dark
" silent! so a machine that has not run setup-vim.sh yet does not
" print E185 on every startup
:silent! colorscheme vividchalk

" :set number
" :set relativenumber
" https://stackoverflow.com/questions/5728259/how-to-clear-the-line-number-in-vim-when-copying
" :se mouse+=a

" Remember position of last edit and return on reopen
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

nmap <C-n> :NERDTreeToggle<CR>

" ALE: run only these linters (g:, not b: -- a buffer-local set here only
" ever applies to the buffer that exists while .vimrc is sourced).
" C/C++ go through clangd, which reads compile_commands.json itself; ALE's
" own cc/clangtidy linters parse that file in VimScript and hang vim for
" minutes on a Chromium-sized one.
let g:ale_linters = {'javascript': ['eslint'], 'c': ['clangd'], 'cpp': ['clangd']}
let g:ale_linters_explicit = 1
" Chromium's clangd understands Chromium's clang flags; gclient keeps it current.
let g:ale_cpp_clangd_executable = expand('~/electron/gn/main/src/third_party/llvm-build/Release+Asserts/bin/clangd')
let g:ale_c_clangd_executable = g:ale_cpp_clangd_executable
" Lets clangd ask the system compiler for its include dirs in non-Chromium
" projects. The glob is quoted because ALE runs the command through the
" login shell, and zsh aborts on an unmatched glob.
let g:ale_cpp_clangd_options = "--query-driver='/usr/bin/*'"
let g:ale_c_clangd_options = g:ale_cpp_clangd_options

