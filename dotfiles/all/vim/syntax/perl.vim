so $VIMRUNTIME/syntax/perl.vim

syn match   perlVarCurly    /[$@%]{[a-zA-Z_]\+}/
syn cluster perlInterpDQ	contains=perlSpecialString,perlVarPlain,perlVarNotInMatches,perlVarSlash,perlVarBlock,perlVarCurly
hi def link perlVarCurly perlVarPlain

