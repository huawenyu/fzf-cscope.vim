if !exists("s:init")
    let s:init = 1
    silent! let s:log = logger#getLogger(expand('<sfile>:t'))

    if 0
        echo "void render(SDL_Surface *screen)" | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
        echo "render(SDL_Surface *screen)"      | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
        echo "render(screen)"                   | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
        echo "render()"                         | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'

        echo "void render(SDL_Surface *screen)" | awk '/^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'
        echo "render(SDL_Surface *screen)"      | awk '/^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'
        echo "render(screen)"                   | awk '/^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'

        echo "render(screen)"                   | awk '/^[a-zA-Z\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'
        echo "void render(SDL_Surface *screen)" | awk '/^([_a-zA-Z])+?([ \*]+)*?\(/{print $0}'
        echo "render(SDL_Surface *screen)"      | awk '/^([a-zA-Z\w\* ]){1,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'

        echo "void render(SDL_Surface *screen)" | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
        echo "void render(SDL_Surface *screen)" | awk '/^([\w\*]+( )*?){2,}\([^!@#$+%^;]+?\)/{print $0}'
        echo "void render(SDL_Surface *screen)" | awk '/^(\w+( )*?){2,}\([^!@#$+%^;]+?\)/{print $0}'

        echo "void render(SDL_Surface *screen)" | awk '/([a-zA-Z]\w\*)\s+(\w+)\s*\([^\)]*\)\s*(;|{))/{print $0}'
        echo "void render(SDL_Surface *screen)" | awk '/(?![a-z])[^\:,>,\.]([a-z,A-Z]+[_]*[a-z,A-Z]*)+[(]/{print $0}'
    endif

    let s:color_cscope = '{file=$1;$1 =""; lnum=$3;$3=""; caller=$2;$2="";'
                \.'isFuncDefine=0;'
                \.'tmp=match($0, /(\w+( )?){2,}\([^!@#$+%^]+?\)/); if (tmp) isFuncDefine=1;'
                \.'if(isFuncDefine) {tmp=match($0, /;$/); if (tmp) isFuncDefine=0;}'
                \.'if(isFuncDefine) {tmp=match($0, / = /); if (tmp) isFuncDefine=0;}'
                \.'if(isFuncDefine) {printf "\033[34m%s\033[0m:\033[35m%s:0\033[0m\011\033[32m%s()\033[0m\011\033[33m%s\033[0m\n",'
                \.                          ' file,lnum,caller,$0; }'
                \.'else    {printf "\033[34m%s\033[0m:\033[35m%s:0\033[0m\011\033[32m%s()\033[0m\011\033[37m%s\033[0m\n",'
                \.                          ' file,lnum,caller,$0; }'
                \.'}'

    let s:color_tag = '{$1=$2=""; lnum=$3;$3=""; file=$4;$4="";'
                \.'tmp=match($0, /(\w+( )?){2,}\(([^!@#$+%^]+)?\)/, arr);'
                \.'if(tmp) {printf "%s\033[30m:%s:0\033[0m\033[33m%s\033[0m(%s)\n",'
                \.    ' file,lnum,arr[1],arr[3]; }'
                \.'else {printf "%s\033[30m:%s:0\033[0m\033[33m%s\033[0m\n",'
                \.    ' file,lnum,$0; }'
                \.'}'

    let s:color_fake_lnum = '{ printf "%s\033[30m:0:0\033[0m\n", $0; }'
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

    let opts = {
                \ 'source':  "cscope -dL" . a:option . " " . a:query . " | awk '" . s:color_cscope . "'",
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

    let cmdStr = "cscope -dL" . a:option . " " . a:query . " | awk '" . s:color_cscope . "'"
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
    let __func__ = "cscope#FileCat() "

    if !CheckPlug('fzf.vim', 1)
        return
    endif

    let cmdStr = ""
    if !a:bang && filereadable("./.cscope.files")
        let cmdStr = "awk '($1~/". a:args . "/)". s:color_fake_lnum. "' ./.cscope.files"
    elseif executable('rg')
        let cmdStr = 'rg --no-heading --files --color=never --fixed-strings'. "| awk '($1~/". a:args . "/)". s:color_fake_lnum. "' "
    elseif executable('ag')
        let cmdStr = "ag -l --silent --nocolor -g '' ". "| awk '($1~/". a:args . "/)". s:color_fake_lnum. "' "
    endif

    "silent! call s:log.info(__func__, cmdStr)
    if empty(cmdStr)
        Files
        return
    endif

    call fzf#vim#grep(
                \   cmdStr, 1,
                \   a:preview ? fzf#vim#with_preview('up:60%')
                \           : fzf#vim#with_preview('right:50%:hidden', '?'),
                \   a:preview)
endfunction


function! cscope#TagCat(mode, args, bang, preview)
    let __func__ = "cscope#TagCat() "

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
        let cmdStr = "awk '($2 != \"function\" && $1~/". a:args. "/)". s:color_tag. "' ". tagfile
    else
        let cmdStr = "awk '($2 == \"function\" && $1~/". a:args. "/)". s:color_tag. "' ". tagfile
    endif

    "silent! call s:log.info(__func__, cmdStr)
    if !empty(cmdStr)
        call fzf#vim#grep(
                    \   cmdStr, 0,
                    \   a:preview ? fzf#vim#with_preview('up:60%')
                    \          : fzf#vim#with_preview('right:50%:hidden', '?'),
                    \   a:preview)

        "call fzf#run({
        "            \ 'source': cmdStr,
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

