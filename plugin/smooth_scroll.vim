" Smooth Scroll
"
" Remamps 
"  <C-U>
"  <C-D>
"  <C-F>
"  <C-B>
"
" to allow smooth scrolling of the window. I find that quick changes of
" context don't allow my eyes to follow the action properly.
"
" The global variable g:scroll_factor changes the scroll speed.
"
"
" Written by Brad Phelan 2006
" http://xtargets.com
let g:scroll_factor = 5000
function! SmoothScroll(dir, windiv, factor)
   let wh=winheight(0)
   let i=0
   while i < wh / a:windiv
      let t1=reltime()
      let i = i + 1
      if a:dir=="d"
         normal 
		 if line(".") != line("w$")
			 normal j
		 endif
      else
         normal 
		 if line("w0") != 1
			 normal k
		 endif
      end
      redraw
      while 1
         let t2=reltime(t1,reltime())
         if t2[1] > g:scroll_factor * a:factor
            break
         endif
      endwhile
   endwhile
endfunction
noremap <silent> <C-D> :call SmoothScroll("d",2, 2)<CR>
noremap <silent> <C-U> :call SmoothScroll("u",2, 2)<CR>
noremap <silent> <C-F> :call SmoothScroll("d",1, 1)<CR>
noremap <silent> <C-B> :call SmoothScroll("u",1, 1)<CR>
