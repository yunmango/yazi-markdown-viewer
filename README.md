# yazi-markdown-viewer

A Markdown preview plugin for [Yazi](https://yazi-rs.github.io/) powered by
[glow](https://github.com/charmbracelet/glow).

The installable Yazi plugin in this repository is `md-glow.yazi`.

## Features

- Renders Markdown previews through `glow`
- Supports Yazi 26.x by avoiding newer cache-specific plugin APIs
- Falls back to Yazi's built-in `code` previewer when `glow` fails
- Ships a VSCode-like Glamour style in `assets/vscode.json`

## Requirements

- Yazi 26 or newer
- `glow` in `PATH`

## Install

Install with Yazi's package manager:

```sh
ya pkg add yunmango/yazi-markdown-viewer:md-glow
```

This installs the `md-glow.yazi` package directory from this repository as the
`md-glow` plugin. Yazi's package manager fetches packages from GitHub, copies
them into the Yazi plugin directory, and locks the resolved revision in
`~/.config/yazi/package.toml`.

Then add the previewer rules to `~/.config/yazi/yazi.toml`:

```toml
[[plugin.prepend_previewers]]
url = "*.{md,markdown,mdown,mkdn}"
run = "md-glow"

[[plugin.prepend_previewers]]
mime = "text/markdown"
run = "md-glow"
```

Restart Yazi after changing the config.

## Package Management

```sh
ya pkg upgrade
ya pkg install
ya pkg delete yunmango/yazi-markdown-viewer:md-glow
```

- `ya pkg upgrade` updates installed packages.
- `ya pkg install` installs the locked packages from `~/.config/yazi/package.toml`.
- `ya pkg delete ...` removes this package.

## Local Development

For local development, symlink the package directory into Yazi's plugin folder:

```sh
ln -s /path/to/yazi-markdown-viewer/md-glow.yazi ~/.config/yazi/plugins/md-glow.yazi
```

This workspace already uses that layout, so edits under `md-glow.yazi/` are used
by the local Yazi config immediately.

If you want to test `ya pkg add` on a machine that already has this development
symlink, remove the symlink first to avoid a plugin-directory conflict.

## Customization

- Scroll speed: edit `local SCROLL_SPEED = 5` in `md-glow.yazi/main.lua`
- Style: edit `md-glow.yazi/assets/vscode.json`
- One-off style override: set `YAZI_MARKDOWN_VIEWER_STYLE=/path/to/style.json`

## Package Layout

Yazi's [plugin documentation](https://yazi-rs.github.io/docs/plugins/overview/)
describes plugins as kebab-case `.yazi` directories containing at least
`main.lua`, `README.md`, and `LICENSE`. This package follows that layout:

```text
md-glow.yazi/
  main.lua
  README.md
  LICENSE
  assets/vscode.json
```

Keep the plugin entrypoint at `md-glow.yazi/main.lua`. Additional non-Lua files
used at runtime should live under `md-glow.yazi/assets/` so the package manager
copies them with the plugin.
