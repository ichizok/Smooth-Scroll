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

function! s:do_smooth_scroll(amount, scale) abort
  if a:amount > 0
    let movcur = 'gj'
    let scrwin = "\<C-E>"
    let ranges = ['w$', 'w0']
    let bottom = line('$')
  else
    let movcur = 'gk'
    let scrwin = "\<C-Y>"
    let ranges = ['w0', 'w$']
    let bottom = 1
  endif

  if line(ranges[0]) == bottom
    silent execute 'normal!' (a:amount > 0 ? a:amount : -a:amount) . movcur
    return
  endif

  let boundln = line(ranges[1]) + a:amount
  if a:amount > 0 ? bottom < boundln : bottom > boundln
    let boundln = bottom
  endif
  echom printf('boundln=%d', boundln)

  let latency = g:smooth_scroll#scroll_latency * a:scale / 1000
  let skiplns = g:smooth_scroll#skip_line_size + 1
  let scrlcmd = line('.') == line(ranges[0]) ? movcur : movcur . scrwin
  let waitcmd = latency > 0 ? 'sleep ' . latency . 'm' : ''

  let done = 0
  let k = 0
  let save_wln = winline()
  let save_col = wincol()

  while !done
    if line(ranges[0]) == bottom
      silent execute 'normal!' (boundln - line('.')) . movcur
      break
    endif

    let diff_wln = winline() - save_wln
    silent execute 'normal!' (diff_wln == 0 ? scrlcmd : scrwin)

    if a:amount > 0 ? line(ranges[1]) >= boundln : line(ranges[1]) <= boundln
      let done = 1
    endif

    if !done
      silent execute waitcmd
    else
      let diff_wln = winline() - save_wln
      if diff_wln != 0
        silent execute 'normal!' abs(diff_wln) . (diff_wln < 0 ? 'gj' : 'gk')
      endif
      let diff_col = wincol() - save_col
      if diff_col != 0
        silent execute 'normal!' abs(diff_col) . (diff_col < 0 ? 'l' : 'h')
      endif
    endif

    if skiplns <= 1 || (k + 1) % skiplns == 0
      redraw
    endif

    let k += 1
  endwhile
endfunction

function! s:smooth_scroll(amount, scale) abort
  if a:amount == 0
    return
  endif

  let save_cuc = &l:cursorcolumn
  let save_cul = &l:cursorline
  let save_lz = &lazyredraw
  try
    setlocal nocursorcolumn nocursorline
    set lazyredraw

    call s:do_smooth_scroll(a:amount, a:scale)
  finally
    let &l:cursorcolumn = save_cuc
    let &l:cursorline = save_cul
    let &lazyredraw = save_lz
  endtry
endfunction

function! smooth_scroll#down(windiv, scale) abort
  let amount = (winheight(0) + 1) / a:windiv - 1
  call s:smooth_scroll(+amount, a:scale)
endfunction

function! smooth_scroll#up(windiv, scale) abort
  let amount = (winheight(0) + 1) / a:windiv - 1
  call s:smooth_scroll(-amount, a:scale)
endfunction

function! smooth_scroll#by(amount, scale, ...) abort
  if a:0 && a:1
    let &l:scroll = a:amount > 0 ? a:amount : -a:amount
  endif
  call s:smooth_scroll(a:amount, a:scale)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
