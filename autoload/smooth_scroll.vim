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

function! s:boundary_line(baseln, movcur) abort
  let save_pos = getcurpos()
  try
    silent execute a:baseln '| normal!' a:movcur
    return line('.')
  finally
    call setpos('.', save_pos)
  endtry
endfunction

function! s:do_smooth_scroll(params, windiv, scale) abort
  let [movcur, scrwin, ranges, bottom] =
        \  [a:params.movcur, a:params.scrwin, a:params.ranges, a:params.bottom]
  let amount = (winheight(0) + 1) / a:windiv - 1

  if line(ranges[0]) == bottom
    silent execute 'normal!' amount . movcur
    return
  endif

  let boundln = a:windiv == 1
        \ ? line(ranges[0]) : s:boundary_line(line(ranges[1]), amount . movcur)
  let latency = g:smooth_scroll#scroll_latency * a:scale / 1000
  let skiplns = g:smooth_scroll#skip_line_size + 1
  let scrlcmd = line('.') == line(ranges[0]) ? movcur : movcur . scrwin
  let waitcmd = latency > 0 ? 'sleep ' . latency . 'm' : ''

  let done = 0
  let i = 0
  let save_wln = winline()

  while !done
    if line(ranges[1]) == boundln
      let done = 1
    endif

    if line(ranges[0]) == bottom
      silent execute 'normal!' (boundln - line('.')) . movcur
      break
    endif

    let diffln = winline() - save_wln
    silent execute 'normal!' (diffln == 0 ? scrlcmd : scrwin)

    if done && diffln != 0
      silent execute 'normal!' abs(diffln) . (diffln < 0 ? 'gj' : 'gkgk')
    endif

    if skiplns <= 1 || (i + 1) % skiplns == 0
      redraw
    endif

    silent execute waitcmd

    let i += 1
  endwhile
endfunction

function! s:smooth_scroll(params, windiv, scale) abort
  let save_cuc = &l:cursorcolumn
  let save_cul = &l:cursorline
  let save_lz = &lazyredraw
  try
    setlocal nocursorcolumn nocursorline
    set lazyredraw

    call s:do_smooth_scroll(a:params, a:windiv, a:scale)
  finally
    let &l:cursorcolumn = save_cuc
    let &l:cursorline = save_cul
    let &lazyredraw = save_lz
  endtry
endfunction

function! smooth_scroll#down(windiv, scale) abort
  let params = {
        \   'movcur': 'gj'
        \ , 'scrwin': "\<C-E>"
        \ , 'ranges': ['w$', 'w0']
        \ , 'bottom': line('$')
        \ }
  call s:smooth_scroll(params, a:windiv, a:scale)
endfunction

function! smooth_scroll#up(windiv, scale) abort
  let params = {
        \   'movcur': 'gk'
        \ , 'scrwin': "\<C-Y>"
        \ , 'ranges': ['w0', 'w$']
        \ , 'bottom': 1
        \ }
  call s:smooth_scroll(params, a:windiv, a:scale)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
