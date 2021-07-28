if exists('g:loaded_close_buffers') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! -bang -nargs=1 BDelete lua require('close_buffers').cmd(<q-args>, 'delete', <q-bang>)
command! -bang -nargs=1 BWipeout lua require('close_buffers').cmd(<q-args>, 'wipe', <q-bang>)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_close_buffers = 1
