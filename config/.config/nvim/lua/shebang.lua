-- shebang.lua

local M = {}

M.detect_shebang = function()
  local first_line = vim.fn.getline(1)
  if string.match(first_line, '^#!.*/bin/bash') or string.match(first_line, '^#!.*/bin/env%s+bash') then
    vim.cmd('setfiletype bash')
  end
end

return M
