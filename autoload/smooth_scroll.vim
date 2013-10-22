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
" The global variable g:smooth_scroll#scroll_latency changes the scroll speed.
"
"
" Written by Brad Phelan 2006
" http://xtargets.com

let s:save_cpo = &cpo
set cpo&vim

let g:smooth_scroll#scroll_latency = get(g:, 'smooth_scroll#scroll_latency', 5000)
let g:smooth_scroll#skip_line_size = get(g:, 'smooth_scroll#skip_line_size', 0)

function! s:smooth_scroll(dir, windiv, scale)
  let save_cul = &cul
  if save_cul | set nocul | endif

  let wlcount = winheight(0) / a:windiv
  let latency = ((g:smooth_scroll#scroll_latency * a:scale) / 1000) . 'm'
  let skiplns = g:smooth_scroll#skip_line_size + 1

  let pos = a:dir.pos
  let vbl = a:dir.vbl
  let tob = a:dir.tob

  for i in range(1, wlcount)
    if line(vbl) == tob
      execute 'normal' (wlcount - i + 1) . pos
      break
    endif

    execute 'normal' pos

    if i % skiplns == 0
      redraw
    endif

    execute 'sleep' latency
  endfor

  if save_cul | set cul | endif
endfunction

function! smooth_scroll#down(windiv, scale)
  let dir = {
        \   'pos': 'j' . (line('.') != line('w$') ? "\<C-E>" : '')
        \ , 'vbl': 'w$'
        \ , 'tob': line('$')
        \ }
  call s:smooth_scroll(dir, a:windiv, a:scale)
endfunction

function! smooth_scroll#up(windiv, scale)
  let dir = {
        \   'pos': 'k' . (line('.') != line('w0') ? "\<C-Y>" : '')
        \ , 'vbl': 'w0'
        \ , 'tob': 1
        \ }
  call s:smooth_scroll(dir, a:windiv, a:scale)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
