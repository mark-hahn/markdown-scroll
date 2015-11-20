###
  lib/scroll.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, scroll:'].concat args

module.exports =
  
  chkScroll: (event, e) -> 
    if not @editor.alive then @stopTracking(); return

    if event isnt 'changed'
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
    
    switch event
      when 'init'
        cursorOfs  = @editor.getCursorScreenPosition().row * @chrHgt
        if @scrnTopOfs <= cursorOfs <= @scrnBotOfs 
             @setScroll cursorOfs
        else @setScroll @scrnTopOfs
          
      when 'changed', 'cursorMoved'
        @setScroll @editor.getCursorScreenPosition().row * @chrHgt
      
      when 'newtop'
        @lastScrnTopOfs ?= @scrnTopOfs + 1
        if      @scrnTopOfs < @lastScrnTopOfs then @setScroll @scrnTopOfs
        else if @scrnTopOfs > @lastScrnTopOfs then @setScroll @scrnBotOfs
        @lastScrnTopOfs = @scrnTopOfs
  
  setScroll: (scrnPosPix) ->
    log 'setScroll', scrnPosPix
    
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
      
    scrnTopSpanRow = row1
    scrnSpanHgtRow = (row2 - row1)
    spanFrac       = Math.max 0, Math.min 1, 
        (scrnPosPix - scrnTopSpanRow * @chrHgt) / (scrnSpanHgtRow * @chrHgt)
        
    visOfs    = scrnPosPix - @scrnTopOfs
    pvwPosPix = pix1 + (pix2 - pix1) * spanFrac
    @previewEle.scrollTop = pvwPosPix - visOfs
      
