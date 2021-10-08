if exists('g:loaded_hw_fzffilter') || &compatible
    finish
endif
let g:loaded_hw_fzffilter = 1


let g:vim_confi_option = get(g:, 'vim_confi_option', {})
let g:vim_confi_option.tmp_file = get(g:vim_confi_option, 'tmp_file', '/tmp/vim.tmp')

if !empty(g:vim_confi_option.fzf_files)
    "@evalStart
    let g:vim_confi_option.trans_grepshorter =<< END
        | awk -F: '
        function basename(file) {
            sub(".*/", "", file);
            return file;
        }
        BEGIN { OFS = FS } /:2:/{
            fname = basename($1);
            tag = $3;
            if (fname == $3)
                tag = "";

            $3 = $3 ":" fname ":" tag;
            print;
        }'
END
    "echo "test:[". join(g:vim_confi_option.trans_grepshorter). "]"
    "@evalEnd

    command! -bang -nargs=* Cheat
                \ call fzf#vim#grep(
                \   'grep --color=no -rn -m2 "" -- '
                \       ..join(g:vim_confi_option.fzf_files)
                \       ..' '..shellescape(<q-args>)
                \       ..join(g:vim_confi_option.trans_grepshorter),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)

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


" function! GoToJump(jump)
"     let jumpnumber = split(a:jump, '\s\+')[0]
"     execute "normal " . jumpnumber . "\<c-o>"
" endfunction

" command! Jump let $ftxt = expand('%') <bar> call fzf#run(fzf#vim#with_preview(fzf#wrap({
"             \ 'source': GetJumps(),
"             \ 'sink': function('GoToJump')})))

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


if HasPlug('vim.config')
    command! -bang -nargs=* WikiRgBug call fzf#vim#grep('rg
                \ --column --line-number --no-heading --no-column --color=never --sort-files
                \ --smart-case --type md <q-args> "$MYPATH_WIKI"',
                \ 1, fzf#vim#with_preview(), <bang>0)

    command! -bang -nargs=* WikiRgDot call fzf#vim#grep('rg
                \ --column --line-number --no-heading --no-column --color=never --sort-files
                \ --smart-case --type md <q-args> "$HOME/dotwiki"',
                \ 1, fzf#vim#with_preview(), <bang>0)

    command! -bang -nargs=* WikiRgLinux call fzf#vim#grep('rg
                \ --column --line-number --no-heading --no-column --color=never --sort-files
                \ --smart-case --type md <q-args> "$HOME/wiki"',
                \ 1, fzf#vim#with_preview(), <bang>0)

    "autocmd FileType vimwiki nnoremap <buffer> <leader>wf :WikiRg<Space>
    Shortcut! Wiki(bug) search full text
			\ nnoremap <Space>,,d      :WikiRgBug<Space>
    Shortcut! Wiki(dot) search full text
			\ nnoremap <Space>,,e      :WikiRgDot<Space>
    Shortcut! Wiki(linux) search full text
			\ nnoremap <Space>,,f      :WikiRgLinux<Space>

endif


