local status, null_ls = pcall(require, "null-ls")
if (not status) then return end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end

null_ls.setup {
  sources = {
    null_ls.builtins.formatting.eslint_d.with({
      extra_filetypes = { "svelte" },
    }),
    null_ls.builtins.diagnostics.eslint_d.with({
      diagnostics_format = '[eslint] #{m}\n(#{c})',
      extra_filetypes = { "svelte" },
    }),
    null_ls.builtins.formatting.prettierd.with({
      extra_filetypes = { "svelte" },
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          lsp_formatting(bufnr)
        end,
      })
    end

    vim.api.nvim_create_user_command('FixEslint', '!eslint_d "%" --fix', { nargs = 0 })
  end
}

vim.api.nvim_create_user_command(
  'TogglePrettierFormatting',
  function()
    null_ls.toggle('prettierd')
  end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  'ToggleEslintChecking',
  function()
    null_ls.toggle('eslint_d')
  end,
  { nargs = 0 }
)
