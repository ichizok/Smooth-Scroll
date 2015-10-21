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

function! s:do_smooth_scroll(unitvec, windiv, scale) abort
  if a:unitvec > 0
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

  let amount = (winheight(0) + 1) / a:windiv - 1

  if line(ranges[0]) == bottom
    silent execute 'normal!' amount . movcur
    return
  endif

  let boundln = a:windiv == 1
        \ ? line(ranges[0]) : s:boundary_line(line(ranges[1]), amount . movcur)
  echomsg 'boundln=' . boundln
  let latency = g:smooth_scroll#scroll_latency * a:scale / 1000
  let skiplns = g:smooth_scroll#skip_line_size + 1
  let scrlcmd = line('.') == line(ranges[0]) ? movcur : movcur . scrwin
  let waitcmd = latency > 0 ? 'sleep ' . latency . 'm' : ''

  let done = 0
  let i = 0
  let save_wln = winline()
  let save_col = wincol()

  while !done
    if line(ranges[1]) == boundln
      let done = 1
    endif

    if line(ranges[0]) == bottom
      silent execute 'normal!' (boundln - line('.')) . movcur
      break
    endif

    let diff_wln = winline() - save_wln
    silent execute 'normal!' (diff_wln == 0 ? scrlcmd : scrwin)

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

    if skiplns <= 1 || (i + 1) % skiplns == 0
      redraw
    endif

    let i += 1
  endwhile
endfunction

function! s:smooth_scroll(unitvec, windiv, scale) abort
  let save_cuc = &l:cursorcolumn
  let save_cul = &l:cursorline
  let save_lz = &lazyredraw
  try
    setlocal nocursorcolumn nocursorline
    set lazyredraw

    call s:do_smooth_scroll(a:unitvec, a:windiv, a:scale)
  finally
    let &l:cursorcolumn = save_cuc
    let &l:cursorline = save_cul
    let &lazyredraw = save_lz
  endtry
endfunction

function! smooth_scroll#down(windiv, scale) abort
  call s:smooth_scroll(+1, a:windiv, a:scale)
endfunction

function! smooth_scroll#up(windiv, scale) abort
  call s:smooth_scroll(-1, a:windiv, a:scale)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
