###
  lib/scroll.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, scroll:'].concat args

module.exports =

  chkScroll: (event, e) ->   
    # log @map
    # @stopTracking()
     
    if not @editor.alive then @stopTracking(); return
    
    switch event
      when 'init'
        scrnTopRow = @editorView.getFirstVisibleScreenRow()
        scrnBotRow = @editorView.getLastVisibleScreenRow()
        cursorRow  = @editor.getCursorScreenPosition()
        if scrnTopRow <= cursorRow <= scrnBotRow 
             @setScroll cursorRow  * @chrHgt
        else @setScroll scrnTopRow * @chrHgt
          
      when 'changed', 'cursorMoved'
        @setScroll @editor.getCursorScreenPosition() * @chrHgt
      
      when 'newtop'
        scrollTop = @previewEle.scrollTop
        @lastScrollTop ?= scrollTop
        if scrollTop < @lastScrollTop
          @setScroll @editorView.getFirstVisibleScreenRow() * @chrHgt
        else if scrollTop > @lastScrollTop 
          @setScroll @editorView.getLastVisibleScreenRow() * @chrHgt
        @lastScrollTop = scrollTop
  
  setScroll: (scrnPosPix) ->
    scrlTop = Math.max 0, scrlTop
    lastMapping = null
    for mapping, idx in @map
      [topPix, botPix, topRow, botRow] = mapping
      if scrlTop < topRow * @chrHgt
        row1 = lastMapping[3] + 1
        row2 = topRow
        pix1 = lastMapping[1]
        pix2 = topPix
      else if scrlTop < (botRow+1) * @chrHgt
        row1 = rowTop
        row2 = botRow + 1
        pix1 = topPix
        pix2 = botPix
      else
        continue
        
    scrnTopRow     = @editorView.getFirstVisibleScreenRow()
    scrnTopSpanRow = row1
    scrnSpanHgtRow = (row2 - row1)
    spanFrac       = Math.max 0, Math.min 1, 
        (scrnPosPix - scrnTopSpanRow * @chrHgt) / (scrnSpanHgtRow * @chrHgt)
        
    pvwPosPix = pix1 + (pix2 - pix1) * spanFrac
    visOfs    = scrnPosPix - scrnTopRow * @chrHgt
    @previewEle.scrollTop = pvwPosPix - visOfs
      
