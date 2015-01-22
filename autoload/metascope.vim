" typename -> definition
let s:definitions = {}

" internal_key -> data
let s:data = {}

function! metascope#register(definition) abort " {{{
	call s:ensure_has_key('definition', a:definition, 'scope_identifier')
	call s:ensure_has_key('definition', a:definition, 'name')

	let s:definitions[a:definition.name] = a:definition
endfunction " }}}

function! metascope#defined(fullname) abort " {{{
	return has_key(s:data, metascope#internal_key(a:fullname))
endfunction " }}}

function! metascope#get(fullname, ...) abort " {{{
	let key = metascope#internal_key(a:fullname)
	if !has_key(s:data, key)
		throw 'metascope: variable ' . a:fullname . ' is not set in current scope'
	endif
	return s:data[key]
endfunction " }}}

function! metascope#set(fullname, data) abort " {{{
	let s:data[metascope#internal_key(a:fullname)] = a:data
endfunction " }}}

function! metascope#definition(typename) abort " {{{
	if !has_key(s:definitions, a:typename)
		throw 'metascope: Unknown scope type name: ' . a:typename
	endif
	return s:definitions[a:typename]
endfunction " }}}

function! metascope#internal_key(fullname) abort " {{{
	let [typename, name] = s:parse_name(a:fullname)
	let definition = metascope#definition(typename)

	let id = definition.scope_identifier()

	return typename . ':' . id . ':' . name
endfunction " }}}

function! metascope#accessor(fullname, ...) abort " {{{
	if a:0 == 0
		return s:new_accessor(metascope#internal_key(a:fullname))
	else
		let [typename, name] = s:parse_name(a:fullname)
		call metascope#definition(typename) " ensure typename is registered
		return s:new_accessor(typename . ':' . a:1 . ':' . name)
	endif
endfunction " }}}

function! s:parse_name(fullname) abort " {{{
	let [typename, name] = split(a:fullname, ':')
	return [typename, name]
endfunction " }}}

function! s:ensure_has_key(name, dic, key) abort " {{{
	if !has_key(a:dic, a:key)
		throw 'metascope: ' . a:name . '.' . a:key . ' is not set'
	endif
endfunction " }}}

function! s:new_accessor(internal_key) abort " {{{
	return extend(copy(s:accessor_prototype), {'key': a:internal_key})
endfunction " }}}

if exists('s:accessor_prototype')
	unlet s:accessor_prototype
endif
let s:accessor_prototype = {}

function! s:accessor_prototype.get() dict abort " {{{
	return s:data[self.key]
endfunction " }}}

function! s:accessor_prototype.set(value) dict abort " {{{
	let s:data[self.key] = a:value
endfunction " }}}

function! s:accessor_prototype.is_defined() dict abort " {{{
	return has_key(s:data, self.key)
endfunction " }}}

lockvar! s:accessor_prototype
