" vim-plug *********************************************************************

" Run :PlugInstall after updating this list to install plugins.
call plug#begin(stdpath('data') . '/plugged')
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'junegunn/fzf'
Plug 'khutchens/colorful.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'weilbith/nvim-lsp-smag'
call plug#end()

" LSP configs ******************************************************************

lua << EOF
local util = require 'lspconfig.util'
require('lspconfig').ccls.setup {
    init_options = {
        diagnostics = {
            onOpen = 0;
            onSave = 0;
            onChange = 10;
        };
        highlight = { lsRanges = true; };
        index = { comments = 2 };
        cache = { directory = ''; };
    };
    -- Don't treat git submodules as new CCLS trees.
    root_dir = util.root_pattern('compile_commands.json', '.ccls');
}

require('lspconfig').pylsp.setup {
}
EOF

" syntax/colors ****************************************************************

colorscheme colorful
hi Visual ctermbg=black cterm=reverse

" settings/mappings ************************************************************

let mapleader=","
set autowrite
set number cursorline
set wildmode=longest:list
set expandtab shiftwidth=4 softtabstop=4 tabstop=4
set scrolloff=5

" folding
set foldmethod=indent
set foldcolumn=1
"set foldminlines=2
set foldnestmax=1
set foldopen-=block
set foldopen-=search
set foldopen-=hor

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

" LSP
nnoremap <silent> <leader>d :lua vim.diagnostic.setloclist()<CR>
nnoremap K :lua vim.lsp.buf.hover()<CR>

" keep sign column open to avoid it coming and going during editing, which is
" an LSP side effect.
set scl=yes

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

nnoremap <silent> <leader>fe :call fzf#run({'down': '30%', 'sink': 'edit', 'options': '--multi'})<CR>
nnoremap <silent> <leader>fb :call fzf#run({'down': '30%', 'source': Bufs(), 'sink': 'buffer'})<CR>
nnoremap <silent> <leader>fq :call fzf#run({'down': '30%', 'source': Bufs(), 'sink': 'bdelete', 'options': '--multi'})<CR>

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

" filetypes ********************************************************************

function AutoFold()
    if line('$') > &lines - 2
        :set foldlevel=0
    else
        :set foldlevel=1
    endif
endfunction
au BufNewFile,BufRead *.openocd setf tcl
au BufNewFile,BufRead *.expect setf expect
au BufNewFile,BufRead * :call AutoFold()
