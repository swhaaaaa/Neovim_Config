-- Resolve vLLM endpoint — priority: saved file > env var > warn + fallback
-- The saved file lives in stdpath("data") (outside the repo, never committed).
-- Run :VllmSetup to set or change the server URL interactively.
local function get_vllm_endpoint()
  local data_file = vim.fn.stdpath("data") .. "/vllm_endpoint"
  if vim.fn.filereadable(data_file) == 1 then
    local ep = vim.fn.readfile(data_file)[1]
    if ep and ep ~= "" then return ep end
  end
  if vim.env.VLLM_ENDPOINT then
    return vim.env.VLLM_ENDPOINT
  end
  vim.notify(
    "avante: vLLM server not configured.\nRun  :VllmSetup  to set the server URL.",
    vim.log.levels.WARN,
    { title = "avante.nvim" }
  )
  return "http://localhost:8000/v1"
end

require("avante").setup {
  provider = "vllm",
  vendors = {
    vllm = {
      __inherited_from = "openai",
      api_key_name = "",
      endpoint     = get_vllm_endpoint(),
      model        = "devstral",
      max_tokens   = 4096,
      temperature  = 0,
    },
  },
  mappings = {
    ask     = "<leader>ia",
    edit    = "<leader>ie",
    refresh = "<leader>ir",
    toggle  = { default = "<leader>it" },
    diff = {
      ours   = "co",
      theirs = "ct",
      both   = "cb",
      next   = "]x",
      prev   = "[x",
    },
    submit = {
      normal = "<CR>",
      insert = "<S-CR>",
    },
  },
  hints = { enabled = false },
}
