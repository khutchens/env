
let b:current_syntax = "zephyr_conf"

"syn keyword pyKeyword False await else import pass None break except in raise True class finally is return and continue for lambda try as def from nonlocal while assert del global not with async elif if or yield

syn match zconfComment /#.*/

"syn keyword zconfTag CONFIG_ contained nextgroup=zconfLabel
syn match zconfTag /\<CONFIG_/ nextgroup=zconfLabel
syn match zconfLabel /\w\+/ contained nextgroup=zconfAssign
syn match zconfAssign /=/ contained nextgroup=zconfBoolT,zconfBoolF,zconfString
syn match zconfBoolT /\<y\>/ contained
syn match zconfBoolF /\<n\>/ contained
"syn region zconfString start='"' end='"' contained
"syn region zconfString start='"' end='"' contained

hi def link zconfComment Comment
hi def link zconfBoolT Pass
hi def link zconfBoolF Fail
hi def link zconfString String
hi def link zconfTag Folded
hi def link zconfLabel Function
hi def link zconfAssign Folded

"hi def link zconfStatement CommentBright


