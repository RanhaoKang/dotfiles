" new line 
nnoremap <BS> O<Esc>
nnoremap <CR> o<Esc>
" indent
nnoremap <Tab> >> 
nnoremap <S-Tab> <<
vnoremap <Tab> >>
vnoremap <S-Tab> <<
" Increment / Decrement, it's useful when working on prefabs
nnoremap - <C-X>
nnoremap = <C-A>

call plug#begin()
Plug 'lifepillar/gruvbox8'
Plug 'preservim/nerdtree'
Plug 'yegappan/lsp'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

set number
set mouse=a

" bar cursor in insert mode
let &t_SI = "\e[6 q"
" else steady block
let &t_EI = "\e[2 q"

set lazyredraw
set autoindent

nnoremap <A-1> 1gt
nnoremap <A-2> 2gt
nnoremap <A-3> 3gt
nnoremap <A-4> 4gt
nnoremap <A-5> 5gt
nnoremap <A-6> 6gt
nnoremap <A-7> 7gt
nnoremap <A-8> 8gt
nnoremap <A-9> 9gt 
nnoremap H <C-w>h
nnoremap L <C-w>l

set background=dark
colorscheme gruvbox8
" italics (must be before colorscheme)
let g:gruvbox_italics=0
let g:gruvbox_italicize_strings=0
set termguicolors

let lspOpts = #{autoHighlightDiags: v:true}
autocmd User LspSetup call LspOptionsSet(lspOpts)

let lspServers = [#{
	\	  name: 'luals',
	\	  filetype: ['lua'],
	\	  path: '/usr/bin/lua-language-server',
	\	  args: []
	\ }]
autocmd User LspSetup call LspAddServer(lspServers)
nnoremap <C-p> :Files<CR>

autocmd BufRead,BufNewFile *.lua.txt set filetype=lua
nnoremap KK :vsplit<CR>:LspGotoDefinition<CR>
nnoremap K :LspHover<CR>
" nnoremap KKK :FindMe<CR>

function! FindMe()
	let command = 'fd --type f ' . expand('<cword>') . '|  grep -v meta | grep lua'
	let output = system(command)
	if !empty(output)
        let files = split(trim(output), '\n')
        for file in files
            execute 'silent! botright vnew ' . file
            execute 'silent! setf lua'
        endfor
	endif
endfunction
nnoremap KKK :call FindMe()<CR>

function! PushLSWork(file_path)
    " Debug: Show the file path being processed
    " echo "Processing file: " . a:file_path

    " Construct the command components
    let luacheck_cmd = 'luacheck ' . shellescape(a:file_path) . ' --only 1 --no-color'
    let grep_cmd = "grep 'setting non-standard global variable\\|accessing undefined variable'"
    let awk_cmd = "awk -F\"'\" '{print $2}'"
    let sort_cmd = 'sort'
    let uniq_cmd = 'uniq'
    let fd_cmd = 'xargs -I {} fd {} --type f | grep -v meta | grep lua.txt'

    " Combine the commands into a single command string
    let command = luacheck_cmd . ' | ' . grep_cmd . ' | ' . awk_cmd . ' | ' . sort_cmd . ' | ' . uniq_cmd . ' | ' . fd_cmd

    " Debug: Show the command being executed
    " echo "Executing command: " . command

    " Execute the command and capture the output
    let output = system(command)

    " Debug: Show the raw output
    " echo "Raw output: " . output


    " Display the output
    if !empty(output)
        " Split the output into a list of variable names
        let variable_names = split(output, '\n')

        " Iterate over each variable name
        for path in variable_names
            if !empty(path)
                " echo "kkwtf" . shellescape(path)
                execute 'silent! tabedit ' . path
                execute 'setf lua'
                execute 'silent! tabclose'
            endif
        endfor
    else
        echo "No warnings/errors found."
    endif
endfunction


" autocmd BufRead,BufNewFile *.lua.txt call PushLSWork(expand("%:p"))
