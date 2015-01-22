" Scope filetype {{{
let s:def = {'name': 'filetype'}

function! s:def.scope_identifier() abort " {{{
	return &filetype
endfunction " }}}

call metascope#register(s:def)
unlet s:def
" }}}

" Scope buffer {{{
let s:def = {'name': 'buffer'}

function! s:def.scope_identifier() abort " {{{
	return string(bufnr('%'))
endfunction " }}}

call metascope#register(s:def)
unlet s:def

augroup metascope-scope-buffer
	autocmd!
	autocmd BufDelete * call metascope#scope('buffer').clear_context(expand('<abuf>'))
augroup END
" }}}
