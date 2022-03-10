local nightfox = require('nightfox')

nightfox.setup({
  fox = "nordfox", -- Change the colorscheme variant
  transparent = false, -- Enable setting the background color
  alt_nc = false, -- Non current window bg to alt color see `hl-NormalNC`
  terminal_colors = false, -- Configure the colors used when opening :terminal
  styles = {
    comments = "italic",
    functions = "italic,bold",
    keywords = "bold",
    strings = "NONE",
    variables = "NONE",
  },
  inverse = {
    match_paren = false, -- Enable/Disable inverse highlighting for match parens
    visual = false, -- Enable/Disable inverse highlighting for visual selection
    search = false, -- Enable/Disable inverse highlights for search highlights
  },
  colors = {},
  hlgroups = {
    Search = { fg = "${fg}", bg = "${fg_gutter}" },
    IncSearch = { fg = "${bg}", bg = "${cyan}" },
    Substitute = { fg = "${bg}", bg = "#bf616a" },
  }
})

nightfox.load()
require('lualine').setup()
