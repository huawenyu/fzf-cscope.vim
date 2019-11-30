if !exists("s:init")
    let s:init = 1
    silent! let s:log = logger#getLogger(expand('<sfile>:t'))
endif


function! cscope#LoadCscope()
    if exists("s:cscope_db_loaded") && s:cscope_db_loaded
        return
    endif

    set nocscopeverbose " suppress 'duplicate connection' error

    " add any database in current directory
    if filereadable("cscope.out")
        let s:cscope_db_loaded = 1
        silent cs add cscope.out
    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        let s:cscope_db_loaded = 1
        silent cs add $CSCOPE_DB
    else
        " Searches from the directory of the current file upwards until root '/'
        let db = findfile("cscope.out", ".;")
        if (!empty(db))
            let s:cscope_db_loaded = 1
            let path = strpart(db, 0, match(db, "/cscope.out$"))
            exec "cs add " . db . " " . path
        endif
    endif

    set cscopeverbose
endfunction

function! cscope#ReLoadCscope()
    if s:cscope_db_loaded
        silent! cs reset
        redraw
    endif

    call cscope#LoadCscope()
endfunction


function! cscope#run(option, query)
    if !CheckPlug('fzf.vim', 1) | return | endif

    "int func(struct s1 *, void *ctx,
    let color = '{file=$1;$1 =""; lnum=$3;$3=""; caller=$2;$2="";'
                \.'isDefine=0;'
                \.'if(!isDefine) {tmp=match($0, /;$/); if (tmp) isDefine=1;}'
                \.'if(isDefine) {printf "\033[34m%s\033[0m:\033[35m%s:0\033[0m\011\033[32m%s()\033[0m\011\033[37m%s\033[0m\n",'
                \.'     file,lnum,caller,$0; }'
                \.'else    {printf "\033[34m%s\033[0m:\033[35m%s:0\033[0m\011\033[32m%s()\033[0m\011\033[33m%s\033[0m\n",'
                \.'     file,lnum,caller,$0; }'
                \.'}'
    let opts = {
                \ 'source':  "cscope -dL" . a:option . " " . a:query . " | awk '" . color . "'",
                \ 'options': ['--ansi', '--prompt', '> ',
                \             '--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
                \             '--color', 'fg:188,fg+:222,bg+:#3a3a3a,hl+:104'],
                \ 'down': '40%'
                \ }
    function! opts.sink(lines) 
        let data = split(a:lines)
        let file = split(data[0], ":")
        execute 'e ' . '+' . file[1] . ' ' . file[0]
    endfunction

    call fzf#run(opts)
endfunction


function! cscope#preview(option, query, preview)
    let __func__ = "cscope#preview() "

    if !CheckPlug('fzf.vim', 1) | return | endif

    let color = '{file=$1;$1 =""; lnum=$3;$3=""; caller=$2;$2="";'
                \.'isDefine=0;'
                \.'if(!isDefine) {tmp=match($0, /;$/); if (tmp) isDefine=1;}'
                \.'if(isDefine) {printf "\033[34m%s\033[0m:\033[35m%s:0\033[0m\011\033[32m%s()\033[0m\011\033[37m%s\033[0m\n",'
                \.'     file,lnum,caller,$0; }'
                \.'else    {printf "\033[34m%s\033[0m:\033[35m%s:0\033[0m\011\033[32m%s()\033[0m\011\033[33m%s\033[0m\n",'
                \.'     file,lnum,caller,$0; }'
                \.'}'
    let cmdStr = "cscope -dL" . a:option . " " . a:query . " | awk '" . color . "'"
    "silent! call s:log.info(__func__, cmdStr)

    call fzf#vim#grep(
                \   cmdStr, 0,
                \   a:preview ? fzf#vim#with_preview('up:60%')
                \           : fzf#vim#with_preview('right:50%:hidden', '?'),
                \   a:preview)
endfunction


function! cscope#Query(option)
    call inputsave()
    if a:option == '0'
        let query = input('Assignments to: ')
    elseif a:option == '1'
        let query = input('Functions calling: ')
    elseif a:option == '2'
        let query = input('Functions called by: ')
    elseif a:option == '3'
        let query = input('Egrep: ')
    elseif a:option == '4'
        let query = input('File: ')
    elseif a:option == '6'
        let query = input('Definition: ')
    elseif a:option == '7'
        let query = input('Files #including: ')
    elseif a:option == '8'
        let query = input('C Symbol: ')
    elseif a:option == '9'
        let query = input('Text: ')
    else
        echo "Invalid option!"
        return
    endif
    call inputrestore()
    if query != ""
        call cscope#run(a:option, query)
    else
        echom "Cancelled Search!"
    endif
