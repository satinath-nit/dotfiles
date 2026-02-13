-- ============================================
-- Bootstrap lazy.nvim (plugin manager)
-- ============================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- Leader Key
-- ============================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================
-- Options
-- ============================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true

-- ============================================
-- Keymaps
-- ============================================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- ============================================
-- Plugins
-- ============================================
require("lazy").setup({
    { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function()
        vim.cmd.colorscheme("catppuccin-mocha")
    end },

    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[F]ind [R]ecent" })
        end },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "lua", "java", "javascript", "typescript", "python", "go", "rust",
                "json", "yaml", "toml", "html", "css", "bash", "dockerfile", "terraform", "sql", "xml" },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end },

    { "neovim/nvim-lspconfig", dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    }, config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "ts_ls", "pyright", "gopls" },
        })
        local lspconfig = require("lspconfig")
        local on_attach = function(_, bufnr)
            local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
            end
            map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
            map("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
            map("K", vim.lsp.buf.hover, "Hover Documentation")
            map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
            map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        end
        local servers = { "lua_ls", "ts_ls", "pyright", "gopls" }
        for _, server in ipairs(servers) do
            lspconfig[server].setup({ on_attach = on_attach })
        end
    end },

    { "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    }, config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        cmp.setup({
            snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            },
        })
    end },

    { "lewis6991/gitsigns.nvim", config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        })
    end },

    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({ options = { theme = "catppuccin" } })
        end },

    { "folke/which-key.nvim", event = "VeryLazy", config = function()
        require("which-key").setup()
    end },

    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

    { "numToStr/Comment.nvim", config = true },
})
