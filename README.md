# markdown-scroll Atom editor package

Auto-scroll markdown-preview tab to match markdown source.

---

![Image inserted by Atom editor package auto-host-markdown-image](http://i.imgur.com/X3fVXdL.gif)

---

### Background

This is a rewrite of the `markdown-scroll-sync` package. This is smarter in that it only matches needed points in the file and then smoothly interpolates the position.

### Usage

There is no atom command or keybinding. There are no config settings.

The package starts on load and watches for when it should sync.  It will automatically sync when there are two panes where one active tab is a markdown file and another active tab is the markdown preview for that file.  At that point it will scroll the preview to match the markdown file's scroll position.  

When the markdown file is scrolled the preview is automatically scrolled to match.  If the preview is scrolled then syncing is temporarily turned off until the main file is focused again.  The markdown file is never automatically scrolled to match the preview.

### License

Copyright Mark Hahn by MIT license.
