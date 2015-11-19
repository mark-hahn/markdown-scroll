###
  lib/scroll.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, scroll:'].concat args

module.exports =
  
  chkScroll: (event, e) -> 
    @getVisTopHgtBot()
    
    if @scrnTopOfs    isnt @lastScrnTopOfs or
       @scrnBotOfs    isnt @lastScrnBotOfs or
       @previewTopOfs isnt @lastPvwTopOfs  or
       @previewBotOfs isnt @lastPvwBotOfs
      @lastScrnTopOfs = @scrnTopOfs
      @lastScrnBotOfs = @scrnBotOfs
      @lastPvwTopOfs  = @previewTopOfs
      @lastPvwBotOfs  = @previewBotOfs
      @setMap no
      
    # log '@nodes', @nodes  
    # log '@map', @map
     
    if not @editor.alive then @stopTracking(); return
    
    switch event
      when 'init'
        scrnTopRow = @editorView.getFirstVisibleScreenRow()
        scrnBotRow = @editorView.getLastVisibleScreenRow()
        cursorRow  = @editor.getCursorScreenPosition().row
        if scrnTopRow <= cursorRow <= scrnBotRow 
             @setScroll cursorRow  * @chrHgt
        else @setScroll scrnTopRow * @chrHgt
          
      when 'changed', 'cursorMoved'
        @setScroll @editor.getCursorScreenPosition().row * @chrHgt
      
      when 'newtop'
        scrollTop = @editorView.getScrollTop()
        @lastScrollTop ?= scrollTop + 1
        if scrollTop < @lastScrollTop
          @setScroll @editorView.getFirstVisibleScreenRow() * @chrHgt
        else if scrollTop > @lastScrollTop 
          @setScroll @editorView.getLastVisibleScreenRow() * @chrHgt
        @lastScrollTop = scrollTop
  
  setScroll: (scrnPosPix) ->
    scrnPosPix = Math.max 0, scrnPosPix
    lastMapping = null
    for mapping, idx in @map
      [topPix, botPix, topRow, botRow] = mapping
      if scrnPosPix < topRow * @chrHgt
        row1 = lastMapping[3] + 1
        row2 = topRow
        pix1 = lastMapping[1]
        pix2 = topPix
        break
      else if scrnPosPix < (botRow+1) * @chrHgt
        row1 = topRow
        row2 = botRow + 1
        pix1 = topPix
        pix2 = botPix
        break
      lastMapping = mapping  
      
    scrnTopRow     = @editorView.getFirstVisibleScreenRow()
    scrnTopSpanRow = row1
    scrnSpanHgtRow = (row2 - row1)
    spanFrac       = Math.max 0, Math.min 1, 
        (scrnPosPix - scrnTopSpanRow * @chrHgt) / (scrnSpanHgtRow * @chrHgt)
        
    pvwPosPix = pix1 + (pix2 - pix1) * spanFrac
    visOfs    = scrnPosPix - scrnTopRow * @chrHgt
    @previewEle.scrollTop = pvwPosPix - visOfs
      
