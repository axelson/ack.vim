" NOTE: You must, of course, install the ack script
"       in your path.
" On Debian / Ubuntu:
"   sudo apt-get install ack-grep
" On your vimrc:
"   let g:ackprg="ack-grep -H --nocolor --nogroup --column"
"
" With MacPorts:
"   sudo port install p5-app-ack

" Location of the ack utility
if !exists("g:ackprg")
	let g:ackprg="ack -H --nocolor --nogroup --column"
endif

" Height of quickfix window to open
if !exists("g:ackWinHeight")
	let g:ackWinHeight=20
endif

function! s:Ack(cmd, args)
    redraw
    echo "Searching ..."

    " Format, used to manage column jump
    if a:cmd =~# '-g$'
        let g:ackformat="%f"
    else
        let g:ackformat="%f:%l:%c:%m"
    end

    let grepprg_bak=&grepprg
    let grepformat_bak=&grepformat
    try
        let &grepprg=g:ackprg
        let &grepformat=g:ackformat
        silent execute a:cmd . " " . a:args
    finally
        let &grepprg=grepprg_bak
        let &grepformat=grepformat_bak
    endtry

    if a:cmd =~# '^l'
        execute "botright lopen " . g:ackWinHeight
    else
        execute "botright copen " . g:ackWinHeight
    endif

    exec "nnoremap <silent> <buffer> q :ccl<CR>" 

    " If highlighting is on, highlight the search keyword.
    if exists("g:ackhighlight")
        let @/=a:args
        set hlsearch
    end

    redraw!
endfunction

function! s:AckFromSearch(cmd, args)
    let search =  getreg('/')
    " translate vim regular expression to perl regular expression.
    let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
    call s:Ack(a:cmd, '"' .  search .'" '. a:args)
endfunction

command! -bang -nargs=* -complete=file Ack call s:Ack('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file AckAdd call s:Ack('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFromSearch call s:AckFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAck call s:Ack('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAckAdd call s:Ack('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFile call s:Ack('grep<bang> -g', <q-args>)
