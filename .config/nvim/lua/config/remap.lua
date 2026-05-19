vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })


vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("x", "<leader>pp", "\"_dP")
vim.keymap.set("x", "<leader>pe", "\"+p")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>d", "\"+d")
vim.keymap.set("v", "<leader>d", "\"+d")

vim.keymap.set("n", "<leader>i", ":lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "<leader>rf", ":e!<cr>")

vim.keymap.set("n", "<leader>n", ":enew<cr>")

local blame_stack = {}

local function push_and_switch(target)
  local full_target = vim.fn.system('git rev-parse ' .. target):gsub('%s+', '')
  if #blame_stack == 0 then
    local branch = vim.fn.system('git symbolic-ref --short HEAD 2>/dev/null'):gsub('%s+', '')
    if branch == '' then
      branch = vim.fn.system('git rev-parse HEAD'):gsub('%s+', '')
    end
    if full_target == vim.fn.system('git rev-parse HEAD'):gsub('%s+', '') then
      vim.notify('Already on this commit', vim.log.levels.WARN)
      return
    end
    table.insert(blame_stack, branch)
  else
    local current = vim.fn.system('git rev-parse HEAD'):gsub('%s+', '')
    if full_target == current then
      vim.notify('Already on this commit', vim.log.levels.WARN)
      return
    end
    table.insert(blame_stack, current)
  end
  vim.fn.system('git switch --detach ' .. full_target)
  vim.cmd('edit')
end

vim.keymap.set('n', '<leader>gb', function()
  local line = vim.fn.line('.')
  local file = vim.fn.expand('%')
  local cmd = string.format(
    "git blame -L %d,%d -- %s | head -1 | cut -d' ' -f1 | tr -d '^'",
    line, line, vim.fn.shellescape(file)
  )

  local sha = vim.fn.system(cmd):gsub('%s+', '')
  push_and_switch(sha)
end, { desc = 'Git switch to blame commit for current line' })

vim.keymap.set('n', '<leader>gu', function()
  if #blame_stack == 0 then
    vim.notify('Blame stack is empty', vim.log.levels.WARN)
    return
  end
  local prev = table.remove(blame_stack)
  if #blame_stack == 0 then
    -- this was the base entry, could be a branch name
    vim.fn.system('git switch ' .. prev)
  else
    vim.fn.system('git switch --detach ' .. prev)
  end
  vim.cmd('edit');
end, { desc = 'Undo last blame switch' })

vim.keymap.set('n', '<leader>gp', function()
  local parent = vim.fn.system('git rev-parse HEAD~1'):gsub('%s+', '')
  if vim.v.shell_error ~= 0 then
    vim.notify('No parent commit', vim.log.levels.WARN)
    return
  end
  push_and_switch(parent)
end, { desc = 'Git switch to parent of current commit' })
