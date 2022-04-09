
local util <const> = require("tealmaker.util")

local tealmaker = {}

local function copy_lua_files(project_dir:string, verbose:boolean)
   local teal_dir = util.join_paths(project_dir, "teal")

   if vim.fn.isdirectory(teal_dir) ~= 1 then
      return
   end

   local output_dir = util.join_paths(project_dir, "lua")

   for _, source_path in ipairs(vim.fn.globpath(teal_dir, "**/*.lua", 0, 1)) do
      local relative_path = source_path:sub(#teal_dir + 2)
      local output_path = util.join_paths(output_dir, relative_path)

      util.make_missing_directories_in_path(output_path)
      vim.fn.writefile(vim.fn.readfile(source_path), output_path)

      if verbose then
         print(string.format("Unpruned '%s'", relative_path))
      end
   end
end

local function should_prune_files():boolean
   local ok, result = pcall(function():boolean
      return vim.api.nvim_get_var("TealMaker_Prune") as boolean
   end)

   return ok and result
end

local function get_most_recent_modification_time(dir:string, extension:string):integer
   local most_recent_time = 0

   for _, path in ipairs(vim.fn.globpath(dir, "**/*." .. extension, 0, 1)) do
      local changetime = vim.fn.getftime(path)

      if changetime > most_recent_time then
         most_recent_time = changetime
      end
   end

   return most_recent_time
end

local function should_build_project(project_dir:string):boolean
   local teal_dir = util.join_paths(project_dir, "teal")

   if vim.fn.isdirectory(teal_dir) ~= 1 then
      return false
   end

   local lua_dir = util.join_paths(project_dir, "lua")
   return get_most_recent_modification_time(teal_dir, "tl") > get_most_recent_modification_time(lua_dir, "lua")
end

local function build_project(project_dir:string, verbose:boolean)

   if not should_build_project(project_dir) then
      if verbose then
         print(string.format("Skipped teal project at '%s' because teal files have not changed since last build", project_dir))
      end

      return
   end

   local all_output:{string} = {}

   local build_args = {"cyan", "build"}
   local should_prune = should_prune_files()

   if should_prune then
      table.insert(build_args, "--prune")
   end

   local job_id = vim.fn.jobstart(build_args, {
      cwd = project_dir,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_:integer, data:{string})
         if data then
            for _, line in ipairs(data) do
               table.insert(all_output, line)
            end
         end
      end,
      on_stderr = function(_:integer, data:{string})
         if data then
            for _, line in ipairs(data) do
               table.insert(all_output, line)
            end
         end
      end,
   })

   if job_id <= 0 then
      error("Failed to start 'cyan' to build teal files.  Is it installed?")
   end

   local results = vim.fn.jobwait({job_id})

   local function get_all_output():string
      local raw_output = table.concat(all_output, '\n')
      -- Cyan adds lot of ansi color codes which vim can't display so let's remove those
      local text_output = raw_output:gsub('\x1b%[%d+;%d+;%d+;%d+;%d+m','')
           :gsub('\x1b%[%d+;%d+;%d+;%d+m','')
           :gsub('\x1b%[%d+;%d+;%d+m','')
           :gsub('\x1b%[%d+;%d+m','')
           :gsub('\x1b%[%d+m','')
      return text_output
   end

   if results[1] ~= 0 then
      print(string.format("Build failed for project at '%s'\n%s", project_dir, get_all_output()))
   else
      if verbose then
         print(string.format("Successfully built project at '%s'\n%s", project_dir, get_all_output()))
      end

      if should_prune then
         -- Unfortunately, cyan --prune deletes all lua files in the output directory, so we need to copy them back
         -- More info here: https://github.com/teal-language/cyan/issues/19
         copy_lua_files(project_dir, verbose)
      end
   end
end

function tealmaker.build_all(verbose:boolean):boolean

   local ok, is_exe = pcall(vim.fn.executable, "cyan")

   if not ok or is_exe ~= 1 then
      error("Could not find 'cyan' on path.  This is necessary to build teal files")
   end

   local plugin_paths = vim.api.nvim_list_runtime_paths()
   local our_plugin_name = "nvim-teal-maker"

   for _, plugin_path in ipairs(plugin_paths) do
      -- Skip ourselves to avoid the performance hit there
      if plugin_path:sub(#plugin_path + 1 - #our_plugin_name) ~= our_plugin_name then
         local config_path = util.join_paths(plugin_path, "tlconfig.lua")

         if vim.fn.filereadable(config_path) == 1 then
            build_project(plugin_path, verbose)
         end
      end
   end
end

return tealmaker

