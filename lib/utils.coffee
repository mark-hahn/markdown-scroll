###
  lib/utils.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll, utils:'].concat args

module.exports =

  getVisTopHgtBot: ->
    {top: @edtTopBnd, bottom: edtBotBnd} = @editorView.getBoundingClientRect()
    lineEles = @editorView.shadowRoot.querySelectorAll '.lines .line'
    lines = []
    for lineEle in lineEles
      {top:linTopBnd, bottom:linBotBnd} = lineEle.getBoundingClientRect()
      lines.push [+lineEle.getAttribute('data-screen-row'), linTopBnd, linBotBnd]
    lines.sort()
    [firstRow, firstTopBnd] = lines[0]
    @scrnTopOfs = (firstRow * @chrHgt) - (firstTopBnd - @edtTopBnd)
    @scrnBotOfs = @scrnTopOfs + (edtBotBnd - @edtTopBnd)
    
    {top: @pvwTopBnd, bottom: pvwBotBnd} = @previewEle.getBoundingClientRect()
    @previewTopOfs = @previewEle.scrollTop
    @previewBotOfs = @previewTopOfs + (pvwBotBnd - @pvwTopBnd)
    log 'getVisTopHgtBot', 
      {@scrnTopOfs, @scrnBotOfs, @previewTopOfs, @previewBotOfs}
  
  getEleTopHgtBot: (ele, scrn = yes) ->
    {top:eleTopBnd, bottom: eleBotBnd} = ele.getBoundingClientRect()
    top = if scrn then @scrnTopOfs    + (eleTopBnd - @edtTopBnd) \
                  else @previewTopOfs + (eleTopBnd - @pvwTopBnd)
    hgt = eleBotBnd - eleTopBnd
    bot = top + hgt
    [top, hgt, bot]
  