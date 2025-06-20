return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.ai").setup()
    require("mini.surround").setup()
    -- TODO por o mini.surround a funcionar
  end,
}
