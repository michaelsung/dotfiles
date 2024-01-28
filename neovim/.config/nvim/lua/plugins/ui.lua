return {
  {
    "echasnovski/mini.indentscope",
    opts = {
      draw = {
        delay = 0,
        animation = function()
          return 0
        end,
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline",
      },
      presets = {
        lsp_doc_border = true,
      },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    opts = {
      hide_if_all_visible = false,
      handlers = {
        gitsigns = true,
      },
    },
  },
  { "akinsho/bufferline.nvim", opts = {
    options = {
      always_show_bufferline = true,
    },
  } },
}
