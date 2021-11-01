
let b:current_syntax = "ref_trace"

"syn keyword pyKeyword False await else import pass None break except in raise True class finally is return and continue for lambda try as def from nonlocal while assert del global not with async elif if or yield

syn match trLit /0x[0-9a-fA-F]\+/
syn match trErr /<err>/
syn match trWrn /<wrn>/
syn match trRef /\w*ref_inline/
syn match trZSmp /zsmp_\w\+/

syn match trSmp1 /smp_bt_ud_\w\+/
syn match trSmp2 /smp_process_\w\+/

syn match trNb1 /net_buf_alloc\w*/
syn match trNb2 /net_buf_ref\w*/
syn match trNb3 /net_buf_unref\w*/

hi def trLit ctermfg=DarkYellow
hi def trErr ctermfg=DarkRed
hi def trWrn ctermfg=DarkYellow
hi def trRef ctermfg=DarkMagenta
hi def trZSmp ctermfg=DarkBlue

hi def trSmp1 ctermfg=DarkGreen
hi def trSmp2 ctermfg=DarkGreen

hi def trNb1 ctermfg=DarkCyan
hi def trNb2 ctermfg=DarkCyan
hi def trNb3 ctermfg=DarkCyan

