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

Just run :Readup \<plugin_name>.

## TODO

- \[ \] Support other plugin managers.
- \[ \] Get the plugin name from the current cursor.

## License

MIT

```
```
