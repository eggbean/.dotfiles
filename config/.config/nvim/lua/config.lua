-- Set nightfox options
require('nightfox').setup({
  options = {
    transparent = false,     -- Disable setting background
    terminal_colors = false, -- Set terminal colors (vim.g.terminal_color_*)
    dim_inactive = true,     -- Non focused panes set to alternative background
    styles = {               -- Style to be applied to different syntax groups
      comments = "italic",
      functions = "italic,bold",
      keywords = "bold",
      numbers = "NONE",
      strings = "NONE",
      types = "NONE",
      variables = "NONE",
    },
    inverse = {             -- Inverse highlight for different types
      match_paren = false,
      visual = false,
      search = false,
    },
    modules = {             -- List of various plugins and additional options
      -- ...
    },
  }
})

vim.cmd("colorscheme nordfox")

-- Set lualine options
require('lualine').setup({
  options = {
    section_separators = '', component_separators = '|',
  },
})
