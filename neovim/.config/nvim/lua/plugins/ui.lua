return {
  {
    "echasnovski/mini.indentscope",
    enabled = false,
  },
  {
    "folke/noice.nvim",
    opts = {
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
      hide_if_all_visible = true,
      handlers = {
        gitsigns = true,
      },
    },
  },
}
