local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local string = _tl_compat and _tl_compat.string or string
local util = {}

function util.join_paths(left, right)
   local result = left
   local last_char = left:sub(-1)

   if last_char ~= '/' and last_char ~= '\\' then
      result = result .. '/'
   end

   result = result .. right
   return result
end

function util.get_directory(path)
   return path:match('^(.*)[\\/][^\\/]*$')
end

function util.make_missing_directories_in_path(path)
   local dir_path = util.get_directory(path)
   vim.fn.mkdir(dir_path, 'p')
end

return util