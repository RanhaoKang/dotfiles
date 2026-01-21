vim.lsp.config['pylsp'] = {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    capabilities = vim.lsp.protocol.make_client_capabilities()
}
vim.lsp.enable('pylsp')

