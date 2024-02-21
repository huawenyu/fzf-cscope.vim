if !exists("s:init")
    let s:init = 1
    silent! let s:log = logger#getLogger(expand('<sfile>:t'))


    " ($2 == "function" && $1 ~ env_ftxt)
    "            print file ":" lnum ":0:" color1(fname) ": " color2(arr[1]) "(" arr[3] ")";
    let s:color_tag_func =<< END
        | awk -v env_ftagText="$ftagText" -v env_ftagDir="$ftagDir" '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }

        BEGIN {}
        ($2 == "function" && "$1 $2" ~ env_ftagText && $4 ~ env_ftagDir) {

            $1 = $2 = "";
            lnum = $3; $3 = "";
            fname = basename($4);
            file = $4; $4 = "";

            tmp = match($0, /(\w+(\s+)?){2,}\([^!@#$+%^]+?\)/, arr);
            if (tmp)
                print file ":" lnum ":0:" color1(fname) ": " color2(arr[1]) "(" arr[3] ")";
            else
                print file ":" lnum ":0:" color1(fname) ": " color2($0);
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
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }

        BEGIN {}
        ($2 != "function" && $4 ~ env_ftxt) {

            $1 = $2 = "";
            lnum = $3; $3 = "";
            fname = basename($4);
            file = $4; $4 = "";

            tmp = match($0, /(\w+(\s+)?){2,}\([^!@#$+%^]+?\)/, arr);
            if (tmp)
                print file ":" lnum ":0:" color1(fname) ": " color2(arr[1]) "(" arr[3] ")";
            else
                print file ":" lnum ":0:" color1(fname) ": " color2($0);
        }
        END {}
        '
END

    "        # arr[1]  keywords
    "        # arr[2]  section
    "        # arr[3]  line number
    "        # arr[4]  file path
    let s:color_tag_markdown =<< END
        | awk -v env_ftxt="$ftxt" '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }

        BEGIN {}
        match($0, /(.*)\s+(chapter|section|subsecion)\s+([0-9]+)\s+(\S+)/, arr) {
            lnum = arr[3];
            fname = basename(arr[4]);
            file = arr[4];
            print file ":" lnum ":0:" color1(fname) ": " color2(arr[1]);
        }
        END {}
        '
END

    "        # arr[1]  file path
    "        # arr[2]  number
    "        # arr[3]  search pattern
    let s:color_tag_markdown2 =<< END
        | awk -F':' -v env_ftxt="$ftxt" '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }

        BEGIN {}
        {
            lnum = $2;
            fname = basename($1);
            file = $1;
            print file ":" lnum ":0:" color1(fname) ": " color2($3);
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


function! fzffilter#TagFilter(text, bang, mode)
    let __func__ = "fzffilter#TagFilter() "

    let tagfile = ''
    if a:mode == 'home-cache-tag'
        let tagList = [$HOME..'/.cache/tagx', $HOME..'/.cache/.tagx']
    else
        if exists('g:fuzzy_file_tag')
            let tagList = g:fuzzy_file_tag
        else
            let tagList = ["tagx", ".tagx"]
        endif
    endif

    for oneTag in tagList
        if filereadable(oneTag)
            let tagfile = oneTag
            break
        endif
    endfor

    if empty(tagfile)
        if exists(":Tags")
            Tags
        endif
        return
    endif

    let $ftagText = ' '
    if a:text
        let $ftagText = a:text
    endif
    let $ftagDir = '/'
    if a:mode == 'home-cache-tag'
        let cmdStr = 'cat '..tagfile..join(s:color_tag_markdown2)
    else
        if !empty(g:fzfCscopeFilter)
            let $ftagDir = g:fzfCscopeFilter
        endif

        if a:bang
            let cmdStr = 'cat '..tagfile..join(s:color_tag_no_func)
        else
            let cmdStr = 'cat '..tagfile..join(s:color_tag_func)
        endif
    endif

    silent! call s:log.info(__func__, "Text='"..$ftagText.."'", " Dir='"..$ftagDir.."'", " AWK", cmdStr)
    if !empty(cmdStr)
        call fzf#vim#grep(cmdStr,
                \   1,
                \   fzfpreview#p(1, { 'options': '--delimiter=: --with-nth=4..' }),
                \   1)
    else
        if exists(":Tags")
            Tags
        endif
        return
    endif
endfunction


function! fzffilter#_Function(type, sname, ...)
    Decho "fzffilter#_Function a:0=" . a:0

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

