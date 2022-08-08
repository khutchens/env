"syn keyword langKeyword ? | :


if exists("b:current_syntax")
 finish
endif

"syn region langComment start="#" end="$" contains=langTodo
syn match langComment /#.*/ contains=langTodo
syn keyword langTodo TODO contained

setlocal iskeyword+=$
syn keyword langKeyword iface impl struct with context func enter exit error if while import as using for var is bool try catch panic
syn keyword langSelf $
syn keyword langTypes void byte i8 i16 i32 u8 u16 u32

syn match langId /[_a-zA-Z][_a-zA-Z0-9]*/

syn match langFuncId /[_a-zA-Z][_a-zA-Z0-9]*/ contained
syn match langFunc /[_a-zA-Z][_a-zA-Z0-9]*(/ contains=langFuncId

"syn match langOperators /[|:+[\](){}?*]\|->\|\.\./
"syn match langPrefixes /[?%]/ contained

"setlocal iskeyword+=%
"syn keyword langDirective %declare %ignore %import
"syn match langRuleRef /[a-z_]\+/
"syn match langRule /^?\?[a-z_]\+/ contains=langPrefixes
"syn match langTerminalRef /[A-Z_]\+/
"syn match langTerminal /^[A-Z_]\+/
"syn region langPattern start="/" end="/" skip="\\."
syn match langDecNumber /[0-9]\+/
syn match langHexNumber /0x[0-9a-f]\+/
syn region langString start='"' end='"' skip='\\.'


let b:current_syntax = "lang"

hi langComment ctermfg=darkgrey
hi langTodo ctermfg=darkyellow
hi langKeyword ctermfg=darkmagenta
hi langSelf ctermfg=darkred
hi langTypes ctermfg=darkmagenta
hi langId ctermfg=darkcyan
hi langFuncId ctermfg=darkyellow
hi langString ctermfg=darkred
hi langDecNumber ctermfg=darkred
hi langHexNumber ctermfg=darkred
