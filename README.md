# yazi-markdown-viewer

A Markdown preview plugin for [Yazi](https://yazi-rs.github.io/) powered by
[glow](https://github.com/charmbracelet/glow).

The installable Yazi plugin in this repository is `mdglow.yazi`.

## Features

- Renders Markdown previews through `glow`
- Caches rendered ANSI output per file and preview width
- Uses Yazi preloaders to render nearby Markdown files in the background
- Falls back to Yazi's built-in `code` previewer when `glow` fails
- Ships a VSCode-like Glamour style in `assets/vscode.json`

## Requirements

- Yazi 26.5 or newer
- `glow` in `PATH`

## Install

Install with Yazi's package manager:

```sh
ya pkg add OWNER/yazi-markdown-viewer:mdglow
```

Replace `OWNER` with the GitHub owner or organization after this repository is
published.

Then add the previewer and preloader rules to `~/.config/yazi/yazi.toml`:

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

Run `ya pkg install` if needed, then restart Yazi.

## Local Development

For local development, symlink the package directory into Yazi's plugin folder:

```sh
ln -s /path/to/yazi-markdown-viewer/mdglow.yazi ~/.config/yazi/plugins/mdglow.yazi
```

This workspace already uses that layout, so edits under `mdglow.yazi/` are used
by the local Yazi config immediately.

## Customization

- Scroll speed: edit `local speed = 5` in `mdglow.yazi/main.lua`
- Style: edit `mdglow.yazi/assets/vscode.json`
- One-off style override: set `YAZI_MARKDOWN_VIEWER_STYLE=/path/to/style.json`

## Package Layout

Yazi deploys package assets from the child package directory. Keep the plugin
entrypoint at `mdglow.yazi/main.lua` and additional non-Lua files under
`mdglow.yazi/assets/`.
