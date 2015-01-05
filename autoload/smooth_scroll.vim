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

function! s:smooth_scroll(params, windiv, scale)
  let save_cul = &l:cursorline
  setlocal nocursorline

  let wlcount = winheight(0) / a:windiv
  let latency = g:smooth_scroll#scroll_latency * a:scale / 1000
  let skiplns = g:smooth_scroll#skip_line_size + 1
  let waitcmd = latency > 0 ? 'sleep ' . latency . 'm' : ''

  let [mvc, scw, vbl, tob] = [a:params.mvc, a:params.scw, a:params.vbl, a:params.tob]

  for i in range(1, wlcount)
    if line(vbl) == tob
      silent execute 'normal!' (wlcount - i + 1) . mvc
      break
    endif

    silent execute 'normal!' mvc . scw

    if i % skiplns == 0
      redraw
    endif

    silent execute waitcmd
  endfor

  let &l:cursorline = save_cul
endfunction

function! smooth_scroll#down(windiv, scale)
  let params = {
        \   'mvc': 'gj'
        \ , 'scw': "\<C-E>"
        \ , 'vbl': 'w$'
        \ , 'tob': line('$')
        \ }
  call s:smooth_scroll(params, a:windiv, a:scale)
endfunction

function! smooth_scroll#up(windiv, scale)
  let params = {
        \   'mvc': 'gk'
        \ , 'scw': "\<C-Y>"
        \ , 'vbl': 'w0'
        \ , 'tob': 1
        \ }
  call s:smooth_scroll(params, a:windiv, a:scale)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
