so $VIMRUNTIME/syntax/c.vim

syn match cVarKyle  /[a-zA-Z_]\w*/
syn match cFuncKyle /[a-zA-Z_]\w\+\s*\ze(/
syn match cPreProc  /^\s*#\w\+/
syn match cDoxy contained /@\w\+/

hi def link cVarKyle Identifier
hi def link cFuncKyle Function
hi def link cPreProc PreProc
hi def link cDoxy CommentBright

syn cluster cCommentGroup add=cDoxy

