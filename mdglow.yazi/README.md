# mdglow.yazi

Markdown previewer for Yazi, powered by `glow`.

This plugin renders Markdown once, stores the rendered ANSI output in Yazi's
preview cache, and reuses that cache while scrolling. It also implements a
preloader so nearby Markdown files can be rendered before they are hovered.

## Requirements

- Yazi 26.5 or newer
- `glow` in `PATH`

## Yazi Config

```toml
[[plugin.prepend_previewers]]
url = "*.{md,markdown,mdown,mkdn}"
run = "mdglow"

[[plugin.prepend_previewers]]
mime = "text/markdown"
run = "mdglow"

[[plugin.prepend_preloaders]]
url = "*.{md,markdown,mdown,mkdn}"
run = "mdglow"

[[plugin.prepend_preloaders]]
mime = "text/markdown"
run = "mdglow"
```

## Notes

- The bundled style is `assets/vscode.json`.
- Set `YAZI_MARKDOWN_VIEWER_STYLE=/path/to/style.json` to use another Glamour
  style file.
- If `glow` is unavailable or rendering fails, the plugin falls back to Yazi's
  built-in `code` previewer.
