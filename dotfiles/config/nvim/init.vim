" vim-plug *********************************************************************

" Run :PlugInstall after updating this list to install plugins.
call plug#begin(stdpath('data') . '/plugged')
Plug 'junegunn/fzf'
Plug 'neovim/nvim-lspconfig'
Plug 'jackguo380/vim-lsp-cxx-highlight'
call plug#end()

" LSP configs ******************************************************************

lua << EOF
require('lspconfig').ccls.setup {
    init_options = {
        diagnostics = {
            onOpen = 0;
            onSave = 0;
            onChange = 10;
        };
        highlight = { lsRanges = true; };
        index = { comments = 2 };
    };
}

require('lspconfig').pylsp.setup {
}
EOF

" syntax/colors ****************************************************************

set background=dark
hi  clear
if exists("syntax on")
    syntax reset
endif

hi Normal ctermfg=White cterm=none
hi Comment ctermfg=DarkGrey cterm=none
hi Constant ctermfg=DarkRed cterm=none
hi PreProc ctermfg=DarkBlue cterm=none
hi Type ctermfg=DarkMagenta cterm=none
hi Statement ctermfg=DarkMagenta cterm=none
hi Identifier ctermfg=DarkMagenta cterm=none
hi Function	 ctermfg=DarkYellow cterm=none
hi LineNr ctermfg=DarkGrey cterm=none
"hi NonText ctermfg=DarkBlue cterm=none
hi Search ctermfg=White ctermbg=DarkMagenta cterm=none
hi Special ctermfg=DarkCyan cterm=none
"hi CommentBright ctermfg=DarkCyan cterm=none
"hi MoreMsg ctermfg=DarkGreen
"hi StatusLine cterm=reverse
hi MatchParen cterm=underline ctermbg=none
hi Todo ctermfg=3 ctermbg=none cterm=none
hi Error cterm=undercurl ctermfg=9 ctermbg=none
hi Folded ctermfg=DarkGrey ctermbg=Black
hi FoldColumn ctermbg=Black
hi SignColumn ctermbg=Black
hi NormalFloat ctermbg=DarkGrey

hi CursorLine  cterm=none ctermbg=234
hi CursorLineNr cterm=none ctermfg=White ctermbg=234

hi DiagnosticError ctermfg=1 cterm=undercurl
hi DiagnosticWarn ctermfg=3 cterm=undercurl
hi DiagnosticInfo ctermfg=4 cterm=undercurl
hi DiagnosticHint ctermfg=7 cterm=undercurl
hi DiagnosticUnderlineError cterm=undercurl
hi DiagnosticUnderlineWarn cterm=undercurl
hi DiagnosticUnderlineInfo cterm=undercurl
hi DiagnosticUnderlineHint cterm=undercurl

" Unknown
hi LspUnknown ctermbg=Red ctermfg=Black
hi def link LspCxxHlSkippedRegionBeginEnd LspUnknown
hi def link LspCxxHlSymUnknownStaticField LspUnknown

" Variables
hi LspVariable ctermfg=DarkCyan
hi def link LspCxxHlSymVariable LspVariable

" Comment
hi def link LspComment Comment
hi def link LspCxxHlSkippedRegion LspComment

" Meta
hi LspMeta ctermfg=DarkGreen cterm=italic
hi def link LspCxxHlGroupNamespace LspMeta
hi def link LspCxxHlSymNamespace LspMeta

" Macro
hi def link LspMacro PreProc
hi def link LspCxxHlGroupEnumConstant LspMacro
hi def link LspCxxHlSymEnumMember LspMacro
hi def link LspCxxHlSymEnumConstant LspMacro
hi def link LspCxxHlSymMacro LspMacro
hi def link LspCxxHlSymUnknown LspMacro

" Members
hi LspMember ctermfg=DarkCyan cterm=italic
hi def link LspCxxHlGroupMemberVariable LspMember
hi def link LspCxxHlSymField LspMember
hi def link LspCxxHlSymParameter LspMember

