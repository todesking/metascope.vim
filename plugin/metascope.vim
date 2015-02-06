" Scope filetype {{{
let s:def = {'name': 'filetype'}

function! s:def.scope_identifier() abort " {{{
	return &filetype
endfunction " }}}

call metascope#register(s:def)
unlet s:def
" }}}

function! s:define_accessor(definition, dict_name) abort " {{{
endfunction " }}}

function! s:accessor_get(dict, name, ...) abort " {{{
endfunction " }}}

function! s:accessor_set(dict, name, value) abort " {{{
endfunction " }}}

" Scope buffer {{{
let s:def = {'name': 'b', 'storage_type': 'dynamic_dict'}

function! s:def.storage() abort " {{{
	return b:
endfunction " }}}

call metascope#register(s:def)
unlet s:def
" }}}

" Scope window {{{
let s:def = {'name': 'w', 'storage_type': 'dynamic_dict'}

function! s:def.storage() abort " {{{
	return w:
endfunction " }}}

call metascope#register(s:def)
unlet s:def
" }}}

" Scope tab {{{
let s:def = {'name': 't', 'storage_type': 'dynamic_dict'}

function! s:def.storage() abort " {{{
	return t:
endfunction " }}}

call metascope#register(s:def)
unlet s:def
" }}}

" Scope global {{{
let s:def = {'name': 'g', 'storage_type': 'dynamic_dict'}

function! s:def.storage() abort " {{{
	return g:
endfunction " }}}

call metascope#register(s:def)
unlet s:def
" }}}
