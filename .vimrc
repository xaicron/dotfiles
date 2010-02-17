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

"ペースト
set paste

set tabstop=4
"タブを空白に置き換える
set expandtab
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start

" 全角スペースの表示
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
match ZenkakuSpace /　/

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

"psgiにperl syntaxを適用
:au BufEnter *.psgi execute ":setlocal filetype=perl"

"TT用syntax
:au BufEnter *.tt,*.cfm execute ":setlocal filetype=html"

"辞書ファイルを使用する設定に変更
set complete+=k

"Vroom
set exrc

"バッファを開いた時に、カレントディレクトリを自動で移動
:au BufEnter *.pl,*.pm,*.cgi,*.yaml,*.json execute ":lcd " . expand("%:p:h")

noremap  
noremap!  

"reset highlight
nmap  :nohlsearch<CR>

":w + !perl command
map <F4>  :w !perl<CR>
"!perl command
map <F5>  :!perl %<CR>

"lhs comments
map ,# :s/^/#/<CR>
map ,/ :s/^/\/\//<CR>
map ,> :s/^/> /<CR>
map ," :s/^/\"/<CR>
map ,% :s/^/%/<CR>
map ,! :s/^/!/<CR>
map ,; :s/^/;/<CR>
map ,- :s/^/--/<CR>
map ,c :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>

"wrapping comments
map ,* :s/^\(.*\)$/\/\* \1 \*\//<CR>
map ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>
map ,< :s/^\(.*\)$/<!-- \1 -->/<CR>
map ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>



" ===================================================================
" Mapping of special keys - arrow keys and function keys.
" ===================================================================
" Buffer commands (split,move,delete) -
" this makes a little more easy to deal with buffers.
map <F6>  :split<C-M>
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


" ===================================================================
" Word dictionary & Comment Usefull function keys.
" ===================================================================
" Insert mode commands( user dictionary words ) -
iab === # =========================================================================
iab --- # -------------------------------------------------------------------------

" Template Toolkit用
iab TS    [% %]
iab Ts    [% etc %]
iab TI    [% INCLUDE "" %]
iab TIF   [% IF %][% END %]
iab TIFE  [% ELSIF %]
iab TIFEL [% ELSE %]
iab TF    [% FOREACH %][% END %]
iab TW    [% WHILE %][% END %]
iab TS    [% SWITCH %][% CASE %][% END %]

iab Cmyself my ($self, $c) = @_;
iab Cdebug $c->log->debug(
iab Cinfo $c->log->info(
iab Cwarn $c->log->warn(
iab Cthrow Catalyst::Exception->throw(
iab YDT <C-R>=strftime("%Y-%m-%d %T")<CR>
iab PSIMPLE <ESC>:r ~/.vim/tmpl/perl_simple.pl<CR>
iab PMODULE <ESC>:r ~/.vim/tmpl/perl_module.pl<CR>
iab PSUB    <ESC>:r ~/.vim/tmpl/perl_sub.pl<CR>
iab PHREF   $hash_name->{namae}
iab PFOREACH    foreach my $element (@nanigasi){
iab PFOR        for ( my $i=1; $i <= 100; $i++ ){
iab PRINT       print $i, "\n";
iab HSIMPLE <ESC>:r ~/.vim/tmpl/xhtml_simple.html<CR>
iab XSIMPLE <ESC>:r ~/.vim/tmpl/xml_simple.xml<CR>
iab LSIMPLE <ESC>:r ~/.vim/tmpl/lisp_simple.lisp<CR>
iab UA_IE Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)
iab UA_FX Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.8.0.4) Gecko/20060508 Firefox/1.5.0.4
iab MIME_POST application/x-www-form-urlencoded
iab MIME_JSON application/json
iab authe authentication
iab autho authorization
iab passw password
iab javasc javascript
iab concate concatenate

ab Dec December
ab dec december
ab Feb February
ab feb february
ab Fri Friday
ab fri friday
ab Jan January
ab jan january
ab Mon Monday
ab mon monday
ab nite night
ab Nov November
ab nov november
ab Oct October
ab oct october
ab Sat Saturday
ab Sep September
ab sep september
ab tho though
ab thru through
ab Thu Thursday
ab thu thursday
ab thur thursday
ab tonite tonight
ab Tue Tuesday
ab tue tuesday
ab Wed Wednesday
ab wed wednesday

