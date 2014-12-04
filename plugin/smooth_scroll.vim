" vim-smooth-scroll
"
" Remaps
"  <C-U>
"  <C-D>
"  <C-F>
"  <C-B>
"
" to allow smooth scrolling of the window. I find that quick changes of
" context don't allow my eyes to follow the action properly.
"
" The global variable g:smooth_scroll_latency changes the scroll speed.
"
"
" Written by Brad Phelan 2006
" http://xtargets.com

if exists('g:loaded_smooth_scroll')
  finish
endif
let g:loaded_smooth_scroll = 1

let s:save_cpo = &cpo
set cpo&vim

" Interfaces.
nnoremap <silent> <script> <Plug>(smooth-scroll-down-full) :call smooth_scroll#down(1, 1)<CR>
nnoremap <silent> <script> <Plug>(smooth-scroll-up-full)   :call smooth_scroll#up(1, 1)<CR>
nnoremap <silent> <script> <Plug>(smooth-scroll-down-half) :call smooth_scroll#down(2, 2)<CR>
nnoremap <silent> <script> <Plug>(smooth-scroll-up-half)   :call smooth_scroll#up(2, 2)<CR>

" Default mappings.
if !get(g:, 'smooth_scroll_no_default_key_mappings', 0)
  if !hasmapto('<Plug>(smooth-scroll-down-full)')
    nmap <silent> <unique> <C-F> <Plug>(smooth-scroll-down-full)
  endif
  if !hasmapto('<Plug>(smooth-scroll-up-full)')
    nmap <silent> <unique> <C-B> <Plug>(smooth-scroll-up-full)
  endif
  if !hasmapto('<Plug>(smooth-scroll-down-half)')
    nmap <silent> <unique> <C-D> <Plug>(smooth-scroll-down-half)
  endif
  if !hasmapto('<Plug>(smooth-scroll-up-half)')
    nmap <silent> <unique> <C-U> <Plug>(smooth-scroll-up-half)
  endif
endif

let &cpo = s:save_cpo
unlet s:save_cpo
