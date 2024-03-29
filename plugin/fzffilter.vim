if exists('g:loaded_hw_fzffilter') || &compatible
    finish
endif
let g:loaded_hw_fzffilter = 1


let g:vim_confi_option = get(g:, 'vim_confi_option', {})
let g:vim_confi_option.tmp_file = get(g:vim_confi_option, 'tmp_file', '/tmp/vim.tmp')


" tldr wiki search
let g:vim_confi_option.tldr_dirs = []
if executable('tldr') && !empty($TLDR_PAGES_SOURCE_LOCATION)
    let s:tldr_dirs = split($TLDR_PAGES_SOURCE_LOCATION, ';')
    let s:file_pre = 'file://'
    for aDir in s:tldr_dirs
        let aDir = expand(trim(aDir))
        if aDir[0:len(s:file_pre)-1] ==# s:file_pre
            let aDir = aDir[len(s:file_pre):]
            if isdirectory(aDir)
                call add(g:vim_confi_option.tldr_dirs, aDir)
            endif
        endif
    endfor
    unlet s:tldr_dirs
    unlet s:file_pre
endif

if len(g:vim_confi_option.tldr_dirs) > 0
    let s:grep_prettier =<< END
        | awk -F: '
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        function path3(file) {
            return gensub(/.*\/([^\/]*)\/([^\/]*)\/([^\/]*)$/, "\\1/\\2/\\3", file);
        }
        BEGIN { OFS = FS } {
            fname = basename($1);
            tag = $3;
            if (fname == $3)
                tag = "";

            fname = path3($1);
            $3 = $3 ":" fname ":\t\011" tag;
            print;
        }'
END

    " grep-sample: ./tldr/linux/sharememory.md:1:# sharememory: mmap, shmget, shm_open
    let s:grep_hdr_prettier =<< END
        | awk -F: '
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        function path3(file) {
            return gensub(/.*\/([^\/]*)\/([^\/]*)\/([^\/]*)$/, "\\1/\\2/\\3", file);
        }
        BEGIN { OFS = FS }
        $3 ~ /^# / || $3 ~ /^## / || $3 ~ /^### / {
            fname = basename($1);
            tag = $3;
            if (fname == $3)
                tag = "";

            fname = path3($1);
            $3 = $3 ":" fname ":\t\011" tag;
            print;
        }'
END

    let s:grep_filter_1st_titleline =<< END
        | awk -F: '
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        function path3(file) {
            return gensub(/.*\/([^\/]*)\/([^\/]*)\/([^\/]*)$/, "\\1/\\2/\\3", file);
        }
        BEGIN { OFS = FS }
        /:1:/ {
            fname = basename($1);
            tag = $3;
            if (fname == $3)
                tag = "";

            fname = path3($1);
            $3 = $3 ":" fname ":\t\011" tag;
            print;
        }'
END

    command! -bang -nargs=* Wiki2FzfFile
                \ call fzf#vim#grep(
                \   'rg --column --line-number --no-heading --no-column --color=never --sort-files --smart-case --type md '
                \   ..' '..shellescape(<q-args>)
                \   ..' '..join(g:vim_confi_option.tldr_dirs)
                \   ..join(s:grep_filter_1st_titleline),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)

    command! -bang -nargs=* Wiki2FzfHeader
                \ call fzf#vim#grep(
                \   'rg --column --line-number --no-heading --no-column --color=never --sort-files --smart-case --type md '
                \   ..' '..shellescape(<q-args>)
                \   ..' '..join(g:vim_confi_option.tldr_dirs)
                \   ..join(s:grep_hdr_prettier),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)

    command! -bang -nargs=* Wiki2FzfText
                \ call fzf#vim#grep(
                \   'rg --column --line-number --no-heading --no-column --color=never --sort-files --smart-case --type md '
                \   ..' '..shellescape(<q-args>)
                \   ..' '..join(g:vim_confi_option.tldr_dirs)
                \   ..join(s:grep_prettier),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)
else
    command! -bang -nargs=* Wiki2FzfFile   call echomsg "Please check env-var `TLDR_PAGES_SOURCE_LOCATION`: file://$HOME/wiki/tldr"
    command! -bang -nargs=* Wiki2FzfHeader call echomsg "Please check env-var `TLDR_PAGES_SOURCE_LOCATION`: file://$HOME/wiki/tldr"
    command! -bang -nargs=* Wiki2FzfText   call echomsg "Please check env-var `TLDR_PAGES_SOURCE_LOCATION`: file://$HOME/wiki/tldr"
endif


if !empty(g:vim_wiki_dirs)
    "
    " @var tag is the 2nd content of the file, so here insert <tab> between filename and content-sample-line
    " @cmd gensub offer match-group references
    " @cmd path3() shorter path by only keep last 3 level:
    "               ~/.vim/bundle/fzf-cscope.vim/plugin/fzffilter.vim
    "                             fzf-cscope.vim/plugin/fzffilter.vim
    "
    "@evalStart
    let s:grep_filter_2ndline =<< END
        | awk -F: '
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        function path3(file) {
            return gensub(/.*\/([^\/]*)\/([^\/]*)\/([^\/]*)$/, "\\1/\\2/\\3", file);
        }
        BEGIN { OFS = FS }
        /:2:/ {
            fname = basename($1);
            tag = $3;
            if (fname == $3)
                tag = "";

            fname = path3($1);
            $3 = $3 ":" fname ":\t\011" tag;
            print;
        }'
