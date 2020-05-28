
let b:current_syntax = "python"

syn keyword pyKeyword False await else import pass None break except in raise True class finally is return and continue for lambda try as def from nonlocal while assert del global not with async elif if or yield

syn keyword pyBuiltin abs delattr hash memoryview set all dict help min setattr any dir hex next slice ascii divmod id object sorted bin enumerate input oct staticmethod bool eval int open str breakpoint exec isinstance ord sum bytearray filter issubclass pow super bytes float iter print tuple callable format len property type chr frozenset list range vars classmethod getattr locals repr zip compile globals map reversed __import__ complex hasattr max round

syn keyword pySelf self

"syn keyword pyCommentTag TODO NOTE WARNING contained

syn keyword pyBuiltinConstant False True None NotImplemented Ellipsis __debug__

"syn match pyIdentifier /\<[a-zA-Z_][a-zA-Z_0-9]*\>/
syn match pyFunction /\<[a-zA-Z_][a-zA-Z_0-9]*(/me=e-1
syn match pyDecorator /@_(/me=e-1
"syn match pyComment /#.*/ contains=pyCommentTag
syn match pyComment /#.*/

syn match pyLiteral /\<0[oO]\=\o\+[Ll]\=\>/
syn match pyLiteral /\<0[xX]\x\+[Ll]\=\>/
syn match pyLiteral /\<0[bB][01]\+[Ll]\=\>/
syn match pyLiteral /\<\%([1-9]\d*\|0\)[Ll]\=\>/
syn match pyLiteral /\<\d\+[jJ]\>/
syn match pyLiteral /\<\d\+[eE][+-]\=\d\+[jJ]\=\>/
syn match pyLiteral /\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@=/
syn match pyLiteral /\%(^\|\W\)\zs\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>/

syn match pyEscape /\\[\'"abfnrtv]/ contained
syn match pyEscape /\\\o{3}/ contained
syn match pyEscape /\\x\x{2}/ contained
syn match pyEscape /{{/ contained
syn match pyEscape /}}/ contained
syn match pyFormat /{[^{}]*}/ contained

syn region pyString start='"' end='"' contains=pyEscape,pyFormat
syn region pyString start="'" end="'" contains=pyEscape,pyFormat

hi def link pyKeyword Keyword
hi def link pySelf Special
hi def link pyBuiltin Special
hi def link pyBuiltinConstant Constant

hi def link pyIdentifier Identifier
hi def link pyFunction Function
hi def link pyDecorator Function

hi def link pyComment Comment
"hi def link pyCommentTag CommentBright

hi def link pyLiteral Constant
hi def link pyString Constant

hi def link pyEscape Function
hi def link pyFormat Special

