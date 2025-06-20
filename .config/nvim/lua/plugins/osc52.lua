return {
  "ojroques/nvim-osc52",
  config = function()
    require("osc52").setup({
      max_length = 0, -- sem limite de tamanho
      silent = false, -- mete a true se não quiseres mensagens
      trim = false, -- não corta espaços em branco
    })

    -- Copia para o clipboard local automaticamente ao yank
    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        if vim.v.event.operator == "y" and vim.v.event.regname == "" then
          require("osc52").copy_register("")
        end
      end,
    })
  end,
}