END
    "echo "test:[". join(g:vim_confi_option.grep_filter_2ndline). "]"
    "@evalEnd


    " @var tag is the 2nd content of the file, so here insert <tab> between filename and content-sample-line
    " @cmd gensub offer match-group references
    " @cmd path3() shorter path by only keep last 3 level:
    "               ~/.vim/bundle/fzf-cscope.vim/plugin/fzffilter.vim
    "                             fzf-cscope.vim/plugin/fzffilter.vim
    " For example:
    "   grep output: ./tldr/linux/sharememory.md:1:# sharememory: mmap, shmget, shm_open
    "   awk input:
    "         $3,4  <The text>  '# sharememory: mmap, shmget, shm_open'
    "         $3    '# sharememory'
    "         $4    'mmap, shmget, shm_open'
    "@evalStart
    let s:grep_filter_1stline =<< END
        | awk -F: '
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        function path3(file) {
            return gensub(/.*\/([^\/]*)\/([^\/]*)\/([^\/]*)$/, "\\1/\\2/\\3", file);
        }
        BEGIN { OFS = FS }
        /:1:/ {
            fname = basename($1);
            fname = path3($1);
            $3 = "0:" fname;
            print $1 ":" $2 ":" $3;
        }'
END
    "echo "test:[". join(g:vim_confi_option.grep_filter_2ndline). "]"
    "@evalEnd

    let s:grep_prettier =<< END
        | awk -F: '
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        function path3(file) {
            return gensub(/.*\/([^\/]*)\/([^\/]*)\/([^\/]*)$/, "\\1/\\2/\\3", file);
        }
        BEGIN { OFS = FS } {
            fname = basename($1);
            tag = $3;
            if (fname == $3)
                tag = "";

            fname = path3($1);
            $3 = $3 ":" fname ":\t\011" tag;
            print;
        }'
END

    command! -bang -nargs=* FzfFiles
                \ call fzf#vim#grep(
                \   'grep --color=no -rn --exclude-dir={'..shellescape("'.tag?',")..shellescape("'.cache',")..shellescape("'.ccls_cache'")..'} -m2 "" -- '
                \       ..join(g:vim_wiki_dirs)
                \       ..' '..shellescape(<q-args>)
                \       ..join(s:grep_filter_2ndline),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4.. -q '..shellescape(hw#misc#GetCursorWord()) }),
                \   <bang>0)

    command! -bang -nargs=* WikiFzfFiles
                \ call fzf#vim#grep(
                \   'grep --color=no -rn --include \*.md --exclude-dir={'..shellescape("'.tag?',")..shellescape("'.cache',")..shellescape("'.ccls_cache'")..'} -m1 "" -- '
                \       ..join(g:vim_wiki_dirs)
                \       ..' '..shellescape(<q-args>)
                \       ..join(s:grep_filter_1stline),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)

    command! -bang -nargs=* WikiFzfText
                \ call fzf#vim#grep(
                \   'rg --column --line-number --no-heading --no-column --color=never --sort-files --smart-case --type md '
                \   ..' '..shellescape(<q-args>)
                \   ..' '..join(g:vim_wiki_dirs)
                \   ..join(s:grep_prettier),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)

else
    command! -bang -nargs=* FzfFiles     call echomsg 'Please set in `.vimrc.before` like: `let g:vim_wiki_dirs = ["~/wiki"]`'
    command! -bang -nargs=* WikiFzfFiles call echomsg 'Please set in `.vimrc.before` like: `let g:vim_wiki_dirs = ["~/wiki"]`'
    command! -bang -nargs=* WikiFzfText  call echomsg 'Please set in `.vimrc.before` like: `let g:vim_wiki_dirs = ["~/wiki"]`'
endif


"         line  = $2;
"         col   = $3;
"         fname = $4;
"         if (getline < fname < 0)
"             fname = env_ftxt;
"         print fname ":" line ":" col ":" basename(fname);
"@evalStart
let g:vim_confi_option.trans_jump =<< END
    | awk -v env_ftxt="$ftxt" -v env_home="$fhome" '
    function basename(file) {
        sub(".*/", "", file);
        return file;
    }
    function exists(name) {
        return getline < name <= 0 ? 0 : 1;
    }
    BEGIN {}
    NF > 3 {
        line  = $2;
        col   = $3;

        gsub(/^~/, env_home, $4);
        fname = $4;

        text  = "";
        if (NF > 4) {
            fname = env_ftxt;
            for (i=4; i <= NF; i++)
                text = text" "$i;
        } else if (! exists(fname)) {
            text = fname;
            fname = env_ftxt;
        }
        print fname ":" line ":" col ":" basename(fname)": " text;
    }'
