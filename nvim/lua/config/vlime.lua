local plugin_dir = vim.fn.stdpath("data") .. "/lazy"
local vlimepath = plugin_dir .. "/vlime"

-- Find the Lisp entry file regardless of manager path
local function find_start_vlime()
  local p = vlimepath .. "/lisp/start-vlime.lisp"
  if vim.fn.filereadable(p) == 1 then return p end
  local found = vim.fn.globpath(vim.o.rtp, "*/vlime/lisp/start-vlime.lisp", false, true)
  return (#found > 0) and found[1] or nil
end

vim.api.nvim_create_user_command("VlimeStart", function()
  local sbcl = vim.fn.exepath("sbcl")
  if sbcl == "" then
    vim.notify("SBCL not found in PATH", vim.log.levels.ERROR)
    return
  end
  local entry = find_start_vlime()
  if not entry then
    vim.notify("Cannot find start-vlime.lisp", vim.log.levels.ERROR)
    return
  end
  vim.fn.jobstart({ sbcl, "--load", entry }, { detach = true })
  vim.notify("Vlime server starting (default 127.0.0.1:7002)")
end, {})

