-- Plugins -------------------------------------------------------------------------------------------------------------

require 'paq' {
    'savq/paq-nvim';
    'junegunn/fzf';
    'khutchens/colorful.vim';
    'neovim/nvim-lspconfig';
}

-- Options, settings, mappings, auto-commands --------------------------------------------------------------------------

vim.cmd('colorscheme colorful')
vim.cmd('hi Visual ctermbg=black cterm=reverse')

vim.g.mapleader = ','

vim.opt.autowrite   = false
vim.opt.wildmode    = 'longest:list'
vim.opt.scrolloff   = 5
vim.opt.mouse       = ''

vim.opt.number      = true
vim.opt.cursorline  = true

vim.opt.expandtab   = true
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = 4
vim.opt.tabstop     = 4

vim.opt.foldmethod        = 'indent'
vim.opt.foldcolumn        = '1'
vim.opt.foldnestmax       = 1
vim.opt.foldlevelstart    = 2
vim.opt.foldopen = vim.opt.foldopen - {'block', 'search', 'hor'}

vim.g.scl = true -- keep sign column open to avoid it coming and going during editing, which is an LSP side effect.

-- Buffer navigation
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>q', ':bdelete<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>wq', ':w<CR>:bdelete<CR>', {noremap = true})

-- quickfix
vim.api.nvim_set_keymap('n', '<leader>el', ':cf<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ee', ':cn<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>E', ':cN<CR>', {noremap = true})

-- use <space> to clear hilight after searching
vim.api.nvim_set_keymap('n', '<Space>', ':<C-U>noh<CR>:cclose<CR>', {noremap = true, silent = true})

-- LSP
vim.api.nvim_set_keymap('n', '<leader>d', ':lua vim.diagnostic.setloclist()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})

--local lspconfig = require'lspconfig'
--lspconfig.ccls.setup {
--    --init_options = {
--    --    diagnostics = {
--    --        onOpen = 0;
--    --        onSave = 0;
--    --        onChange = 10;
--    --    };
--    --    highlight = { lsRanges = true; };
--    --    index = { comments = 2 };
--    --    cache = { directory = ''; };
--    --};
--    -- Don't treat git submodules as new CCLS trees.
--    --root_dir = lspconfig.util.root_pattern('compile_commands.json', '.ccls');
--}

--local myluafun = function() print("This buffer enters") end
--vim.lsp.start({
--    name = 'my-server-name',
--    cmd = {'name-of-language-server-executable'},
--    root_dir = vim.fs.dirname(vim.fs.find({'pyproject.toml', 'setup.py'}, { upward = true })[1]),
--})
--vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--    pattern = {"*.c", "*.h"},
--    callback = myluafun,  -- Or myvimfun
--})
--local cpp_lsp_cb = function()
--    vim.lsp.start({
--        name = 'c++',
--        cmd = {'ccls', '-v=2', '--log-file=/Users/kyle/ccls.log'},
--        root_dir = vim.fs.dirname(vim.fs.find({'compile_commands.json', '.ccls'}, { upward = true })[1]),
--    })
--end
--vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {pattern={'*.cc'}, callback=cpp_lsp_cb})

-- CCLS init options are supplied as a JSON string
--local ccls_init_options = [[
----init={
--    "diagnostics":  { "onOpen": 0, "onSave": 0, "onChange": 10 },
--    "highlight": { "lsRanges": true },
--    "index": { "comments": 2 },
--    "cache": { "directory": "" }
--}
--]]
--
--function start_ccls()
--    vim.lsp.start({
--        name = 'c++',
--        cmd = {'ccls', '-v=2', '--log-file=/Users/kyle/ccls.log', ccls_init_options},
--        root_dir = vim.fs.dirname(vim.fs.find({'compile_commands.json', '.ccls'}, { upward = true })[1]),
--    })
--end
--
--vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {pattern={'*.cc', '*.cpp', '*.c', '*.hpp', '*.h'}, callback=start_ccls })

--autocmd BufNewFile,BufRead *.cc,*.cpp,*.hpp,*.c,*.h
--
--   lua vim.lsp.start({
--       name = 'c++',
--       cmd = {'ccls', '--log-file=/tmp/ccls.log'},
--       root_dir = vim.fs.dirname(
--           vim.fs.find(
--               {'compile_commands.json', '.ccls'},
--               { upward = true }
--           )[1]
--       )
--   })

--lua << EOF
--local util = require 'lspconfig.util'
--require('lspconfig').ccls.setup {
--    init_options = {
--        diagnostics = {
--            onOpen = 0;
--            onSave = 0;
--            onChange = 10;
--        };
--      highlight = { lsRanges = true; };
--        index = { comments = 2 };
--        cache = { directory = ''; };
--    };
--    -- Don't treat git submodules as new CCLS trees.
--    root_dir = util.root_pattern('compile_commands.json', '.ccls');
--}

-- fzf
local fzf_source_file = io.open("source.fzf", "r")
if fzf_source_file == nil then
    vim.api.nvim_set_keymap('n', '<leader>fe', ":call fzf#run({'down': '30%', 'sink': 'edit', 'options': '--multi'})<CR>", {noremap = true, silent = true})
else
    fzf_source_cmd = fzf_source_file:read("*all"):gsub('\'', '\\\''):gsub('%c', '')
    local call_cmd = string.format(":call fzf#run({'down': '30%%', 'source': '%s', 'sink': 'edit', 'options': '--multi'})<CR>", fzf_source_cmd)
    vim.api.nvim_set_keymap('n', '<leader>fe', call_cmd, {noremap = true, silent = true})
    fzf_source_file:close() 
end
vim.api.nvim_set_keymap('n', '<leader>fb', ":call fzf#run({'down': '30%', 'source': v:lua.GetListedBuffersByName(), 'sink': 'buffer'})<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fq', ":call fzf#run({'down': '30%', 'source': v:lua.GetListedBuffersByName(), 'sink': 'bdelete', 'options': '--multi'})<CR>", {noremap = true, silent = true})

-- clang-format
vim.api.nvim_set_keymap('n', '<leader>ss', ':ClangFormat<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', '<leader>s', ':ClangFormat<CR>', {noremap = true, silent = true})

-- File types
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {pattern='*.openocd', command='setf tcl'})
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {pattern='*.expect', command='setf expect'})

-- Helper functions and commands ---------------------------------------------------------------------------------------

-- Get list of currently open buffers by name
function GetListedBuffersByName()
    local buffers = {}

    for buffer = 1, vim.fn.bufnr('$') do
        if vim.fn.buflisted(buffer) == 1 then
            local buffer_name = vim.fn.bufname(buffer)
            local modified_name = vim.fn.fnamemodify(buffer_name, ':~:.')
            table.insert(buffers, modified_name)
        end
    end

    return buffers
end

-- Filter range through clang-format
vim.api.nvim_create_user_command('ClangFormat', 
    function(args)
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.cmd(args.line1 .. ',' .. args.line2 .. ' !clang-format --style=file --assume-filename=' .. vim.fn.expand('%:t'))
        vim.api.nvim_win_set_cursor(0, cursor)
    end, {range='%'})
