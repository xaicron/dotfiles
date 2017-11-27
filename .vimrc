"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.vim/dein')
  call dein#begin('~/.vim/dein')

  " Let dein manage dein
  " Required:
  call dein#add('~/.vim/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
    " call dein#add('Shougo/neosnippet.vim')
    " call dein#add('Shougo/neosnippet-snippets')
  call dein#add('Shougo/neocomplcache.git')
  call dein#add('Shougo/unite.vim.git')
  call dein#add('vim-perl/vim-perl')
  call dein#add('xaicron/perldoc-vim')
  call dein#add('othree/html5.vim')
  call dein#add('hail2u/vim-css3-syntax')
  call dein#add('jelera/vim-javascript-syntax')
  call dein#add('itchyny/lightline.vim')
  call dein#add('tpope/vim-fugitive')
  call dein#add('vim-scripts/AutoComplPop')
  call dein#add('fatih/vim-go')

  " Colorscheme
  call dein#add('wellsjo/wellsokai.vim')

  " You can specify revision/branch/tag.
    " call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

" settings for lightline

" 行番号を非表示
set nonumber
" 括弧入力時に対応する括弧を表示
set showmatch
" コマンドをステータス行に表示
set showcmd
" タイトルを表示
set title
" 常にステータス行を表示
set laststatus=2

" if(){}などのインデント
set cindent

" ルーラーを表示
set ruler
set ignorecase

" 検索に大文字を含んでいたら大小区別
set smartcase
" 検索時にヒット部位の色を変更
set hlsearch
" 検索時にインクリメンタルサーチを行う
set incsearch
set showmode

" コマンドラインの履歴の保存数
set history=1024
" インデント
set autoindent
set smartindent
set smarttab

" 置換に正規表現を使えるようにする
set magic

set tabstop=4
" タブを空白に置き換える
set expandtab
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start

" バックアップディレクトリを変更
set nobackup
" set backupdir=$HOME/.vim-backup
" let &directory = &backupdir

" スワップファイルを作らない
set noswapfile

" さようなら undofile
set noundofile

" マルチバイト記号を崩れないようにする
set ambiwidth=double

" syntax
filetype plugin on
filetype indent on
syntax on

" 256色対応
set t_Co=256

" カラースキーマ
colorscheme wellsokai

" ファイルタイプ別辞書ファイル
au FileType perl :set dictionary+=~/.vim/dict/perl_function.dict
au FileType perl :compiler perl

au FileType python     set omnifunc=pythoncomplete#Complete
au FileType javascript set omnifunc=javascriptcomplete#CompleteJS
au FileType html       set omnifunc=htmlcomplete#CompleteTags
au FileType css        set omnifunc=csscomplete#CompleteCSS
au FileType xml        set omnifunc=xmlcomplete#CompleteTags
au FileType php        set omnifunc=phpcomplete#CompletePHP
au FileType c          set omnifunc=ccomplete#Complete

" set filetype
:au BufEnter *.t,*.psgi,*.perl,*.tra,cpanfile execute ":setlocal filetype=perl"
:au BufEnter *.tt,*.cfm,*.tx execute ":setlocal filetype=html"
:au BufEnter *.sql execute ":setlocal filetype=mysql"

" 辞書ファイルを使用する設定に変更
set complete+=k
set complete-=i

" Vroom
set exrc

" 全角スペースとタブの表示
highlight WhiteSpace cterm=underline ctermfg=lightblue guibg=darkgray
match WhiteSpace /[	　]/

noremap  
noremap!  

" reset highlight
nmap  :nohlsearch<CR>

" :w + !perl command
map <F4>  :w !perl -Ilib<CR>
" !perl command
map <F5>  :!perl -Ilib %<CR>

" 全選択
map <F8> ggVG

" paste from clipboard
if has('mac') && !has('gui')
    nmap <S-p> :r !pbpaste<CR>
    vmap <S-p> :r !pbpaste<CR>
    nmap <S-y> :w !pbcopy<CR>
    vmap <S-y> :w !pbcopy<CR>
elseif has('unix') && !has('gui')
    nmap <Space>p :set paste<CR>:r !xsel -o -b<CR>:set nopaste<CR>
endif

" lhs comments
vmap ,# :s/^/#/<CR>:nohlsearch<CR>
vmap ,/ :s/^/\/\//<CR>:nohlsearch<CR>
vmap ,> :s/^/> /<CR>:nohlsearch<CR>
vmap ," :s/^/\"/<CR>:nohlsearch<CR>
vmap ,% :s/^/%/<CR>:nohlsearch<CR>
vmap ,! :s/^/!/<CR>:nohlsearch<CR>
vmap ,; :s/^/;/<CR>:nohlsearch<CR>
vmap ,- :s/^/--/<CR>:nohlsearch<CR>
vmap ,c :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>:nohlsearch<CR>

" wrapping comments
vmap ,* :s/^\(.*\)$/\/\* \1 \*\//<CR>:nohlsearch<CR>
vmap ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>:nohlsearch<CR>
vmap ,< :s/^\(.*\)$/<!-- \1 -->/<CR>:nohlsearch<CR>
vmap ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>:nohlsearch<CR>

" block comments
vmap ,b v`<I<CR><esc>k0i/*<ESC>`>j0i*/<CR><esc><ESC>
vmap ,h v`<I<CR><esc>k0i<!--<ESC>`>j0i--><CR><esc><ESC>

" ===================================================================
" Mapping of special keys - arrow keys and function keys.
" ===================================================================
" Buffer commands (split,move,delete) -
" this makes a little more easy to deal with buffers.
map <F6> :split<C-M>
map <F7> :vsp<C-M>

map <C-Down>  <C-w>j
map <C-Up>    <C-w>k
map <C-Left>  <C-w>h
map <C-Right> <C-w>l
map <C-j> <C-W>j<C-w>_
map <C-k> <C-W>k<C-w>_
map <C-h> <C-w>h<C-w>_
map <C-l> <C-w>l<C-w>_

" insert mode key mapping

" <Tab> is bound to `complete'
" inoremap <tab> <c-p>
"
" cycle fast through buffers ...
nnoremap <C-n> :bn<CR>
nnoremap <C-p> :bp<CR>
"
" cycle fast through errors ...
map <m-n> :cn<cr>
map <m-p> :cp<cr>

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

set list
set lcs=nbsp:_,tab:>_,trail:_,extends:>,precedes:<

" very magic
nnoremap / /\v
