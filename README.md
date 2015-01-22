# metascope.vim: User-defined scope for variables

## Usage

Example: Define the "current-filetype" scope

```vim
" from plugin/metascope.vim

let s:def = {'name': 'filetype'}

function! s:def.scope_identifier() abort " {{{
	return &filetype
endfunction " }}}

call metascope#register(s:def)

unlet s:def

```

```vim
call metascope#set('filetype:foo', 10)

echo metascope#get('filetype:foo')
```
