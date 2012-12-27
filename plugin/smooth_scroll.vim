" Smooth Scroll
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

if !exists('g:smooth_scroll_latency')
      \ || type(g:smooth_scroll_latency) != type(0)
  let s:smooth_scroll_latency = 5000
else
  let s:smooth_scroll_latency = g:smooth_scroll_latency
endif

function! SmoothScroll(dir, windiv, scale)
  let save_cul = &cul
  if save_cul | set nocul | endif

  let scrdown = a:dir == 'd'
  let wlcount = winheight(0) / a:windiv
  let latency = (s:smooth_scroll_latency * a:scale) / 1000

  let cmd = 'normal '
  if scrdown
    let cmd .= line('.') != line('w0') ? "j" : ''
    let cmd .= line('.') != line('w$') ? "\<C-E>" : ''
    let mov = 'j'
    let vbl = 'w$'
    let tob = line('$')
  else
    let cmd .= line('.') != line('w0') ? "\<C-Y>" : ''
    let cmd .= line('.') != line('w$')
          \ || line('w0') == line('w$') ? "k" : ''
    let mov = 'k'
    let vbl = 'w0'
    let tob = 1
  endif
  let slp = 'sleep '.latency.'m'

  let i = 0
  while i < wlcount
    let i += 1
    if line(vbl) == tob
      execute 'normal '.(wlcount - i).mov
      break
    endif
    execute cmd
    redraw
    execute slp
  endwhile

  if save_cul | set cul | endif
endfunction

noremap <silent> <C-D> :call SmoothScroll('d', 2, 2)<CR>
noremap <silent> <C-U> :call SmoothScroll('u', 2, 2)<CR>
noremap <silent> <C-F> :call SmoothScroll('d', 1, 1)<CR>
noremap <silent> <C-B> :call SmoothScroll('u', 1, 1)<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
