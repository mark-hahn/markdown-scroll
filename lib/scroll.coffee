###
  lib/scroll.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, scroll:'].concat args

module.exports =

  chkScroll: (event, e) ->   
    log @map
    @stopTracking()
     
  #   if not @editor.alive then @stopTracking(); return
  #   
  #   scrnTopRow = @editor.getFirstScreenRow()
  #   scrnBotRow = @editor.getLastScreenRow()
  #   cursorRow  = @editor.getCursorScreenPosition()
  # 
  #   setScrollByCursor = =>
  #     @scrollByCursor = yes
  #     if cursorRow isnt @lastCursorRow
  #       @lastCursorRow = cursorRow
  #       @setScroll cursorRow, @chrHgt/2
  #       
  #   setScrollByScreenRow = =>
  #     if scrnTopRow <= cursorRow <= scrnBotRow 
  #       setScrollByCursor()
  #       return
  #     @scrollByCursor = no
  #     @lastScrnRow ?= (scrnTopRow + scrnBotRow) / 2
  #     @setScroll @lastScrnRow, @chrHgt/2
  # 
  #   switch event
  #     when 'init'    then if setScrollByScreenRow()
  #     when 'changed' then setScrollByCursor()
  #     when 'cursorMoved'
  #       if e.cursor is @editor.getLastCursor() then setScrollByCursor()
  #     when 'newtop' then x
  #   
  #   
  #   
  #   if not changed then @scrollByCursor = false
  #   
  # setScroll: (row, ofs) ->
  #   @lastScrnRow = row
  #   @lastChrOfs  = ofs
  #     
  #     
