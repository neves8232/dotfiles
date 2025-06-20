return {
  "neovim/nvim-lspconfig",
  opts = function()
    local Keys = require("lazyvim.plugins.lsp.keymaps").get()

    -- Desativar o atalho original "gr"
    Keys[#Keys + 1] = { "gr", false }

    -- Adicionar o novo atalho "<leader>gr"
    Keys[#Keys + 1] = {
      "<leader>gr",
      vim.lsp.buf.references,
      desc = "Referências LSP",
      nowait = true,
    }
  end,
}
