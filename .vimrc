" use vscodevim instead of vim
noremap <CR> i

noremap i <Esc><Up>
noremap j <Esc><Left>
noremap k <Esc><Down>
noremap l <Esc><Right>

nnoremap J v<Left>
vnoremap J <Left>
nnoremap L v<Right>
vnoremap L <Right>
nnoremap I v<Up>
vnoremap I <Up>
nnoremap K v<Down>
vnoremap K <Down>

noremap s <Nop>
noremap w <Nop>
noremap a <Nop>
" noremap d <Nop>