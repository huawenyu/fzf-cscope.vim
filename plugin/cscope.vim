if exists('g:loaded_hw_fzfcscope') || &compatible
    finish
endif
let g:loaded_hw_fzfcscope = 1


augroup fzf_cscope
    autocmd!

    "nvim should load cscope db by script
    autocmd BufEnter * call cscope#LoadCscope()
    "autocmd BufEnter /* call cscope#ReLoadCscope()
    "autocmd BufNewFile,BufRead * call cscope#LoadCscope()
augroup end

command! Cscope :call cscope#ReLoadCscope()

command! -bang -nargs=* CSFileFilter    call cscope#FileFilter(<q-args>, <bang>0)
command! -bang -nargs=* CSTagFilter     call cscope#TagFilter(<q-args>, <bang>0)
command! -bang -nargs=* CscopeText      call cscope#preview('4', <q-args>, <bang>0)
command! -bang -nargs=* CscopeGrep      call cscope#preview('6', <q-args>, <bang>0)


if has('cscope')
    set cscopetagorder=0
    "set cscopetag
    set cscoperelative
    set cscopeverbose
    "set cscopequickfix=s-,c-,d-,i-,t-,e-
    set cscopequickfix=s0,c0,d0,i0,t-,e-
    set cscopepathcomp=3

    "nnoremap T :cs find c <C-R>=expand("<cword>")<CR><CR>
    "nnoremap t <C-]>
    "nnoremap gt <C-W><C-]>
    "nnoremap gT <C-W><C-]><C-W>T

    "nnoremap <silent> <leader>z :Dispatch echo "Generating tags and cscope database..." &&
    "    \ find -L . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files &&
    "    \ sort cscope.files > cscope.files.sorted && mv cscope.files.sorted cscope.files &&
    "    \ cscope -kbq -i cscope.files -f cscope.out &&
    "    \ ctags -R --fields=+aimSl --c-kinds=+lpx --c++-kinds=+lpx --exclude='.svn' 
    "    \ --exclude='.git' --exclude='*.a' --exclude='*.js' --exclude='*.pxd' --exclude='*.pyx' --exclude='*.so' &&
    "    \ echo "Done." <cr><cr>

    "cnoreabbrev csa cs add
    "cnoreabbrev csf cs find
    "cnoreabbrev csk cs kill
    "cnoreabbrev csr cs reset
    "cnoreabbrev css cs show
    "cnoreabbrev csh cs help
    "cnoreabbrev csc Cscope
endif


" The following maps all invoke one of the following cscope search types:
"   's'   symbol: find all references to the token under cursor
"   'g'   global: find global definition(s) of the token under cursor
"   'c'   calls:  find all calls to the function name under cursor
"   'd'   called: find functions that function under cursor calls
"   't'   text:   find all instances of the text under cursor
"   'e'   egrep:  egrep search for the word under cursor
"   'f'   file:   open the filename under cursor
"   'i'   includes: find files that include the filename under cursor
"
"    0    Find this C symbol:
"    1    Find this function definition:
"    2    Find functions called by this function:
"    3    Find functions calling this function:
"    4    Find this text string:
"    5    Change this text string:
"    6    Find this egrep pattern:
"    7    Find this file:
"    8    Find files #including this file:
"    9:   Find places where this symbol is assigned a value
"
" +ctags
"         :tags   see where you currently are in the tag stack
"         :tag sys_<TAB>  auto-complete
" http://www.fsl.cs.sunysb.edu/~rick/rick_vimrc

":help cscope-options

" Diable cscopetag, using tags for auto-tag quickly.
"set cscopetag
"set cscopequickfix=s0,c0,d0,i0,t-,e-

if exists("g:fzf_cscope_map") && g:fzf_cscope_map
    " symbol
    " 1. Please install 'batcat' first: sudo apt install bat
    " 2. Then check the config if batcat can't works:  batcat --diagnostic
    if !executable('batcat')
        echom "[fzf-cscope.vim] Please install `batcat` for fzf-preview: sudo apt install bat"
        finish
    endif

    if !executable('gawk')
        echom "[fzf-cscope.vim] Please install `gawk` for tags filter: sudo apt install gawk"
        finish
    endif

    " File
    " FileCatV, FileCatPreN (preview)
    nnoremap <silent> <leader>ff    :CSFileFilter<cr>
    vnoremap <silent> <leader>ff    :<c-u>CSFileFilter<cr>

    " All files
    nnoremap <silent>        ;ff    :CSFileFilter!<cr>
    vnoremap <silent>        ;ff    :<c-u>CSFileFilter!<cr>

    " Function called
    nnoremap <silent> <leader>fs    :call cscope#preview('3', 'n', 1)<cr>
    vnoremap <silent> <leader>fs    :<c-u>call cscope#preview('3', 'v', 1)<cr>

    " Function calling
    nnoremap <silent>        ;fs    :call cscope#preview('2', 'n', 1)<cr>
    vnoremap <silent>        ;fs    :<c-u>call cscope#preview('2', 'v', 1)<cr>

    " Function symbol
    nnoremap <silent> <leader>fw    :CSTagFilter<cr>
    vnoremap <silent> <leader>fw    :<c-u>CSTagFilter<cr>
    " no Function symbol
    nnoremap <silent>        ;fw    :CSTagFilter!<cr>
    vnoremap <silent>        ;fw    :<c-u>CSTagFilter!<cr><cr>

    nnoremap <silent> <leader>fj    :FZFJump<cr>
    nnoremap <silent> <leader>fc    :FZFChange<cr>
    nnoremap <silent> <leader>fm    :FZFMarks<cr>

    " " tExt
    " nnoremap          <leader>fe    :CscopeText! <c-r>=utils#GetSelected('')<cr>
    " vnoremap          <leader>fe    :<c-u>CscopeText! <c-r>=utils#GetSelected('')<cr>
    " nnoremap          <leader>fE    :CscopeGrep! <c-r>=utils#GetSelected('')<cr>
    " vnoremap          <leader>fE    :<c-u>CscopeGrep! <c-r>=utils#GetSelected('')<cr>

    Shortcut! <space>ff    find file related
    Shortcut!       ;ff    find file all
    Shortcut! <space>fs    find function caller
    Shortcut!       ;fs    find function callee
    Shortcut! <space>fw    find symbol function
    Shortcut!       ;fw    find symbol not function
    "Shortcut! <space>fF   find file all
    "Shortcut! <space>fe   find function

endif

