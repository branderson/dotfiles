local M = {}

-- Open ranger from within nvim; if it writes a chosen path to its return
-- file, open that file. Mirrors the old vimscript Ranger() function.
function M.ranger()
  if vim.fn.executable("ranger") == 0 then
    vim.notify("ranger is not installed", vim.log.levels.WARN)
    return
  end
  local tmpfile = vim.fn.system("mktemp -u"):gsub("\n", "")
  vim.cmd(("silent !RANGER_RETURN_FILE=%s ranger"):format(tmpfile))
  if vim.fn.filereadable(tmpfile) == 1 then
    local filetoedit = vim.fn.system("cat " .. tmpfile)
    vim.cmd("edit " .. filetoedit)
    vim.fn.delete(tmpfile)
  end
  vim.cmd("redraw!")
end

-- Delete trailing whitespace on the current buffer, preserving cursor
-- position. Mirrors the old vimscript DeleteTrailingWS() function.
function M.delete_trailing_ws()
  local view = vim.fn.winsaveview()
  vim.cmd([[silent! %s/\s\+$//ge]])
  vim.fn.winrestview(view)
end

return M
