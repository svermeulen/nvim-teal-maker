
nnoremap <plug>(TealBuild) :<c-u>call tealmaker#BuildAll(1)<cr>

command! -bang -nargs=0 TealBuild call tealmaker#BuildAll(1)
