if exists('g:loaded_hw_fzffilter') || &compatible
    finish
endif
let g:loaded_hw_fzffilter = 1


if !empty(g:vim_confi_option.fzf_files)
    "@evalStart
    let g:vim_confi_option.transformer =<< END
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
    "echo "test:[". join(g:vim_confi_option.transformer). "]"
    "@evalEnd

    command! -bang -nargs=* Cheat
                \ call fzf#vim#grep(
                \   'grep --color=no -rn -m2 "" -- '..join(g:vim_confi_option.fzf_files)..' '..shellescape(<q-args>)..join(g:vim_confi_option.transformer),
                \   1,
                \   fzfpreview#p(<bang>0, { 'options': '--delimiter=: --with-nth=4..' }),
                \   <bang>0)

endif


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
