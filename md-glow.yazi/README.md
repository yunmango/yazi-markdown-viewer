# md-glow.yazi

Markdown previewer for Yazi, powered by `glow`.

This plugin renders Markdown in Yazi's preview pane with `glow` while staying on
the stable Yazi 26.x previewer API surface.

## Requirements

- Yazi 26 or newer
- `glow` in `PATH`

## Install

```sh
ya pkg add yunmango/yazi-markdown-viewer:md-glow
```

## Yazi Config

```toml
[[plugin.prepend_previewers]]
url = "*.{md,markdown,mdown,mkdn}"
run = "md-glow"

[[plugin.prepend_previewers]]
mime = "text/markdown"
run = "md-glow"
```

## Notes

- The bundled style is `assets/vscode.json`.
- Set `YAZI_MARKDOWN_VIEWER_STYLE=/path/to/style.json` to use another Glamour
  style file.
- If `glow` is unavailable or rendering fails, the plugin falls back to Yazi's
  built-in `code` previewer.
