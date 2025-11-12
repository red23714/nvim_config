-- ===========================
--         ОСНОВНЫЕ НАСТРОЙКИ
-- ===========================
vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus" -- общий буфер обмена (Arch/Ubuntu)

-- ===========================
--         АВТОУСТАНОВКА LAZY.NVIM
-- ===========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    print("Устанавливаю lazy.nvim...")
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ===========================
--         НАСТРОЙКА ПЛАГИНОВ
-- ===========================
require("lazy").setup({

    -- ======== ТЕМЫ ========
    { "folke/tokyonight.nvim",    priority = 1000 },
    { "ellisonleao/gruvbox.nvim", priority = 900 },
    { "navarasu/onedark.nvim",    priority = 800 },

    -- В lazy.nvim
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },

    -- ======== TELESCOPE ========
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', function()
                builtin.find_files({
                    layout_strategy = 'vertical',
                    layout_config = { prompt_position = 'top' },
                })
            end)
        end
    },

    -- ======== ФАЙЛОВЫЙ БРАУЗЕР ========
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("nvim-tree").setup({
                view = { width = 35 },
                renderer = { highlight_git = true },
                actions = { open_file = { quit_on_open = false } },
            })
            vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
        end
    },

    -- ======== ПОДСВЕТКА ========
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', function()
                builtin.find_files({
                    -- ===========================
                    layout_strategy = 'horizontal',   -- 'horizontal' → список слева, предпросмотр справа
                                                    -- 'vertical' → список сверху, предпросмотр снизу
                    layout_config = {
                        prompt_position = 'top',      -- строка поиска вверху
                        preview_width = 0.5,          -- сколько места занимает предпросмотр справа (0.0 - 1.0)
                        width = 0.9,                  -- ширина всего окна Telescope (0.0 - 1.0)
                        height = 0.8,                 -- высота окна (0.0 - 1.0)
                        mirror = false,               -- если true, меняет местами список и превью
                    },
                    sorting_strategy = "ascending",   -- 'ascending' → список сверху вниз (Tab вниз)
                                                    -- 'descending' → список снизу вверх
                    -- ===========================
                })
            end)
        end
    },

    -- ======== АВТОДОПОЛНЕНИЕ ========
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp-signature-help',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(1) then
                            luasnip.jump(1)
                        elseif cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        elseif cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end
    },

    -- ======== LSP (СМАРТ-ПРОЕКТЫ) ========
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local util = require('lspconfig.util')

            local function get_root_dir(fname)
                return util.root_pattern(
                    'CMakeLists.txt',
                    'compile_commands.json',
                    'pyproject.toml',
                    'setup.py',
                    'requirements.txt',
                    'build.zig',
                    '.venv',
                    '.git'
                )(fname) or vim.loop.cwd()
            end

            local servers = {
                clangd = {},
                pyright = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { 'vim' } },
                            workspace = { checkThirdParty = false },
                        }
                    }
                },
                zls = {},
            }

            for name, conf in pairs(servers) do
                conf.capabilities = capabilities
                conf.root_dir = get_root_dir
                conf.flags = { debounce_text_changes = 300 }

                -- Настройка через lspconfig (правильный способ)
                lspconfig[name].setup(conf)
            end

            -- Ошибки только при наведении
            vim.diagnostic.config({
                virtual_text = false,
                underline = false,
                signs = false,
                update_in_insert = false,
            })

            vim.api.nvim_create_autocmd("CursorHold", {
                callback = function()
                    vim.diagnostic.open_float(nil, {
                        focusable = false,
                        border = "rounded",
                        source = "always",
                        prefix = " ",
                    })
                end,
            })
        end
    },

    -- ======== ФОРМАТИРОВАНИЕ ========
    {
        'stevearc/conform.nvim',
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    python = { "black" },
                    lua = { "stylua" },
                    zig = { "zigfmt" },
                },
                format_on_save = { timeout_ms = 500, lsp_fallback = true },
            })
        end
    },

    -- ======== ВКЛАДКИ ========
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("bufferline").setup({})
            vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
            vim.keymap.set('n', '<C-Tab>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
        end
    },

    -- ======== АВТОСКОБКИ ========
    { 'windwp/nvim-autopairs', event = "InsertEnter", config = true },

    -- ======== СТАТУСБАР ========
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'tokyonight',
                    section_separators = '',
                    component_separators = '',
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff' },
                    lualine_c = { 'filename' },
                    lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' },
                },
            })
        end
    },
})

-- ===========================
--         ДОПОЛНИТЕЛЬНО
-- ===========================
vim.cmd("colorscheme tokyonight")

-- Смена темы Space + t + h
vim.keymap.set('n', '<leader>th', function()
    local themes = { "tokyonight", "gruvbox", "onedark" }
    local current = vim.g.colors_name
    local next_index = (vim.fn.index(themes, current) + 1) % #themes + 1
    vim.cmd("colorscheme " .. themes[next_index])
    print("Тема: " .. themes[next_index])
end, { noremap = true, silent = true })

-- Форматирование Ctrl + s
vim.keymap.set("n", "<C-s>", function()
    require("conform").format({ async = true })
end, { desc = "Форматировать код" })
