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
    let color = '{ x = $1; $1 = ""; z = $3; $3 = ""; printf "\033[34m%s\033[0m:\033[31m%s\033[0m\011\033[37m%s\033[0m\n", x,z,$0; }'
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

