
let b:current_syntax = "phx"

"syn keyword pyKeyword False await else import pass None break except in raise True class finally is return and continue for lambda try as def from nonlocal while assert del global not with async elif if or yield

syn match phxErr /<err>.*$/
syn match phxWrn /<wrn>.*$/

syn match phxNRF /^nRF:.*$/
syn match phxSTM /^STM:.*$/

hi def phxErr ctermfg=DarkRed
hi def phxWrn ctermfg=DarkYellow

hi def phxNRF ctermbg=DarkGreen
hi def phxSTM ctermbg=DarkBlue
