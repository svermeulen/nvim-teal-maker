
## Nvim Teal Maker

This plugin adds support for writing neovim plugins/configuration in [teal](https://github.com/teal-language/tl) instead of or in addition to lua

## Requirements

This plugin requires that both [tl](https://github.com/teal-language/tl) and [cyan](https://github.com/teal-language/cyan) have been installed via [luarocks](https://luarocks.org/), and are both available on the PATH

## Quick Start

1. Install the plugin using whatever neovim plugin manager you prefer.

2. Place some `tl` files inside a `/teal` directory underneath one of the directories on the neovim `runtimepath` (see `:h runtimepath` for details)

3. Also place a file named `tlconfig.lua` alongside the `/teal` directory with contents:

```
return {
   build_dir = "lua",
   source_dir = "teal",
   include_dir = { "teal" }
}
```

4. Open/restart neovim

5. Done.  Your `tl` files inside the `/teal` directory should now have been compiled to lua and placed where neovim expects them (the `/lua` directory)

6. After editting your teal files, you can update them manually by any of the following methods:

  * Calling the command `:TealBuild`
  * Binding something to `<plug>(TealBuild)` (eg: `nmap <leader>ct <plug>(TealBuild)`)
  * Calling `tealmaker#BuildAll(1)` or `tealmaker#BuildAll(0)` from VimL (pass 1 for verbose build output)
  * Importing TealMaker directly from your own teal/lua and calling build:
      ```
      local tealmaker = require("tealmaker")
      local verbose_output = true
      tealmaker.build_all(verbose_output)
      ```

## Default Options

* `let g:TealMaker_BuildAllOnStartup = 1`
    * Set this to 0 to disable the automatic cyan build on startup and avoid the performance hit

## How It Works

This plugin follows the conventions that already exist in neovim for both lua and python. On startup, neovim will automatically modify the lua `package.path` value, so that any lua `require` statements will find any `lua` files inside any `/lua` directories on the neovim `runtimepath`.  Neovim also supports a `/python` directory which works similarly.  This plugin follows this same convention by adding support for a `/teal` directory on the runtimepath as well.

## Tips

* In order to make the most of teal, you will need type definitions for any lua-based libraries you're using.  In particular, you will at least want to grab the type definitions for the `vim` lua object, which you can find in the [teal-types](https://github.com/teal-language/teal-types) repo

* It can be common to have some parts of your code in lua and some parts in teal.  Note that you cannot place lua files inside your `/lua` directory because they will be removed the next time the `/teal` directory is built.  However - you can place lua files inside the `teal` directory, alongside your `.tl` files, and these will be copied to the `/lua` directory the next time `:TealBuild` is executed.  Note also that if you want your `foo.lua` file to be accessible to your teal code, you will need to add a `foo.d.tl` file alongisde it as well.

* If you are writing a plugin, you don't need to depend on this plugin, since you can just include the compiled lua files (which is exactly what this plugin does)

* Make sure to place this plugin earlier in the list of plugins with whatever plugin manager you're using, so that the `tl` files will be compiled as soon as possible.  This would be important if you're calling any of the generated lua code during startup from one of your own plugins.

* If your plugin contains multiple `tl` files and you want to avoid polluting the root require path, you can put your teal files into subdirectories underneath the `teal` folder.  Then you can use `require("dir1.dir2.filename")` to use them from other `tl` files

