vim.opt.swapfile = false
vim.opt.undofile = false

local M = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

---@param plugin string
function M.load(plugin)
  local name = plugin:match ".*/(.*)"
  local dir = M.root ".nvim/site/pack/deps/start/"
  if not vim.loop.fs_stat(dir .. name) then
    print("Cloning into" .. plugin)
    vim.fn.mkdir(dir, "p")
    vim.fn.system { "git", "clone", "https://github.com/" .. plugin, dir .. "/" .. name }
  end
end

function M.setup()
  vim.cmd [[set runtimepath=$VIMRUNTIME]]

  vim.opt.runtimepath:append(M.root())
  vim.opt.packpath = { M.root ".nvim/site" }

  M.load "nvim-lua/plenary.nvim"
  M.load "nvim-telescope/telescope.nvim"

  require "plenary.busted"

  -- local ok, _ = pcall(require, "plenary.busted")
  -- print(ok)
end

M.setup()