END
"echo "test:[". join(g:vim_confi_option.transformer). "]"
"@evalEnd


fun! s:getJumps(listname)
    redir => cout
    silent execute a:listname
    redir END
    let jlist =  reverse(split(cout, "\n")[1:])
    if writefile(jlist, g:vim_confi_option.tmp_file)
        echomsg 'write error'
    endif
endf

" function! s:to_relpath(filename)
"     let cwd = getcwd()
"     let s = substitute(a:filename, l:cwd . "/" , "", "")
"     return s
" endfunction

" function! s:format_qf_line(line)
"     let parts = split(a:line, ':')
"     return { 'filename': parts[0]
"                 \,'lnum': parts[1]
"                 \,'col': parts[2]
"                 \,'text': join(parts[3:], ':')
"                 \ }
" endfunction

" function! s:qf_to_fzf(key, line) abort
"     let l:filepath = s:to_relpath(expand('#' . a:line.bufnr . ':p'))
"     return l:filepath . ':' . a:line.lnum . ':' . a:line.col . ':' . a:line.text
" endfunction

" function! s:fzf_to_qf(filtered_list) abort
"     let list = map(a:filtered_list, 's:format_qf_line(v:val)')
"     if len(list) > 0
"         call setqflist(list)
"         copen
"     endif
" endfunction

" fun! s:getQuickfix()
"     let qf = getqflist()
"     call map(qf, function('<sid>qf_to_fzf'))
"     echomsg qf
"     if writefile(qf, g:vim_confi_option.tmp_file)
"         echomsg 'write error'
"     endif
" endf

" command! -bang -nargs=* FZFQF
"             \   let $ftxt = expand('%') <bar> let $fhome = $HOME <bar>
"             \   call s:getQuickfix() <bar>
"             \   call fzf#vim#grep(
"             \       'cat '..g:vim_confi_option.tmp_file,
"             \       1,
"             \       fzfpreview#p(<bang>0, ),
"             \       <bang>0)


command! -bang -nargs=* FZFJump
            \   let $ftxt = expand('%') <bar> let $fhome = $HOME <bar>
            \   call s:getJumps('jumps') <bar>
            \   call fzf#vim#grep(
            \       'cat '..g:vim_confi_option.tmp_file
            \       ..join(g:vim_confi_option.trans_jump),
            \       1,
            \       fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
            \       <bang>0)


command! -bang -nargs=* FZFChange
            \   let $ftxt = expand('%') <bar> let $fhome = $HOME <bar>
            \   call s:getJumps('changes') <bar>
            \   call fzf#vim#grep(
            \       'cat '..g:vim_confi_option.tmp_file
            \       ..join(g:vim_confi_option.trans_jump),
            \       1,
            \       fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
            \       <bang>0)


command! -bang -nargs=* FzfTagHomeCacheTag   call fzffilter#TagFilter(<q-args>, <bang>0, 'home-cache-tag')
command! -bang -nargs=* FzfTagFilter         call fzffilter#TagFilter(<q-args>, <bang>0, 'n')
command! -bang -nargs=* FzfTagFilterV        call fzffilter#TagFilter(<q-args>, <bang>0, 'v')


command! -bang -nargs=* WikiRgDot call fzf#vim#grep('rg
            \ --column --line-number --no-heading --no-column --color=never --sort-files
            \ --smart-case --type md "<q-args>" "$HOME/dotwiki"',
            \ 1, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* WikiRgLinux call fzf#vim#grep('rg
            \ --column --line-number --no-heading --no-column --color=never --sort-files
            \ --smart-case --type md "<q-args>" "$HOME/wiki"',
            \ 1, fzf#vim#with_preview(), <bang>0)


command! FzfQF call fzf#run({
            \ 'source': map(getqflist(), function('<sid>qf_to_fzf')),
            \ 'down':   '20',
            \ 'sink*':   function('<sid>fzf_to_qf'),
            \ 'options': '--reverse --multi --bind=ctrl-a:select-all,ctrl-d:deselect-all --prompt "quickfix> "',
            \ })

" command! -bang FzfQF2 call fzf#run(fzf#vim#with_preview(fzf#wrap({
"             \ 'source': map(getqflist(), function('<sid>qf_to_fzf')),
"             \ 'down':   '30',
"             \ 'sink*':   function('<sid>fzf_to_qf'),
"             \ 'options': '--reverse --multi --bind=ctrl-s:select-all,ctrl-d:deselect-all --prompt "filter> "',
"             \ })))

" command! -bang FzfQF2 call fzf#run(fzf#vim#with_preview(fzf#wrap({
"             \ 'source': map(getqflist(), function('<sid>qf_to_fzf')),
"             \ 'down':   '30',
"             \ 'sink*':   function('<sid>fzf_to_qf'),
"             \ 'options': '--reverse --multi --bind=ctrl-s:select-all,ctrl-d:deselect-all --prompt "filter> "',
"             \ })))
