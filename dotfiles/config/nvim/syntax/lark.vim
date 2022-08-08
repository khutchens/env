"syn keyword larkKeyword ? | :


if exists("b:current_syntax")
 finish
endif

syn match larkOperators /[|:+[\](){}?*]\|->\|\.\./
syn match larkPrefixes /[?%]/ contained
"To do :
"- disable higlight on pattern_group for ()[]{} if there are preseded by \

setlocal iskeyword+=%
syn keyword larkDirective %declare %ignore %import
"syn match larkRegexSymbols /\(\(\\\)\@<=\(\\\\\)*\)\@<!\(+\|(\|)\|{\|}\|\[\|\]\|+\|\*\|?\|\.\|\^\|\$\||\)/
""syn keyword pattern_agroup /
"syn match larkStatement +^\s*%\(ignore\|import\|declare\)+
"syn match larkRule "^\s*\(!\?\)\([_?]\)\?\l\(\l\|[_0-9]\)*"
syn match larkRuleRef /[a-z_]\+/
syn match larkRule /^?\?[a-z_]\+/ contains=larkPrefixes
syn match larkTerminalRef /[A-Z_]\+/
syn match larkTerminal /^[A-Z_]\+/
"syn match larkToken "^\s*\(_\?\)\u\(_\|\u\|\d\)*"
"syn match larkInnerToken "\(\l\|\u\|_\)\@<!\(_\?\)\u\(_\|\u\|\d\)\+"
"syn match larkSeparators +|\|:\|\(->\)+
"syn match larkAgroup +"\|(\|)\|{\|}\|\[\|\]+
"syn match larkTemplateSymbols +\,+
"syn region template start="{" end="}" contains=template_symbols

"The pattern \(\\\)\@<!\(\\\\\)*\\/ match a odd count
"of '\' non preceded by '\'
"syn region pattern matchgroup=pattern_agroup start="/\(/\)\@!" end="/\|\n" skip="\(\\\)\@<!\(\\\\\)*\\/" contains=agroup
"syn region string matchgroup=agroup start='"' end='"\|\n' skip='\(\\\)\@<!\(\\\\\)*\\"'

"syn region larkPattern matchgroup=pattern_agroup start="/" end="/" skip="\\." contains=regex_symbols
syn region larkPattern start="/" end="/" skip="\\."
"syn region larkString matchgroup=agroup start='"' end='"\|\n' skip='\\.'
syn region larkString start='"' end='"' skip='\\.'

syn region larkComment start="//" end="$"

let b:current_syntax = "lark"

"hi Visual ctermbg=black cterm=reverse

hi larkOperators ctermfg=darkcyan
hi larkPrefixes ctermfg=darkcyan

hi larkPattern ctermfg=darkred
hi larkString ctermfg=darkred

hi larkComment ctermfg=darkgrey

hi larkRule ctermfg=darkmagenta
hi larkRuleRef ctermfg=darkyellow

hi larkTerminal ctermfg=darkblue
hi larkTerminalRef ctermfg=darkcyan

hi larkDirective ctermfg=darkgreen


"hi def link larkOperators Special
"hi def link larkPrefixes Special
"
"hi def link larkPattern String
"hi def link larkString String
"
"hi def link larkComment Comment
"
"hi def link larkRule Identifier
"hi def link larkRuleRef Function
"
"hi def link larkTerminal Identifier
"hi def link larkTerminalRef Function
"hi def link larkDirective Macro



"hi def link larkStatement Special
"hi def link larkRule Identifier
"hi def link larkToken Macro
"hi def link larkInnerToken Macro
"hi def link larkSeparators Special
"hi def link larkAgroup Special
"hi def link larkRegexSymbols Special
""hi def link larkPatternAgroup Operator
"hi def link larkComment Comment
"
"hi def link larkPattern String
"hi def link larkString String

"hi def link larkTemplateSymbols Operator
"hi def link larkTemplate Delimiter
