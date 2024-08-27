local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
      },
    },
    { "navarasu/onedark.nvim" },
    { "dense-analysis/ale" },
    { "BurntSushi/ripgrep" },
    { "tpope/vim-dadbod" },
    { "kristijanhusak/vim-dadbod-ui" },
    { "kristijanhusak/vim-dadbod-completion" },
    { "akinsho/git-conflict.nvim", version = "*", config = true },
    { "kjnh10/ExcelLikeVim" },
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },
    { "nvim-neotest/nvim-nio" },
    { "OmniSharp/omnisharp-vim" },
    { "duane9/nvim-rg" },
    { "sindrets/diffview.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "akinsho/bufferline.nvim" },
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      -- or                              , branch = '0.1.x',
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    { "mg979/vim-visual-multi" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
vim.opt.termguicolors = true
require("bufferline").setup({
  options = {
    separator_style = "slant",
  },
})

require("telescope").setup({
  pickers = {
    find_files = {
      theme = "dropdown",
    },
    live_grep = {
      theme = "dropdown",
    },
  },
})

require("onedark").setup({
  style = "darker",
  transparent = true,
})
require("onedark").load()

local dap, dapui = require("dap"), require("dapui")

dap.adapters.coreclr = {
  type = "executable",
  command = "C:\\Users\\SebastianBomher\\AppData\\Local\\netcoredbg\\netcoredbg.exe",
  args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    preLaunchTask = "dotnet build",
    env = {
      ASPNETCORE_ENVIRONMENT = function()
        -- todo: request input from ui
        return "Development"
      end,
      ASPNETCORE_URLS = function()
        -- todo: request input from ui
        return "https://localhost:6001"
      end,
    },
    program = function()
      local dllPath = "C:\\A\\"
      local pathfile = vim.fn.getcwd()
      if string.find(pathfile, "regrep") then
        dllPath = "C:\\A\\regrep\\src\\RegRep\\bin\\Debug\\net6.0\\RegRep.dll"
      elseif string.find(pathfile, "C:\\A\\dpm") then
        dllPath = "C:\\A\\dpm-importer-2.0\\Taxonomy.Importer\\bin\\Debug\\net6.0-windows\\Taxonomy.Importer.dll"
      elseif string.find(pathfile, "reportgenerator") then
        dllPath = "C:\\A\\reportgenerator\\src\\ReportGenerator.Api\\bin\\Debug\\net6.0\\ReportGenerator.Api"
      end
      return vim.fn.input("Path to dll", dllPath, "file")
    end,
    cwd = function()
      local workspacePath = "C:\\A\\"
      local pathfile = vim.fn.getcwd()
      if string.find(pathfile, "regrep") then
        workspacePath = "C:\\A\\regrep\\src\\RegRep"
      elseif string.find(pathfile, "C:\\A\\dpm") then
        workspacePath = "C:\\A\\dpm-importer-2.0\\Taxonomy.Importer"
      elseif string.find(pathfile, "reportgenerator") then
        workspacePath = "C:\\A\\reportgenerator\\src\\ReportGenerator.Api"
      end
      return vim.fn.input("Workspace folder: ", workspacePath, "file")
    end,
  },
}

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override mappings for specific elements
  element_mappings = {
    -- Example:
    -- stacks = {
    --   open = "<CR>",
    --   expand = "o",
    -- }
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        "breakpoints",
        "console",
        "repl",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    controls = {
      -- Requires Neovim nightly (or 0.8 when released)
      enabled = true,
      -- Display controls in this element
      element = "repl",
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil, -- Can be integer or nil.
      max_value_lines = 100, -- Can be integer or nil.
    },
  },
})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
e
