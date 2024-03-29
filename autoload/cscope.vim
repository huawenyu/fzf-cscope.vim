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

    " Troubleshooting:
    " Check it: https://ideone.com/
    " function match: https://stackoverflow.com/questions/476173/regex-to-pull-out-c-function-prototype-declarations
    " color: https://stackoverflow.com/questions/14482101/awk-adding-color-code-to-text
    "       ["None"]    = 0;
    "       ["Black"]   = 30;
    "       ["Red"]     = 31;
    "       ["Green"]   = 32;
    "       ["Yellow"]  = 33;
    "       ["Blue"]    = 34;
    "       ["Magenta"] = 35;
    "       ["Cyan"]    = 36;
    "       ["White"]   = 37;
    " cscope -dL0 <word> | awk
    "\011  tab
    let s:color_cscope =<< END
        | awk -v env_ftxt="$ftxt" '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        BEGIN {}
        ($1 ~ env_ftxt) {

            file   = $1; $1 = "";
            lnum   = $3; $3 = "";
            caller = $2; $2 = "";

            isFunc = 0;
            tmp = match($0, /(\w+(\s+)?){2,}\([^!@#$+%^]+?\)/);
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


function! cscope#run(option, query, bang)
    call fzf#vim#grep(
                \   'cscope -dL'..a:option..' '..a:query..join(s:color_cscope),
                \   1,
                \   fzfpreview#p(a:bang),
                \   a:bang)
endfunction


function! cscope#preview(option, mode, isfunc, filter)
    let query = hw#misc#GetWord(a:mode)
    if len(query) > 0
        if a:mode ==# 'n'
            let char1st = strcharpart(query, 0, 1)
            if char1st !=# '"' && char1st !=# "'"
                let query = "'". query. "'"
            endif
        else
            call inputsave()
            let char1st = strcharpart(query, 0, 1)
            if char1st !=# '"' && char1st !=# "'"
                let query = "'". query. ".*'"
            endif
            let query = input({'prompt':'Cscope: ', 'default': query, 'cancelreturn': ''})
            call inputrestore()

            if len(query) == 0 | return | endif
        endif

        " Suppose the path it's unix/linux path style
        " let $ftxt = hw#misc#GetWord(a:mode)
        if a:filter
            " g:fzfCscopeFilter
            let $ftxt = get(g:, 'fzfCscopeFilter', '/')
        else
            let $ftxt = '/'
        endif

        "" Debug
        "call fzf#run({ 'source': 'ls' })
        "call fzf#run({ 'source': 'cscope -dL0 vd_secure_reload_timer'..join(s:color_cscope) })
        "call fzf#run(fzf#wrap({ 'source': 'ls' }))
        "call fzf#run(fzf#vim#with_preview(fzf#wrap({ 'source': 'ls' })))

        "" See how these decorators "decorate" (or "extend") the dictionary
        "echo fzf#wrap({ 'source': 'ls' })
        "echo fzf#vim#with_preview(fzf#wrap({ 'source': 'ls' }))

        call fzf#vim#grep('cscope -dL'..a:option..' '..query..join(s:color_cscope),
                    \   1,
                    \   fzfpreview#p(1),
                    \   1)
    else
        call fzffilter#TagFilter(a:isfunc, a:mode, a:filter)
    endif
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
        call cscope#run(a:option, query, 1)
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

