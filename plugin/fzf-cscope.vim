" Version:      1.2

if exists('g:loaded_fzf_cscope') || &compatible
  finish
else
  let g:loaded_fzf_cscope = 'yes'
endif


"nvim should load cscope db by script
autocmd BufEnter * call cscope#LoadCscope()
command! Cscope :call cscope#ReLoadCscope()
"autocmd BufEnter /* call cscope#ReLoadCscope()
"autocmd BufNewFile,BufRead * call cscope#LoadCscope()


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
    "nmap <leader>] :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR>
    nmap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>fe :cs find e <C-R>=expand("<cword>")<CR>
    nmap <leader>ft :call cscope#Symbol() <CR>

    nnoremap <silent> <Leader>fa :call cscope#run('0', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>cc :call cscope#run('1', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>cd :call cscope#run('2', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>ce :call cscope#run('3', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>cf :call cscope#run('4', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>cg :call cscope#run('6', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>ci :call cscope#run('7', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>cs :call cscope#run('8', expand('<cword>'))<CR>
    nnoremap <silent> <Leader>ct :call cscope#run('9', expand('<cword>'))<CR>

    nnoremap <silent> <Leader><Leader>ca :call cscope#Query('0')<CR>
    nnoremap <silent> <Leader><Leader>cc :call cscope#Query('1')<CR>
    nnoremap <silent> <Leader><Leader>cd :call cscope#Query('2')<CR>
    nnoremap <silent> <Leader><Leader>ce :call cscope#Query('3')<CR>
    nnoremap <silent> <Leader><Leader>cf :call cscope#Query('4')<CR>
    nnoremap <silent> <Leader><Leader>cg :call cscope#Query('6')<CR>
    nnoremap <silent> <Leader><Leader>ci :call cscope#Query('7')<CR>
    nnoremap <silent> <Leader><Leader>cs :call cscope#Query('8')<CR>
    nnoremap <silent> <Leader><Leader>ct :call cscope#Query('9')<CR>
endif

