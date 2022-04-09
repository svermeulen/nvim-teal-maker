
## Nvim Teal Maker

This plugin adds support for writing neovim plugins/configuration in [teal](https://github.com/teal-language/tl) (ie. strongly typed lua) instead of (or in addition to) lua

## Requirements

This plugin requires that both [tl](https://github.com/teal-language/tl) and [cyan](https://github.com/teal-language/cyan) have been installed via [luarocks](https://luarocks.org/), and are both available on the PATH

## Overview

This plugin follows the conventions that already exist in neovim for both lua and python. On startup, neovim will automatically modify the lua `package.path` value, so that any lua `require` statements will find any `lua` files inside any `/lua` directories on the neovim `runtimepath`.  Neovim also supports a `/python` directory which works similarly.  This plugin follows this same convention by adding support for a `/teal` directory on the runtimepath as well.

This same approach was also done for [moonscript](https://moonscript.org/) in the [nvim-moonmaker](https://github.com/svermeulen/nvim-moonmaker) plugin

## Quick Start

1. Install the plugin using whatever neovim plugin manager you prefer.

2. Place some `tl` files inside a `/teal` directory underneath one of the directories on the neovim `runtimepath` (see `:h runtimepath` for details).  If you're not making a plugin and instead want to just write some neovim configuration in `teal`, you can also just add a `/teal` directory alongside your `init.lua` / `init.vim`

3. Place a file named `tlconfig.lua` alongside the `/teal` directory with contents:

  ```
  return {
     build_dir = "lua",
     source_dir = "teal",
     include_dir = { "teal" }
  }
  ```

  * See documentation for [tl](https://github.com/teal-language/tl) / [cyan](https://github.com/teal-language/cyan) for more details on this config file.

5. Execute `:TealBuild`

6. Your `tl` files inside the `/teal` directory should now have been compiled to lua and placed where neovim expects them (the `/lua` directory)

Notes:

* In addition to `:TealBuild`, there are several other ways to trigger a teal build:

    1. Directly from lua/teal by importing `tealmaker`:

    ```
    local verbose_output = false
    require("tealmaker").build_all(verbose_output)
    ```

    2. By calling `tealmaker#BuildAll` from VimL:

    ```
    local verbose_output = 0
    call tealmaker#BuildAll(verbose_output)
    ```

## init.vim example

If you'd like to write your neovim configuration in teal, you might do something like this:

* Create a new `init.vim` with contents:

```
call plug#begin(stdpath('data') . '/plugged')
Plug 'svermeulen/nvim-teal-maker'
call plug#end()
```

* Add a `/teal` directory next to your `init.vim`
* Place a file named `my_config.tl` inside `/teal` with some neovim configuration.  As a random example:

```
require("vim")

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true

vim.o.hidden = true

vim.o.history = 5000

vim.o.tabstop = 4
vim.o.shiftwidth = vim.o.tabstop
vim.g.mapleader = " "

vim.keymap.set('n', '<space>q', ':qa<cr>')
vim.keymap.set('n', '<space>hw', function()
   print("hello world")
end)
```

* Also add a `tlconfig.lua` file as described in quick start section above
* Open neovim, run `:PlugInstall`, then execute `:TealBuild`.  This should result in errors of the form:

```
Error 11 type errors in teal/my_config.tl
  ... teal/my_config.tl 2:1
  ...    2 | vim.o.ignorecase = true
  ...      | ^^^
  ...      | unknown variable: vim
```

* This is because teal needs type definitions for the `vim` object that we are using.  We can solve this problem by downloading the `vim.d.tl` type definition file from the [teal-types](https://github.com/teal-language/teal-types) repo [here](https://github.com/teal-language/teal-types/blob/master/types/neovim/vim.d.tl) and placing it inside our `/teal` directory.

* Open neovim and execute `:TealBuild` again.  The build should pass now with output:

```
Info Type checked teal/my_config.tl
Info Wrote lua/my_config.lua
```

* Next, let's make sure that our teal file automatically gets built on startup.  Let's change our `init.vim` to the following:

```
call plug#begin(stdpath('data') . '/plugged')
Plug 'svermeulen/nvim-teal-maker'
call plug#end()

call tealmaker#buildAll()

lua require('my_config')
```

* Note that we are calling `call tealmaker#buildAll()` immediately after adding the 'nvim-teal-maker' plugin to our runtimepath via vim-plug.  This is important, otherwise the `lua require('my_config')` line below that might load an older version of `my_config`

* With the above set up, we can now directly modify our `my_config.tl` file and the corresponding lua files will be automatically built the next time neovim is started.  Try changing something in `my_config.tl`, restarting neovim, and verifying that this works

## Default Options

* `let g:TealMaker_Prune = 0`
    * Set this to `1` to automatically delete any lua files that don't have corresponding teal files.  However - requires a version of [cyan](https://github.com/teal-language/cyan) that has `--prune` option (version must be > `0.1.0`).  Also note that when this option is enabled, any lua files inside the `/teal` directory will be automatically copied to `/lua` as well, since you can't place lua files inside `/lua` directly with this option enabled, and it can be common to have some source files in lua.

## Tips

* If you are writing a plugin, you don't need to depend on this plugin, since you can just include the compiled lua files (which is exactly what this plugin does)

* If your plugin contains multiple `tl` files and you want to avoid polluting the root require path, you can put your teal files into subdirectories underneath the `teal` folder.  Then you can use `require("dir1.dir2.filename")` to use them from other `tl` files

