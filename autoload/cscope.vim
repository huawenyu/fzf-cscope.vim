if !exists("s:init")
    let s:init = 1
    silent! let s:log = logger#getLogger(expand('<sfile>:t'))

    " echo "void render(SDL_Surface *screen)" | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
    " echo "render(SDL_Surface *screen)"      | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
    " echo "render(screen)"                   | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
    " echo "render()"                         | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'

    " echo "void render(SDL_Surface *screen)" | awk '/^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'
    " echo "render(SDL_Surface *screen)"      | awk '/^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'
    " echo "render(screen)"                   | awk '/^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'

    " echo "render(screen)"                   | awk '/^[a-zA-Z\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'
    " echo "void render(SDL_Surface *screen)" | awk '/^([_a-zA-Z])+?([ \*]+)*?\(/{print $0}'
    " echo "render(SDL_Surface *screen)"      | awk '/^([a-zA-Z\w\* ]){1,}\(([^!@#$+%^;]+?)\)(?!\s*;)/{print $0}'

    " echo "void render(SDL_Surface *screen)" | awk '/^(\w+( )?){2,}\([^!@#$+%^]+?\)/{print $0}'
    " echo "void render(SDL_Surface *screen)" | awk '/^([\w\*]+( )*?){2,}\([^!@#$+%^;]+?\)/{print $0}'
    " echo "void render(SDL_Surface *screen)" | awk '/^(\w+( )*?){2,}\([^!@#$+%^;]+?\)/{print $0}'

    " echo "void render(SDL_Surface *screen)" | awk '/([a-zA-Z]\w\*)\s+(\w+)\s*\([^\)]*\)\s*(;|{))/{print $0}'
    " echo "void render(SDL_Surface *screen)" | awk '/(?![a-z])[^\:,>,\.]([a-z,A-Z]+[_]*[a-z,A-Z]*)+[(]/{print $0}'

    " Check it: https://ideone.com/
    "\011  tab
    let s:color_cscope =<< END
        | awk '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        BEGIN {}
        {

            file   = $1; $1 = "";
            lnum   = $3; $3 = "";
            caller = $2; $2 = "";

            isFunc = 0;
            tmp = match($0, /(\w+( )?){2,}\([^!@#$+%^]+?[\),]/);
            if (tmp) {
                tmp = match($0, /;$/);
                if (! tmp) {
                    tmp=match($0, / = /);
                    if (! tmp)
                        isFunc = 1;
                }
            }

            if (isFunc)
                print color1(file) ":" color2(lnum) ":0: " color3(caller) color5($0);
            else
                print color1(file) ":" color2(lnum) ":0: " color3(caller) color4($0);
        }
        END {}
        '
END

    let s:color_tag_func =<< END
        | awk -v env_ftxt="$ftxt" '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        BEGIN {}
        ($2 == "function" && $1 ~ env_ftxt) {

            $1 = $2 = "";
            lnum = $3; $3 = "";
            file = $4; $4 = "";

            tmp = match($0, /(\w+( )?){2,}\(([^!@#$+%^]+)?\)/, arr);
            if (tmp)
                print file ":" color1(lnum) ":0:" color2(arr[1]) "(" arr[3] ")";
            else
                print file ":" color1(lnum) ":0:" color2($0);
        }
        END {}
        '
END

    let s:color_tag_no_func =<< END
        | awk -v env_ftxt="$ftxt" '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        BEGIN {}
        ($2 != "function" && $1 ~ env_ftxt) {

            $1 = $2 = "";
            lnum = $3; $3 = "";
            file = $4; $4 = "";

            tmp = match($0, /(\w+( )?){2,}\(([^!@#$+%^]+)?\)/, arr);
            if (tmp)
                print file ":" color1(lnum) ":0:" color2(arr[1]) "(" arr[3] ")";
            else
                print file ":" color1(lnum) ":0:" color2($0);
        }
        END {}
        '
END


    let s:color_fake_lnum =<< END
        | awk -v env_ftxt="$ftxt" '
        function color0(txt) { return "\033[30m" txt "\033[0m"; }
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        BEGIN {}
        ($1 ~ env_ftxt) {
            print color1($0) color0(":0:0:");
        }
        END {}
        '
END

endif


function! cscope#LoadCscope()
    let l:__func__ = "cscope#LoadCscope() "
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
    call fzf#vim#grep(
                \   'cscope -dL'..a:option..' '..a:query..join(s:color_cscope),
                \   1,
                \   fzfpreview#p(<bang>0),
                \   <bang>0)
endfunction


function! cscope#preview(option, query, preview)
    if a:query ==# 'n'
        silent! call s:log.info(__func__, " from nmap ", a:query)
        let query = utils#GetSelected('n')
    elseif a:query ==# 'v'
        silent! call s:log.info(__func__, " from vmap ", a:query)
        let query = utils#GetSelected('v')
    else
        silent! call s:log.info(__func__, " from N/A ", a:query)
        let query = a:query
    endif

    let char1st = strcharpart(query, 0, 1)
    if char1st !=# '"' && char1st !=# "'"
        let query = "'". query. "'"
    endif

    call fzf#vim#grep('cscope -dL'..a:option..' '..query..join(s:color_cscope),
                \   1,
                \   fzfpreview#p(a:preview),
                \   a:preview)
endfunction


function! cscope#preview_text(option, query, preview)
    call cscope#preview(a:o, a:query, a:preview)
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


function! cscope#FileFilter(args, bang)
    let __func__ = "cscope#File() "

    let $ftxt = a:args
    if !a:bang && filereadable("./.cscope.files")
        let cmdStr = "cat ./.cscope.files"..join(s:color_fake_lnum)
    elseif executable('rg')
        let cmdStr = 'rg --no-heading --files --color=never --fixed-strings'..join(s:color_fake_lnum)
    elseif executable('ag')
        let cmdStr = "ag -l --silent --nocolor -g '' "..join(s:color_fake_lnum)
    endif

    "silent! call s:log.info(__func__, cmdStr)
    if empty(cmdStr)
        Files
        return
    endif

    call fzf#vim#grep(cmdStr,
                \   1,
                \   fzfpreview#p(1),
                \   1)
endfunction


function! cscope#TagFilter(args, bang)
    let __func__ = "cscope#TagFilter() "

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
        Tags
        return
    endif

    " <bang>0 function, <bang>1 symbol
    if empty(a:args) && !empty(g:fzf_cscope_tag_filter)
        let $ftxt = g:fzf_cscope_tag_filter
    else
        let $ftxt = a:args
    endif

    if a:bang
        let cmdStr = 'cat '..tagfile..join(s:color_tag_no_func)
    else
        let cmdStr = 'cat '..tagfile..join(s:color_tag_func)
    endif

    "silent! call s:log.info(__func__, cmdStr)
    if !empty(cmdStr)
        call fzf#vim#grep(cmdStr,
                \   1,
                \   fzfpreview#p(1, { 'options': '--delimiter=: --with-nth=4..' }),
                \   1)
    else
        Tags
        return
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
        return "FindFunc ".utils#GetSelected('v')." "
    else
        return "FindFunc ".expand('<cword>')." "
    endif
endfunction

function! cscope#FindVar(sel)
    if a:sel
        return "FindVar ".utils#GetSelected('v')." "
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

