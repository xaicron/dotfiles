"=============================================================================
" File: pureirc.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: 28-Jan-2010.
" Version: 0.1
" WebPage: http://github.com/mattn/pureirc-vim
" Usage:
"
"   1. Open terminal window and start vim
"   3. Open new termianl and start vim
"   2. Type following on one of vim
"        :IrcServer #vim mynick
"   4. Type following on another vim
"        :Irc hello!
"

let g:pureirc_vim_version = "0.1"
if &compatible
  finish
endif

if !executable('curl')
  echoerr "PureIRC: require 'curl' command"
  finish
endif

function! s:nr2byte(nr)
  if a:nr < 0x80
    return nr2char(a:nr)
  elseif a:nr < 0x800
    return nr2char(a:nr/64+192).nr2char(a:nr%64+128)
  else
    return nr2char(a:nr/4096%16+224).nr2char(a:nr/64%64+128).nr2char(a:nr%64+128)
  endif
endfunction

function! s:nr2enc_char(charcode)
  if &encoding == 'utf-8'
    return nr2char(a:charcode)
  endif
  let char = s:nr2byte(a:charcode)
  if strlen(char) > 1
    let char = strtrans(iconv(char, 'utf-8', &encoding))
  endif
  return char
endfunction

function! s:nr2hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunction

function! s:encodeURIComponent(instr)
  let instr = iconv(a:instr, &enc, "utf-8")
  let len = strlen(instr)
  let i = 0
  let outstr = ''
  while i < len
    let ch = instr[i]
    if ch =~# '[0-9A-Za-z-._~!''()*]'
      let outstr = outstr . ch
    elseif ch == ' '
      let outstr = outstr . '+'
    else
      let outstr = outstr . '%' . substitute('0' . s:nr2hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
    endif
    let i = i + 1
  endwhile
  return outstr
endfunction

function! s:item2query(items, sep)
  let ret = ''
  if type(a:items) == 4
    for key in keys(a:items)
      if strlen(ret) | let ret .= a:sep | endif
      let ret .= key . "=" . s:encodeURIComponent(a:items[key])
    endfor
  elseif type(a:items) == 3
    for item in a:items
      if strlen(ret) | let ret .= a:sep | endif
      let ret .= item
    endfor
  else
    let ret = a:items
  endif
  return ret
endfunction

function! s:do_http(url, getdata, postdata, cookie, returnheader)
  let url = a:url
  let getdata = s:item2query(a:getdata, '&')
  let postdata = s:item2query(a:postdata, '&')
  let cookie = s:item2query(a:cookie, '; ')
  if strlen(getdata)
    let url .= "?" . getdata
  endif
  let command = "curl -s -k"
  if a:returnheader
    let command .= " -i"
  endif
  if strlen(cookie)
    let command .= " -H \"Cookie: " . cookie . "\""
  endif
  let command .= " \"" . url . "\""
  if strlen(postdata)
    let file = tempname()
    exec 'redir! > '.file
    silent echo postdata
    redir END
    let quote = &shellxquote == '"' ?  "'" : '"'
    let res = system(command . " -d @" . quote.file.quote)
    call delete(file)
  else
    let res = system(command)
  endif
  return res
endfunction

function! s:get_json(url, param)
  let str = s:do_http(a:url, {}, a:param, {}, 0)
  let str = iconv(str, "utf-8", &encoding)
  let str = substitute(str, '\\u\(\x\x\x\x\)', '\=s:nr2enc_char("0x".submatch(1))', 'g')
  let l:true = 1
  let l:false = 0
  return eval(str)
endfunction

function! IrcRecvNotify(ctx, nick, msg)
  let s:IrcCtx = a:ctx
  let winnr = bufwinnr("__PUREIRC__")
  if winnr > 0
    if winnr != winnr()
      execute winnr.'wincmd w'
    endif
	let oldlazyredraw = &lazyredraw
    set lazyredraw
	if len(a:nick)
      call append(line('$'), "<@".a:nick.">: ".a:msg)
    else
      call append(line('$'), "# ".a:msg)
    endif
    call cursor(line('$'), 0)
    redraw!
    "execute 'wincmd w'
	let &lazyredraw = oldlazyredraw
  endif
  return 1
endfunction

function! IrcSendNotify(ctx, nick, msg)
  let list = serverlist()
  for s in split(list)
    try
      call remote_expr(s, "IrcRecvNotify(".string(a:ctx).",".string(a:nick).",".string(a:msg).")")
    catch /^Vim\%((\a\+)\)\=:E449/
    endtry
  endfor
endfunction

function! IrcSendMessage(msg)
  let winnr = bufwinnr("__PUREIRC__")
  if winnr == -1
    silent! edit __PUREIRC__
    setlocal buftype=nofile bufhidden=hide noswapfile wrap ft= nonumber modifiable
    syntax match SpecialKey /^<\(@[^>]\+\)>/
  endif
  if exists("s:IrcCtx") && len(a:msg)
    call s:get_json("http://webchat.freenode.net/e/p", {"s" : s:IrcCtx['s'], "c" : "PRIVMSG ".s:IrcCtx['r']." :".a:msg})
	call IrcRecvNotify(s:IrcCtx, s:IrcCtx['n'], a:msg)
  endif
endfunction

function! IrcServer(room, nick)
  let nick = a:nick
  while 1
    silent! unlet sids
    silent! unlet sid
    silent! unlet j
    silent! unlet i
    let sids = s:get_json("http://webchat.freenode.net/e/n", {"nick" : nick})
	let sid = sids[1]
    let j = s:get_json("http://webchat.freenode.net/e/s", {"s" : sid})
    for i in j
      if i[0] != "c"
        continue
      endif
      call IrcSendNotify({'s' : sid, 'r' : '', 'n' : ''}, '', string(i[3][1]))
      if i[1] == "433"
        let nick = nick . "_"
        break
      endif
      if i[1] == "376"
        let j = []
        break
      endif
    endfor
    if len(j) == 0
      break
    endif
  endwhile
  call s:get_json("http://webchat.freenode.net/e/p", {"s" : sid, "c" : "JOIN ".a:room})
  while 1
    silent! unlet j
    silent! unlet i
    let j = s:get_json("http://webchat.freenode.net/e/s", {"s" : sid})
    for i in j
      if i[0] != "c"
        continue
      endif
	  if type(i[3]) == 3 && len(i[3]) > 1
        call IrcSendNotify({'s' : sid, 'r' : a:room, 'n' : nick}, substitute(i[2], '!.*', '', ''), string(i[3][1]))
      endif
    endfor
  endwhile
endfunction

command! -nargs=+ IrcServer call IrcServer(<f-args>)
command! -nargs=* Irc call IrcSendMessage(<q-args>)
