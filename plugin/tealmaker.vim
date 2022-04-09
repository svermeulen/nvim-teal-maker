
nnoremap <plug>(TealBuild) :<c-u>call tealmaker#BuildAll(1)<cr>

command! -bang -nargs=0 TealBuild call tealmaker#BuildAll(1)

if get(g:, "TealMaker_BuildAllOnStartup", 1)
    call tealmaker#BuildAll(0)
endif

