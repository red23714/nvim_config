" ----------------- Основные настройки -----------------
set nocompatible
set encoding=UTF-8
set number relativenumber
set cursorline
set tabstop=4 shiftwidth=4 expandtab
set smarttab
set mouse=a
set hlsearch incsearch ignorecase
set showcmd showmode showmatch
set wrap
set splitbelow splitright
set wildmenu
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set nobackup
set undodir=~/.vim/backup
set undofile
set history=1000

" Разрешить переключение между буферами с несохраненными изменениями
set hidden

" ----------------- Настройки курсора -----------------
let &t_SI = "\e[6 q"  " Тонкая линия в insert mode
let &t_SR = "\e[4 q"  " Подчеркивание в replace mode
let &t_EI = "\e[2 q"  " Блок в normal mode

autocmd InsertEnter * set nocursorline
autocmd InsertLeave * set cursorline

" ----------------- Плагины -----------------
call plug#begin('~/.vim/plugged')

Plug 'ghifarit53/tokyonight-vim'              " Цветовая тема
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'bling/vim-bufferline'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'voldikss/vim-floaterm'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

let mapleader=" "

" ----------------- Цвета -----------------
colorscheme tokyonight
let g:airline_theme='dark'
let g:airline_powerline_fonts=1

" ----------------- FZF -----------------
" Настройки для центрированного окна
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.6, 'yoffset': 0.5, 'xoffset': 0.5, 'relative': 'editor', 'border': 'rounded' } }

" Настройки для навигации по списку
let g:fzf_buffers_jump = 1  " Переходить к буферу если он уже открыт

" Опции для всех команд FZF по умолчанию
let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline --bind "tab:down,shift-tab:up,ctrl-j:down,ctrl-k:up"'

" Кастомные команды FZF с правильным поведением
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview-window=right:50%']}, <bang>0)

command! -bang -nargs=? -complete=dir GFiles
    \ call fzf#vim#gitfiles(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview-window=right:50%']}, <bang>0)

" Маппинги для FZF
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :History<CR>

" Навигация по результатам FZF с помощью Tab/Shift-Tab
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" ----------------- NERDTree -----------------
nnoremap <C-n> :NERDTreeToggle<CR>
let g:NERDTreeShowHidden=1

" ----------------- Комментарии -----------------
nnoremap <leader>/ :normal gcc<CR>
vnoremap <leader>/ :normal gc<CR>

" ----------------- Вкладки и буферы (исправлено для несохраненных файлов) -----------------
" Используем :bnext и :bprevious вместо :tabnext для переключения между буферами
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" Альтернативные маппинги для переключения вкладок (если нужны именно вкладки)
nnoremap <leader><Tab> :tabnext<CR>
nnoremap <leader><S-Tab> :tabprevious<CR>

" Создание новой вкладки
nnoremap <leader>c :tabnew<CR>

" Закрытие буфера/вкладки
nnoremap <leader>x :bd<CR>

" ----------------- Airline вкладки -----------------
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#switch_buffers_and_tabs = 1  " Позволяет переключаться между буферами

" ----------------- Airline -----------------
let g:airline_theme='tokyonight'
let g:airline_powerline_fonts=1

" ----------------- Floaterm -----------------
nnoremap <silent> <leader>tt :FloatermToggle<CR>
let g:floaterm_position='center'
let g:floaterm_width=0.85
let g:floaterm_height=0.75

" ----------------- LSP (coc.nvim) -----------------
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <leader>rn <Plug>(coc-rename)
nnoremap <leader>ca <Plug>(coc-codeaction)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Автодополнение coc.nvim
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
inoremap <silent><expr> <C-Space> coc#refresh()

autocmd InsertLeave * if coc#pum#visible() | call coc#pum#close() | endif

" ----------------- Спеллчек -----------------
nnoremap <C-z> :setlocal spell! spelllang=en_us<CR>

" ----------------- Навигация по сплитам -----------------
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
noremap <a-up> <c-w>+
noremap <a-down> <c-w>-
noremap <a-left> <c-w>>
noremap <a-right> <c-w><

" ----------------- Сохранение и выход -----------------
nnoremap <C-s> :w<CR>
nnoremap <C-q> :wq<CR>

" ----------------- Дополнительно -----------------
nnoremap <leader>a ggVG
nnoremap <leader>sw <cmd>echo "Press a char: " \| let c=nr2char(getchar()) \| exec "normal viwo\ei".c."\eea".c."\e" \| redraw<CR>
nnoremap <leader>rw :%s/\<<c-r><c-w>\>//g<left><left>
nnoremap <leader>ht <cmd>call ToggleHebrew()<CR>
nnoremap <leader>hx <cmd>call HexState()<CR>noremap <leader>hx <cmd>call HexState()<CR>
