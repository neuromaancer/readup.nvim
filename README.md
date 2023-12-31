# readup.nvim

## Motivation

Sometimes I want to look up a plugin's README.md without leaving my neovim. Yes, Yes, Yes. I know I can use `:h <plugin_name>` to look up the plugin's help doc. But I think the README.md is more intuitive and easy to understand rather than the help doc. The help doc is somehow tedious 😅.

## WIP

This is a plugin for me to learn lua and neovim plugin development, so everything is subject to change.

## Introduction

Neovim plugin quickly look up one plugin's `README.md` locally. It's useful when you want to look up a plugin's README.md without leaving your neovim.

~~Currently, it only supports plugins installed by [lazy.nvim](https://github.com/folke/lazy.nvim).~~

## Installation

Lazy.nvim:

```lua
{
    "neuromaancer/readup.nvim",
    cmd = "Readup",
    config = function()
        require("readup").setup({
        plugin_manager = "lazy", -- or 'packer', etc.
        float = false,  -- Set to true to open READMEs in floating windows
        open_in_browser = false, -- Set to true to open READMEs in browser
        })
    end
}
```

## Usage

- Just run :`Readup <plugin_name>`.

- Read plugin from cursor position line and open the README.md: `:ReadupCursor`.

- Open in browser: `ReadUpBrower <plugin_name>`.

## TODO

- \[x\] Support other plugin managers.
  - \[x\] lazy.nvim
  - \[x\] packer.nvim
- \[x\] Get the plugin name from the current cursor.
- \[x\] if README.md doesn't exist, try README.markdown, README.txt, etc.
- \[x\] if README.md doesn't exist, try to download it from github.
- \[x\] Support open README.md in browser.
- \[ \] Add tests.

## License

MIT
