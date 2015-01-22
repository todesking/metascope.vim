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
	call s:ensure_has_key('definition', a:definition, 'scope_identifier')
	call s:ensure_has_key('definition', a:definition, 'name')

	" contexts: scope_identifier -> {data}
	return extend(copy(s:scope_prototype), {
		\ 'name': a:definition.name,
		\ 'scope_identifier': a:definition.scope_identifier,
		\ 'contexts': {}
		\ })
endfunction " }}}

function! s:scope_prototype.get(name, ...) abort " {{{
	let id = self.scope_identifier()
	let context = get(self.contexts, id, {})
	if a:0 == 0
		if !has_key(context, a:name)
			throw 'metascope: variable ' . a:name . ' is not defined in current ' . self.name . ' scope'
		endif
		return context[a:name]
	else
		return get(context, a:name, a:1)
	endif
endfunction " }}}

function! s:scope_prototype.set(name, value) abort " {{{
	let id = self.scope_identifier()
	let context = get(self.contexts, id, {})
	let self.contexts[id] = context
	let context[a:name]  = a:value
endfunction " }}}

function! s:scope_prototype.clear_context(context_id) abort " {{{
	if has_key(self.contexts, a:context_id)
		unlet self.context[a:context_id]
	endif
endfunction " }}}

lockvar! s:scope_prototype
" }}}
