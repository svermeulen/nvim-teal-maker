local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table
local util = require("tealmaker.util")

local tealmaker = {}

local function copy_lua_files(project_dir, verbose)
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

local function should_prune_files()
   local ok, result = pcall(function()
      return vim.api.nvim_get_var("TealMaker_Prune")
   end)

   return ok and result
end

local function build_project(project_dir, verbose)
   local all_output = {}

   local build_args = { "cyan", "build" }
   local should_prune = should_prune_files()

   if should_prune then
      table.insert(build_args, "--prune")
   end

   local job_id = vim.fn.jobstart(build_args, {
      cwd = project_dir,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
         if data then
            for _, line in ipairs(data) do
               table.insert(all_output, line)
            end
         end
      end,
      on_stderr = function(_, data)
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

   local results = vim.fn.jobwait({ job_id })

   local function get_all_output()
      local raw_output = table.concat(all_output, '\n')

      local text_output = raw_output:gsub('\x1b%[%d+;%d+;%d+;%d+;%d+m', ''):
      gsub('\x1b%[%d+;%d+;%d+;%d+m', ''):
      gsub('\x1b%[%d+;%d+;%d+m', ''):
      gsub('\x1b%[%d+;%d+m', ''):
      gsub('\x1b%[%d+m', '')
      return text_output
   end

   if results[1] ~= 0 then
      print(string.format("Build failed for project at '%s'\n%s", project_dir, get_all_output()))
   else
      if verbose then
         print(string.format("Successfully built project at '%s'\n%s", project_dir, get_all_output()))
      end

      if should_prune then


         copy_lua_files(project_dir, verbose)
      end
   end
end

function tealmaker.build_all(verbose)

   local ok, is_exe = pcall(vim.fn.executable, "cyan")

   if not ok or is_exe ~= 1 then
      error("Could not find 'cyan' on path.  This is necessary to build teal files")
   end

   local plugin_paths = vim.api.nvim_list_runtime_paths()
   local our_plugin_name = "nvim-teal-maker"

   for _, plugin_path in ipairs(plugin_paths) do

      if plugin_path:sub(#plugin_path + 1 - #our_plugin_name) ~= our_plugin_name then
         local config_path = util.join_paths(plugin_path, "tlconfig.lua")

         if vim.fn.filereadable(config_path) == 1 then
            build_project(plugin_path, verbose)
         end
      end
   end
end

return tealmaker