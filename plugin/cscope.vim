" Version:      1.2

if exists('g:loaded_fzf_cscope') || &compatible
  finish
else
  let g:loaded_fzf_cscope = 'yes'
endif



augroup fzf_cscope
    autocmd!

    "nvim should load cscope db by script
    autocmd BufEnter * call cscope#LoadCscope()
    "autocmd BufEnter /* call cscope#ReLoadCscope()
    "autocmd BufNewFile,BufRead * call cscope#LoadCscope()
augroup end

command! Cscope :call cscope#ReLoadCscope()

command! -bang -nargs=* FileCatN    call cscope#FileCat(0, <q-args>, <bang>0, 0)
command! -bang -nargs=* FileCatV    call cscope#FileCat(1, <q-args>, <bang>0, 0)

command! -bang -nargs=* FileCatPreN call cscope#FileCat(0, <q-args>, <bang>0, 1)
command! -bang -nargs=* FileCatPreV call cscope#FileCat(1, <q-args>, <bang>0, 1)

command! -bang -nargs=* TagCatN     call cscope#TagCat(0,  <q-args>, <bang>0, 0)
command! -bang -nargs=* TagCatV     call cscope#TagCat(1,  <q-args>, <bang>0, 0)

command! -bang -nargs=* TagCatPreN  call cscope#TagCat(0,  <q-args>, <bang>0, 1)
command! -bang -nargs=* TagCatPreV  call cscope#TagCat(1,  <q-args>, <bang>0, 1)


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
    if CheckPlug('fzf.vim', 1)
        nnoremap <silent> <Leader>fs         :call cscope#run('0', expand('<cword>'))<CR>
        nnoremap <silent> <Leader>fc         :call cscope#run('2', expand('<cword>'))<CR>
        nnoremap <silent> <Leader><leader>fs :call cscope#preview('0', expand('<cword>'), 1)<CR>
        nnoremap <silent> <Leader><leader>fc :call cscope#preview('2', expand('<cword>'), 1)<CR>

        nnoremap <leader>fi                  :TagCatN! <C-R>=printf("%s", expand('<cword>'))<cr>
        nnoremap <leader><leader>fi          :TagCatPreN! <C-R>=printf("%s", expand('<cword>'))<cr>
        xnoremap <leader>fi                  :<c-u>TagCatV! <C-R>=printf("%s", hw#misc#GetSelection('o')[0])<cr>
        xnoremap <leader><leader>fi          :<c-u>TagCatPreV! <C-R>=printf("%s", hw#misc#GetSelection('o')[0])<cr>

        nnoremap <leader>ff                  :TagCatN <C-R>=printf("%s", expand('<cword>'))<cr>
        nnoremap <leader><leader>ff          :TagCatPreN <C-R>=printf("%s", expand('<cword>'))<cr>
        xnoremap <leader>ff                  :<c-u>TagCatV <C-R>=printf("%s", hw#misc#GetSelection('o')[0])<cr>
        xnoremap <leader><leader>ff          :<c-u>TagCatPreV <C-R>=printf("%s", hw#misc#GetSelection('o')[0])<cr>


        ""xnoremap <silent> ;o  :FileCatV<cr>
        ""xnoremap <silent> ;O  :FileCatV!<cr>
        ""nnoremap <silent> ;O  :FileCatPreN<cr>
        ""xnoremap <silent> ;O  :FileCatPreV<cr>

        "nnoremap <silent> <a-g> :RgType <C-R>=printf("%s", expand('<cword>'))<cr><cr>
        "nnoremap <silent> <a-q> :BLines<cr>
    else
        "nmap <leader>] :cs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR>
        nmap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>
        nmap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>
        nmap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>
        nmap <leader>fe :cs find e <C-R>=expand("<cword>")<CR>
        nmap <leader>ft :call cscope#Symbol() <CR>
    endif
endif



