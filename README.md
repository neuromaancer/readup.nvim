# readup.nvim

## WIP

This is a plugin for me to learn lua and neovim plugin development, so everything is subject to change.

## Introduction

Neovim plugin quickly look up one plugin's `README.md` locally. It's useful when you want to look up a plugin's README.md without leaving your neovim.

Currently, it only supports plugins installed by [lazy.nvim](https://github.com/folke/lazy.nvim).

## Installation

Lazy.nvim:

```lua
{
    "neuromaancer/readup.nvim",
    cmd = "Readup",
    config = true
}
```

## Usage

Just run :`Readup \<plugin_name>`.

- Read plugin from cursor position line and open the README.md: `:ReadupCursor`.

## TODO

- \[ \] Support other plugin managers.
- \[x\] Get the plugin name from the current cursor.
- \[ \] if README.md doesn't exist, try README.markdown, README.txt, etc.
- \[ \] if README.md doesn't exist, try to download it from github.
- \[ \] Add tests.

## License

MIT
