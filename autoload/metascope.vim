" scopename -> scope
let s:scopes = {}

" internal_key -> data
let s:data = {}

function! metascope#register(definition) abort " {{{
	call s:ensure_has_key('definition', a:definition, 'scope_identifier')
	call s:ensure_has_key('definition', a:definition, 'name')

	let definition = copy(a:definition)
	lockvar! definition
	let s:scopes[a:definition.name] =
		\ extend(copy(s:scope_prototype), {'definition': definition, 'data': {}})
endfunction " }}}

function! metascope#defined(fullname) abort " {{{
	let [scope, name] = s:parse_name(a:fullname)
	return scope.is_defined(name)
endfunction " }}}

function! metascope#get(fullname, ...) abort " {{{
	let [scope, name] = s:parse_name(a:fullname)
	return call(scope.get, [name] + a:000, scope)
endfunction " }}}

function! metascope#set(fullname, data) abort " {{{
	let [scope, name] = s:parse_name(a:fullname)
	call scope.set(name, a:data)
endfunction " }}}

function! metascope#scope(scopename) abort " {{{
	if !has_key(s:scopes, a:scopename)
		throw 'metascope: Unknown scope name: ' . a:scopename
	endif
	return s:scopes[a:scopename]
endfunction " }}}

function! s:parse_name(fullname) abort " {{{
	let [scopename, name] = split(a:fullname, ':')
	return [metascope#scope(scopename), name]
endfunction " }}}

function! s:ensure_has_key(name, dic, key) abort " {{{
	if !has_key(a:dic, a:key)
		throw 'metascope: ' . a:name . '.' . a:key . ' is not set'
	endif
endfunction " }}}

" class Scope {{{
if exists('s:scope_prototype')
	unlet s:scope_prototype
endif
let s:scope_prototype = {}

function! s:scope_prototype.get(name, ...) abort " {{{
	let key = self.make_internal_key(a:name)
	if a:0 == 0
		if !has_key(self.data, key)
			throw 'metascope: variable ' . a:name . ' is not defined in current ' . self.definition.name . ' scope'
		endif
		return self.data[key]
	else
		return get(self.data, key, a:1)
	endif
endfunction " }}}

function! s:scope_prototype.make_internal_key(name) abort " {{{
	let id = self.definition.scope_identifier()
	return self.definition.name . ':' . id . ':' . a:name
endfunction " }}}

function! s:scope_prototype.set(name, value) abort " {{{
	let self.data[self.make_internal_key(a:name)] = a:value
endfunction " }}}

lockvar! s:scope_prototype
" }}}
