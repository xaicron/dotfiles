if has('gui_macvim')
    set showtabline=2
    set imdisable
    set antialias
    set guifont=Monaco:h14
    colorscheme macvim
endif

if has('gui_running')
    set fuoptions=maxvert,maxhorz
    au GUIEnter * set fullscreen
endif

"行番号を非表示
set number
"括弧入力時に対応する括弧を表示
set showmatch
"コマンドをステータス行に表示
set showcmd
"タイトルを表示
set title
"常にステータス行を表示
set laststatus=2

"if(){}などのインデント
set cindent

"ルーラーを表示
set ruler
set ignorecase

"検索に大文字を含んでいたら大小区別
set smartcase
"検索時にヒット部位の色を変更
set hlsearch
"検索時にインクリメンタルサーチを行う
set incsearch
set showmode

"コマンドラインの履歴の保存数
set history=1024
"インデント
set autoindent
set smartindent
set smarttab

"置換に正規表現を使えるようにする
set magic

"ペースト
"set paste

set tabstop=4
"タブを空白に置き換える
set expandtab
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start

" バックアップディレクトリを変更
set backup
set backupdir=$HOME/.vim-backup
let &directory = &backupdir

" 全角スペースとタブの表示
highlight WhiteSpace cterm=underline ctermfg=lightblue guibg=darkgray
match WhiteSpace /[	　]/

" syntax
filetype plugin on
filetype indent on
syntax on

"ヘルプファイル
helptags $HOME/.vim/doc

"ファイルタイプ別辞書ファイル
"autocmd FileType c,cpp,perl set cindent
autocmd FileType ruby :set dictionary=~/.vim/plugin/ruby.vim
autocmd FileType perl :set dictionary+=~/.vim/dict/perl_function.dict
autocmd FileType perl :compiler perl

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

" syntax
:au BufEnter *.t,*.psgi,*.perl execute ":setlocal filetype=perl"
:au BufEnter *.tt,*.cfm execute ":setlocal filetype=html"
:au BufEnter *.sql execute ":setlocal filetype=mysql"

"辞書ファイルを使用する設定に変更
set complete+=k
set complete-=i

"Vroom
set exrc

"バッファを開いた時に、カレントディレクトリを自動で移動
":au BufEnter *.pl,*.pm,*.cgi,*.yaml,*.json,*.psgi execute ":lcd " . expand("%:p:h")

noremap  
noremap!  

"reset highlight
nmap  :nohlsearch<CR>

":w + !perl command
map <F4>  :w !perl -Ilib<CR>
"!perl command
map <F5>  :!perl -Ilib %<CR>

"全選択
map <F8> ggVG

"paste from clipboard
if has('mac') && !has('gui')
    nmap <S-p> :r !pbpaste<CR>
    vmap <S-p> :r !pbpaste<CR>
    nmap <S-y> :w !pbcopy<CR>
    vmap <S-y> :w !pbcopy<CR>
elseif has('unix') && !has('gui')
    nmap <Space>p :set paste<CR>:r !xsel -o -b<CR>:set nopaste<CR>
endif

"lhs comments
map ,# :s/^/#/<CR>
map ,/ :s/^/\/\//<CR>
map ,> :s/^/> /<CR>
map ," :s/^/\"/<CR>
map ,% :s/^/%/<CR>
map ,! :s/^/!/<CR>
map ,; :s/^/;/<CR>
map ,- :s/^/--/<CR>
map ,c :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>

"wrapping comments
map ,* :s/^\(.*\)$/\/\* \1 \*\//<CR>
map ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>
map ,< :s/^\(.*\)$/<!-- \1 -->/<CR>
map ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>



" ===================================================================
" Mapping of special keys - arrow keys and function keys.
" ===================================================================
" Buffer commands (split,move,delete) -
" this makes a little more easy to deal with buffers.
map <F6> :split<C-M>
map <F7> :vsp<C-M>
"map <F6>  :bp<C-M>
"map <F7>  :bn<C-M>
"map <F8> :bd<C-M>

map <C-Down>  <C-w>j
map <C-Up>    <C-w>k
map <C-Left>  <C-w>h
map <C-Right> <C-w>l
map <C-j> <C-W>j<C-w>_
map <C-k> <C-W>k<C-w>_
map <C-h> <C-w>h<C-w>_
map <C-l> <C-w>l<C-w>_

"insert mode key mapping

" <Tab> is bound to `complete'
"inoremap <tab> <c-p>
" 
" cycle fast through buffers ...
nnoremap <C-n> :bn<CR>
nnoremap <C-p> :bp<CR>
"
" cycle fast through errors ...
map <m-n> :cn<cr>
map <m-p> :cp<cr>

"if filereadable(expand('~/.vim/source/auto_encoding'))
"    source ~/.vim/source/auto_encoding
"endif

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

