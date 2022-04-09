
function! tealmaker#BuildAll(...)
    let verbose = len(a:000) == 0 ? 0 : a:1
    if verbose
        lua require("tealmaker").build_all(true)
    else
        lua require("tealmaker").build_all(false)
    endif
endfunction
