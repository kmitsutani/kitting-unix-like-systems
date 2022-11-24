syntax enable
let g:not_isbow = glob("~/.isbow")

" encodings
if g:not_isbow
  set encoding=utf-8
  set termencoding=utf-8
else
  set encoding=utf-8
  set termencoding=utf-8
endif

scriptencoding utf-8
set fileencodings=utf-8,iso-2022-jp,cp932,euc-jp,default,latin
set fileformats=unix,dos,mac
set ambiwidth=double
set fileencoding=utf-8
set ttimeoutlen=10
set ambiwidth=double

" backspace
set backspace=indent,eol,start

" indent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
au BufNewFile,BufRead *.py set tabstop=4 shiftwidth=4
set noswapfile

" searching
set incsearch " incremental search
set ignorecase
set smartcase
set hlsearch

" toggle highlight by double touch of <ESC>
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" Cursor
set whichwrap=b,s,h,l,<,>,[,],~ " カーソルの左右移動で行末から次の行の行頭への移動が可能になる
set number " 行番号を表示
set cursorline " カーソルラインをハイライト"

" completion
set wildmenu " コマンドモードの補完
set history=5000 " 保存するコマンド履歴の数

" clipboard
set clipboard=unnamed,autoselect

" off indent when paste from buffer
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

" key remap
map <F18> <Nop>
map <F19> <Nop>
map <S-F6> <Nop>
map <S-F7> <Nop>
" noremap : ;
" noremap ; :
noremap <C-c> <Nop>
imap <Nul> <Nop>
inoremap ,d <C-r>=strftime('%Y-%m-%d')<Return>
inoremap ,t <C-r>=strftime('%H:%M:%S')<Return>
inoremap ,dt <C-r>=strftime('%Y-%m-%d %H:%M:%S')<Return>
inoremap ,= =======================================

augroup python
  autocmd FileType python set tabstop=4
  autocmd FileType python setlocal completeopt-=preview
augroup END


source ~/.vimrc_dein

if !&compatible
  set nocompatible
endif

if has('gui_macmvim')
  source ~/_gvimrc 
  let g:vimrc_local_finish = 1
endif
