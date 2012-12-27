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
  let scrdown = a:dir == 'd'
  let wlcount = winheight(0) / a:windiv
  let latency = (s:smooth_scroll_latency * a:scale) / 1000

  let cmd = 'normal '
  let cmd .= line('.') != line('w0') ? (scrdown ? "j" : "\<C-Y>") : ''
  let cmd .= line('.') != line('w$') ? (scrdown ? "\<C-E>" : "k") : ''

  let i = 0
  while i < wlcount
    let i += 1
    if scrdown
      if line('w$') == line('$')
        normal G
        break
      endif
    else
      if line('w0') == 1
        normal gg
        break
      endif
    end
    execute cmd
    redraw
    execute 'sleep '.latency.'m'
  endwhile
endfunction

noremap <silent> <C-D> :call SmoothScroll('d', 2, 2)<CR>
noremap <silent> <C-U> :call SmoothScroll('u', 2, 2)<CR>
noremap <silent> <C-F> :call SmoothScroll('d', 1, 1)<CR>
noremap <silent> <C-B> :call SmoothScroll('u', 1, 1)<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
