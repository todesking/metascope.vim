" scopename -> scope
let s:scopes = {}

" internal_key -> data
let s:data = {}

function! metascope#register(definition) abort " {{{
	let s:scopes[a:definition.name] = s:scope_new(a:definition)
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

function! s:scope_new(definition) abort " {{{
	call s:ensure_has_key('definition', a:definition, 'name')

	" contexts: scope_identifier -> {data}
	let instance = extend(copy(s:scope_prototype), {
		\ 'name': a:definition.name,
		\ })

	let storage_type = get(a:definition, 'storage_type', 'internal')
	if storage_type ==# 'internal'
		call s:ensure_has_key('definition', a:definition, 'scope_identifier')
		let instance.scope_identifier = a:definition.scope_identifier
		let instance.contexts = {}
		call extend(instance, s:storage_internal)
	elseif storage_type ==# 'dynamic_dict'
		call s:ensure_has_key('definition', a:definition, 'storage')
		let instance.storage = a:definition.storage
		call extend(instance, s:storage_dynamic_dict)
	else
		throw 'metascope: Unknown storage type: ' . storage_type
	endif
	return instance
endfunction " }}}

" Storage: dynamic dict {{{
let s:storage_dynamic_dict = {}
function! s:storage_dynamic_dict.get(name, ...) dict abort " {{{
	let dict = self.storage()
	if a:0 == 0
		if !has_key(dict, a:name)
			throw self._undefined_var_message(a:name)
		endif
		return dict[a:name]
	else
		return get(dict, a:name, a:1)
	endif
endfunction " }}}

function! s:storage_dynamic_dict.set(name, value) dict abort " {{{
	let dict = self.storage()
	let dict[a:name] = a:value
endfunction " }}}

function! s:storage_dynamic_dict.exists(name) dict abort " {{{
	return has_key(self.storage(), a:name)
endfunction " }}}

lockvar! s:storage_dynamic_dict
" }}}

" Storage: internal {{{
let s:storage_internal = copy(s:storage_dynamic_dict)

function! s:storage_internal.storage() dict abort " {{{
	let key = self.scope_identifier()
	let c = get(self.contexts, key, {})
	let self.contexts[key] = c
	return c
endfunction " }}}
" }}}

function! s:scope_prototype._undefined_var_message(name) dict abort " {{{
	return 'metascope: variable `' . a:name . '` is not defined in current scope(' . self.name . ')'
endfunction " }}}

lockvar! s:scope_prototype
" }}}
