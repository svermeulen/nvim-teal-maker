
local util = {}

function util.join_paths(left:string, right:string):string
   local result = left
   local last_char = left:sub(-1)

   if last_char ~= '/' and last_char ~= '\\' then
      result = result .. '/'
   end

   result = result .. right
   return result
end

function util.get_directory(path:string):string
   return path:match('^(.*)[\\/][^\\/]*$')
end

function util.make_missing_directories_in_path(path:string)
   local dir_path = util.get_directory(path)
   vim.fn.mkdir(dir_path, 'p')
end

return util
