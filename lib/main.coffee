###
  lib/main.coffee
###

log = (args...) -> 
  console.log.apply console, ['markdown-scroll:'].concat args

fs       = require 'fs-plus'
SubAtom  = require 'sub-atom'
escRegex = require 'escape-string-regexp'

class MarkdownScrl
  
  activate: (state) ->
    log 'activated'
    pathUtil     = require 'path'
    {TextEditor} = require 'atom'
    @subs        = new SubAtom

    if not (prvwPkg = atom.packages.getLoadedPackage 'markdown-preview') and
       not (prvwPkg = atom.packages.getLoadedPackage 'markdown-preview-plus')
      log 'markdown preview package not found'
      return

    viewPath = pathUtil.join prvwPkg.path, 'lib/markdown-preview-view'
    MarkdownPreviewView  = require viewPath
    
    @subs.add atom.workspace.observeActivePaneItem (editor) =>
      isMarkdown = (editor)->
        for name in ["GitHub Markdown", "CoffeeScript (Literate)"]
          return true if editor.getGrammar().name is name
        return false
      if editor instanceof TextEditor and
         editor.alive                 and
         isMarkdown(editor)
        @stopTracking()
        for previewView in atom.workspace.getPaneItems() 
          if previewView instanceof MarkdownPreviewView and 
             previewView.editor is editor
            @editor        = editor
            @editorView    = atom.views.getView @editor
            @previewView   = previewView
            @previewEditor = previewView.editor
            @previewEle    = previewView.element
            @startTracking()
            break
        null

  startTracking: ->
    @subs2 = new SubAtom
    @subs2.add @editor    .onDidStopChanging (cb) => @changed(); cb()
    @subs2.add @editorView.onDidChangeScrollTop   => @chkScroll()
    @subs2.add @editor    .onDidDestroy           => @stopTracking()
    @changed()
  
  changed: -> @setMap(); @chkScroll yes
  
  findWordsRegex: (bufRow) ->
    getWordsRegex = (matches) =>
      if not matches then return
      for match in matches
        regex = new RegExp escRegex(match).replace(/\s+/g, '\\s+'), 'ig'
        words = @previewText.match regex
        if words?.length is 1 then return regex
      log 'no match for', matches
      null
    line = @editor.lineTextForBufferRow bufRow
    if line.replace(/^\s+|\s+$/g, '') isnt ''
      getWordsRegex(  line.match /\w+\s+\w+\s+\w+\s+\w+\s+\w+/g) or
        getWordsRegex(line.match /\w+\s+\w+\s+\w+\s+\w+/g)       or
        getWordsRegex(line.match /\w+\s+\w+\s+\w+/g)             or
        getWordsRegex(line.match /\w+\s+\w+/g)                   or
        getWordsRegex(line.match /\w+/g)       
        
  eleForBufRow: (bufRow, delta) ->
  
  addToMap: (bufRowStrt, delta) ->
    for bufRow in [bufRowStrt+delta..bufRowStrt+10*delta] by delta
      if not (wordsRegex = @findWordsRegex(bufRow)) then continue
      
      wlkr = document.createTreeWalker @previewEle, NodeFilter.SHOW_TEXT, null, yes
      while (node = wlkr.nextNode()) 
        if wordsRegex.test node.textContent
          {start:{row:topRow},end:{row:botRow}} =
              @editor.screenRangeForBufferRange [[bufRow,0],[bufRow,Infinity]]
          topPix = node.parentNode.offsetTop
          botPix = topPix + node.parentNode.offsetHeight
          # bufRow and node.textContent are for DEBUG
          @map.push [topRow, botRow, topPix, botPix, bufRow, node.textContent]
          return
  
  setMap: ->
    if not @editor.alive then @stopTracking(); return
    @previewText = @previewEle.textContent
    lastRow = @editor.getLastScreenRow()
    botPix = @previewEle.offsetHeight
    @map = [[0,0,0,0], [lastRow, lastRow, botPix, botPix]]
    @editor.scan /```|\.gif|\.jpg|\.jpeg|\.png|\.webm|\.mkv|\.mpg|\.mpeg|\.avi/g, (res) =>
      {range:{start:{row:bufRow}}} = res
      @addToMap bufRow, -1
      @addToMap bufRow, +1
    @map.sort (a,b) -> (a[0]+a[1]) - (b[0]+b[1])
    
  chkScroll: (changed) ->    
    if not @editor.alive then @stopTracking(); return
    log @map
    @stopTracking()
      
  stopTracking: ->
    @subs2.dispose() if @subs2
    @subs2 = null
      
  deactivate: -> 
    @stopTracking()
    @subs.dispose()

module.exports = new MarkdownScrl
