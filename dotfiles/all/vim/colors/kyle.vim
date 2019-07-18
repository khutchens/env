set background=dark
hi  clear

if exists("syntax on")
    syntax reset
endif

" My syntax colors
hi  Normal      ctermfg=White   cterm=none
hi  Comment     ctermfg=DarkBlue    cterm=none
hi  Constant    ctermfg=DarkRed cterm=none
hi  Type        ctermfg=DarkMagenta cterm=none
hi  PreProc     ctermfg=DarkMagenta cterm=none
hi  Statement   ctermfg=DarkMagenta cterm=none
hi  Identifier  ctermfg=DarkGreen   cterm=none
hi  Function	ctermfg=3           cterm=none
hi  LineNr      ctermfg=DarkGrey    cterm=none
hi  NonText     ctermfg=DarkBlue    cterm=none
hi  Search      ctermfg=White ctermbg=DarkMagenta  cterm=none
hi  Special     ctermfg=3           cterm=none

hi  CommentBright ctermfg=DarkCyan cterm=none

" Copied from standard colors for quick modification
"hi SpecialKey     term=bold cterm=bold ctermfg=4 guifg=Cyan
"hi NonText        term=bold ctermfg=4 gui=bold guifg=#2e69c1
"hi Directory       ctermfg=DarkCyan guifg=DarkCyan
"hi ErrorMsg       term=standout cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
"hi IncSearch      term=reverse cterm=reverse gui=reverse
"hi Search         term=reverse cterm=bold ctermfg=7 ctermbg=5 guifg=#ffffff guibg=Yellow
hi MoreMsg         ctermfg=DarkGreen
"hi ModeMsg        term=bold cterm=bold gui=bold
"hi LineNr         term=underline cterm=bold ctermfg=0 guifg=#333333
"hi Question       term=standout cterm=bold ctermfg=2 gui=bold guifg=Green
hi StatusLine     cterm=reverse
"hi StatusLineNC   term=reverse cterm=reverse gui=reverse
"hi VertSplit      term=reverse cterm=reverse gui=reverse
"hi Title          term=bold cterm=bold ctermfg=5 gui=bold guifg=Magenta
"hi Visual         term=reverse cterm=reverse guibg=DarkGrey
"hi VisualNOS      term=bold,underline cterm=underline gui=bold,underline
"hi WarningMsg     term=standout cterm=bold ctermfg=1 guifg=Red
"hi WildMenu       term=standout ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
hi Folded         ctermfg=DarkGrey ctermbg=none
"hi FoldColumn     term=standout cterm=bold ctermfg=6 ctermbg=0 guifg=Cyan guibg=Grey
"hi DiffAdd        term=bold ctermbg=4 guibg=DarkBlue
"hi DiffChange     term=bold ctermbg=5 guibg=DarkMagenta
"hi DiffDelete     term=bold cterm=bold ctermfg=4 ctermbg=6 gui=bold guifg=Blue guibg=DarkCyan
"hi DiffText       term=reverse cterm=bold ctermbg=1 gui=bold guibg=Red
"hi SignColumn     term=standout cterm=bold ctermfg=6 ctermbg=0 guifg=Cyan guibg=Grey
"hi SpellBad       term=reverse ctermbg=1 gui=undercurl guisp=Red
"hi SpellCap       term=reverse ctermbg=4 gui=undercurl guisp=Blue
"hi SpellRare      term=reverse ctermbg=5 gui=undercurl guisp=Magenta
"hi SpellLocal     term=underline ctermbg=6 gui=undercurl guisp=Cyan
"hi Pmenu          ctermbg=5 guibg=Magenta
"hi PmenuSel       ctermbg=0 guibg=DarkGrey
"hi PmenuSbar      ctermbg=7 guibg=Grey
"hi PmenuThumb     cterm=reverse gui=reverse
"hi CursorColumn   term=reverse ctermbg=0 guibg=Grey40
"hi CursorLine     term=underline cterm=underline guibg=Grey40
"hi ColorColumn    term=reverse ctermbg=1 guibg=DarkRed
hi MatchParen     cterm=underline ctermbg=none
"hi Underlined     term=underline cterm=bold,underline ctermfg=4 gui=underline guifg=#80a0ff
"hi Ignore         ctermfg=0 guifg=bg
"hi Error          term=reverse cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
hi Todo           ctermfg=3 ctermbg=none cterm=none

let colors_name="kyle"

