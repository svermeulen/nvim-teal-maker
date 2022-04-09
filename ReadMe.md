
## Nvim Teal Maker

This plugin adds support for writing neovim plugins/configuration in [teal](https://github.com/teal-language/tl) instead of (or in addition to) lua

## Requirements

This plugin requires that both [tl](https://github.com/teal-language/tl) and [cyan](https://github.com/teal-language/cyan) have been installed via [luarocks](https://luarocks.org/), and are both available on the PATH

## Quick Start

1. Install the plugin using whatever neovim plugin manager you prefer.

2. Place some `tl` files inside a `/teal` directory underneath one of the directories on the neovim `runtimepath` (see `:h runtimepath` for details).  If you're not making a plugin and instead want to just write some neovim configuration in `teal`, you should be able to just add a `/teal` directory alongside your `init.lua` / `init.vim`

3. Also place a file named `tlconfig.lua` alongside the `/teal` directory with contents:

  ```
  return {
     build_dir = "lua",
     source_dir = "teal",
     include_dir = { "teal" }
  }
  ```

  * See documentation for [tl](https://github.com/teal-language/tl) / [cyan](https://github.com/teal-language/cyan) for more details on the config file.

4. Open/restart neovim

5. Execute `:TealBuild`

6. Your `tl` files inside the `/teal` directory should now have been compiled to lua and placed where neovim expects them (the `/lua` directory)

7. In addition to the `:TealBuild` command, you can also trigger a teal build by doing any of the following:

  * Calling `tealmaker#BuildAll(1)` or `tealmaker#BuildAll(0)` from VimL (pass `1` for verbose build output)
  * Importing `tealmaker` directly from your own teal/lua and calling build:
      ```
      local tealmaker = require("tealmaker")
      local verbose_output = true
      tealmaker.build_all(verbose_output)
      ```

## Default Options

* `let g:TealMaker_Prune = 0`
    * Set this to `1` to automatically delete any lua files that don't have corresponding teal files.  However - requires a version of [cyan](https://github.com/teal-language/cyan) that has `--prune` option (version must be > `0.1.0`).  Also note that when this option is enabled, any lua files inside the `/teal` directory will be automatically copied to `/lua` as well, since you can't place lua files inside `/lua` directly with this option enabled, and it can be common to have some source files in lua.

## How It Works

This plugin follows the conventions that already exist in neovim for both lua and python. On startup, neovim will automatically modify the lua `package.path` value, so that any lua `require` statements will find any `lua` files inside any `/lua` directories on the neovim `runtimepath`.  Neovim also supports a `/python` directory which works similarly.  This plugin follows this same convention by adding support for a `/teal` directory on the runtimepath as well.

This same approach was also done for [moonscript](https://moonscript.org/) in the [nvim-moonmaker](https://github.com/svermeulen/nvim-moonmaker) plugin

## Tips

* In order to make the most of teal, you will need type definitions for any lua-based libraries you're using.  In particular, you will at least want to grab the type definitions for the `vim` lua object, which you can find in the [teal-types](https://github.com/teal-language/teal-types) repo.  You can also add your own type definitions for any lua files you're using by placing `*.d.tl` files in your `/teal` directory

* If you are writing a plugin, you don't need to depend on this plugin, since you can just include the compiled lua files (which is exactly what this plugin does)

* If you're adding a `/teal` directory alongside your `init.lua`, you should 

* Make sure to place this plugin earlier in the list of plugins with whatever plugin manager you're using, so that the `tl` files will be compiled as soon as possible.  This would be important if you're calling any of the generated lua code during startup from one of your own plugins.

* If your plugin contains multiple `tl` files and you want to avoid polluting the root require path, you can put your teal files into subdirectories underneath the `teal` folder.  Then you can use `require("dir1.dir2.filename")` to use them from other `tl` files

