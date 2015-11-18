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
    log 'activated 2'
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
  
  setMap: ->
    log 'setMap start',
       @previewEle.offsetHeight, @previewEle.scrollHeight
    start = Date.now()

    @nodes = []
    wlkr = document.createTreeWalker @previewEle, NodeFilter.SHOW_TEXT, null, yes
    while (node = wlkr.nextNode())
      text = node.textContent
      if not /\w+/.test text then continue
      topPix = node.parentNode.offsetTop
      botPix = topPix + node.parentNode.scrollHeight
      @nodes.push [topPix, botPix, null, null, text, null]
      
    log 'walk elapsed ms:', Date.now() - start,
       @previewEle.offsetHeight, @previewEle.scrollHeight
    
    nodePtr = 0
    for bufRow in [0..@editor.getLastBufferRow()]
      line = @editor.lineTextForBufferRow bufRow
      if not (matches = line.match /[a-z0-9-\s]+/i) then continue
      maxLen = 0
      target = null
      for match in matches when /\w+/.test match
        match = match.replace /^\s+|\s+$/, ''
        if match.length > maxLen
          maxLen = match.length
          target = match
      if target
        for idx in [nodePtr...@nodes.length]
          node = @nodes[idx]
          if node[4].includes target
            {start:{row:topRow},end:{row:botRow}} =
              @editor.screenRangeForBufferRange [[bufRow, 0],[bufRow, 9e9]]
            node[2] = topRow
            node[3] = botRow
            node[5] = target  # DEBUG
            nodePtr = idx + 1
            break
            
    log 'nodes elapsed ms:', Date.now() - start,
       @previewEle.offsetHeight, @previewEle.scrollHeight
    
    @map = [[0,0,0,0]]
    lastTopPix = lastBotPix = lastTopRow = lastBotRow = 0
    firstNode = yes
    addNodeToMap = (node) =>
      [topPix, botPix, topRow, botRow] = node
      if topPix <  lastBotPix or
         topRow <= lastBotRow
        lastTopPix = Math.min topPix, lastTopPix
        lastBotPix = Math.max botPix, lastBotPix
        lastTopRow = Math.min topRow, lastTopRow
        lastBotRow = Math.max botRow, lastBotRow
        @map[@map.length - 1] = 
          [lastTopPix, lastBotPix, lastTopRow, lastBotRow]
      else
        if firstNode
          @map[0][1] = topPix
          @map[0][3] = Math.max 0, topRow - 1
        @map.push [lastTopPix = topPix,
                   lastBotPix = botPix, 
                   lastTopRow = topRow, 
                   lastBotRow = botRow]
      firstNode = no
      
    for node in @nodes when node[2] isnt null
      addNodeToMap node
    
    botRow = @editor.getLastScreenRow()
    topRow = Math.min  botRow, lastBotRow + 1
    addNodeToMap [lastBotPix, @previewEle.scrollHeight,
                  topRow, botRow]
              
    @nodes = null
    log 'setMap done, elapsed ms:', Date.now() - start,
       @previewEle.offsetHeight, @previewEle.scrollHeight
    
  chkScroll: (changed) ->    
    if not @editor.alive then @stopTracking(); return
    log '@nodes:', @nodes
    log '@map:',   @map
    @stopTracking()
      
  stopTracking: ->
    @subs2.dispose() if @subs2
    @subs2 = null
      
  deactivate: -> 
    @stopTracking()
    @subs.dispose()

module.exports = new MarkdownScrl