" Types
hi def link LspType Type
hi def link LspCxxHlSymPrimitive LspType

" User Types
hi LspUserType ctermfg=DarkGreen
hi def link LspCxxHlSymClass LspUserType
hi def link LspCxxHlSymStruct LspUserType
hi def link LspCxxHlSymEnum LspUserType
hi def link LspCxxHlSymTypeAlias LspUserType
hi def link LspCxxHlSymTypeParameter LspUserType
hi def link LspCxxHlSymTypedef LspUserType
hi def link LspCxxHlSymTemplateParameter LspUserType
hi def link LspCxxHlSymDependentType LspUserType
hi def link LspCxxHlSymConcept LspUserType

" Function
hi LspFunc ctermfg=DarkYellow
hi def link LspCxxHlSymFunction Function
hi def link LspCxxHlSymMethod Function
hi def link LspCxxHlSymStaticMethod Function
hi def link LspCxxHlSymConstructor Function
hi def link LspCxxHlSymDependentName Function

" settings/mappings ************************************************************

let mapleader=","
set autowrite
set number cursorline
set wildmode=longest:list
set expandtab shiftwidth=4 softtabstop=4 tabstop=4
set foldmethod=indent

" easier buffer navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>q :bdelete<CR>
nnoremap <leader>wq :w<CR>:bdelete<CR>

" quickfix
nnoremap <leader>el :cf<CR>
nnoremap <leader>ee :cn<CR>
nnoremap <leader>E :cN<CR>

" use <space> to clear hilight after searching
nnoremap <silent> <Space> :<C-U>noh<CR>:cclose<CR>
"
" remap :tag to :tjump, which prompts for selection when duplicate tags exist
"nnoremap <C-]> g<C-]>

" keep sign column open to avoid it coming and going during editing, which is
" an LSP side effect.
set scl=yes

" LSP **************************************************************************

nnoremap <silent> <leader>d :lua vim.diagnostic.setloclist()<CR>
nnoremap gd     :lua vim.lsp.buf.declaration()<CR>
nnoremap gf     :lua vim.lsp.buf.definition()<CR>
nnoremap K      :lua vim.lsp.buf.hover()<CR>
nnoremap gt     :lua vim.lsp.buf.type_definition()<CR>
nnoremap gr     :lua vim.lsp.buf.references()<CR>

nnoremap g1     :lua vim.lsp.buf.incoming_calls()<CR>
nnoremap g2     :lua vim.lsp.buf.outgoing_calls()<CR>

" clang-format *****************************************************************

nnoremap <silent> <leader>ss :call ClangFormatBuf()<CR>
xnoremap <silent> <leader>s :call ClangFormatRange()<CR>
function ClangFormatRange() range
    execute(a:firstline . ',' . a:lastline . ' !clang-format --style=file --assume-filename=' . expand('%:t'))
endfunction
function ClangFormatBuf()
    let l:view = winsaveview()
    %call ClangFormatRange()
    call winrestview(l:view)
endfunction

" fzf **************************************************************************

nnoremap <silent> <leader>fe :call fzf#run({'down': '30%', 'sink': 'edit'})<CR>
nnoremap <silent> <leader>fb :call fzf#run({'down': '30%', 'source': Bufs(), 'sink': 'buffer', 'options': '--no-multi'})<CR>
nnoremap <silent> <leader>fq :call fzf#run({'down': '30%', 'source': Bufs(), 'sink': 'bdelete'})<CR>

function Bufs()
	" All buffer numbers.
    let l:bufs = range(1, bufnr('$'))

	" Only include visible buffers.
    call filter(l:bufs, 'buflisted(v:val)')

	" Swap out buffer numbers for names to make them more user-friendly.
	" Also strip leading ./ if it exists since it tends to break things.
    call map(l:bufs, 'fnamemodify(bufname(v:val), ":~:.")')

	return l:bufs
endfunction