endfunction


function! cscope#FileCat(mode, args, bang, preview)
    if !CheckPlug('fzf.vim', 1)
        return
    endif
    let fake_lnum = '{ printf "%s:\033[30m0:0:0\033[0m\n", $0,0,0,0; }'

    let command = ""
    if !a:bang && filereadable("./.cscope.files")
        let command = "awk '($1~/". a:args . "/)". fake_lnum. "' ./.cscope.files"
    elseif executable('rg')
        let command = 'rg --no-heading --files --color=never --fixed-strings'. "| awk '($1~/". a:args . "/){print $0\":\033[30m0:0:0\033[0m\"}' "
    elseif executable('ag')
        let command = "ag -l --silent --nocolor -g '' ". "| awk '($1~/". a:args . "/) {print $0\":\033[30m0:0:0\033[0m\"}' "
    endif

    if empty(command)
        Files
        return
    endif

    call fzf#vim#grep(
                \   command, 1,
                \   a:preview ? fzf#vim#with_preview('up:60%')
                \           : fzf#vim#with_preview('right:50%:hidden', '?'),
                \   a:preview)
endfunction


function! cscope#TagCat(mode, args, bang, preview)
    if !CheckPlug('fzf.vim', 1)
        return
    endif

    let tagfile = ''
    if !exists('g:fuzzy_file_tag')
        let g:fuzzy_file_tag = ["tagx", ".tagx"]
    endif
    for i in g:fuzzy_file_tag
        if filereadable(i)
            let tagfile = i
            break
        endif
    endfor

    if empty(tagfile)
        echomsg "tagx file not exist!"
        return
    endif

    " <bang>0 function, <bang>1 symbol
    if a:bang
        let command = "awk '($2 != \"function\" && $1~/". a:args. "/) {$1=$2=\"\"; print $4\"\033[30m:\"$3\":\033[0m\033[32m\"$5\" \"$6\" \"$7\" \033[0m\"$8}' ". tagfile
    else
        let command = "awk '($2 == \"function\" && $1~/". a:args. "/) {$1=$2=\"\"; print $4\"\033[30m:\"$3\":\033[0m\033[32m\"$5\" \"$6\" \"$7\" \033[0m\"$8}' ". tagfile
    endif

    if !empty(command)
        call fzf#vim#grep(
                    \   command, 0,
                    \   a:preview ? fzf#vim#with_preview('up:60%')
                    \          : fzf#vim#with_preview('right:50%:hidden', '?'),
                    \   a:preview)

        "call fzf#run({
        "            \ 'source': command,
        "            \ 'sink':   'e',
        "            \ 'options': '-m -x +s',
        "            \ 'window':  'enew' })
    endif
endfunction


" list symbol
function! cscope#Symbol()
    let l:old_cscopeflag = &cscopequickfix
    set cscopequickfix=s-,c0,d0,i0,t-,e-

    exec ':cs find s ' . expand("<cword>")
    let w_qf = genutils#GetQuickfixWinnr()
    if w_qf == 0
        call genutils#MarkActiveWindow()
        copen
        call genutils#RestoreActiveWindow()
    endif

    let &cscopequickfix = l:old_cscopeflag
endfunction

function! cscope#FindFunc(sel)
    if a:sel
        return "FindFunc ".utils#GetSelected("")." "
    else
        return "FindFunc ".expand('<cword>')." "
    endif
endfunction

function! cscope#FindVar(sel)
    if a:sel
        return "FindVar ".utils#GetSelected("")." "
    else
        return "FindVar ".expand('<cword>')." "
    endif
endfunction

function! cscope#_Function(type, sname, ...)
    Decho "scope#_Function a:0=" . a:0

    if a:0 > 0
        let cmd_str = ":silent !taglist.awk ".a:type." ".a:sname." ".a:1
    else
        let cmd_str = ":silent !taglist.awk ".a:type." ".a:sname
    endif

    Decho cmd_str
    execute cmd_str

    execute ':redraw!'
    if filereadable('/tmp/vim.taglist')
        let lines = readfile('/tmp/vim.taglist')
        if !empty(lines)
            execute ':cgetfile /tmp/vim.taglist'
        endif
    endif
endfunction

