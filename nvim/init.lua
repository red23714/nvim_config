-- ===========================
--         ОСНОВНЫЕ НАСТРОЙКИ
-- ===========================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.updatetime = 300
vim.opt.clipboard = "unnamedplus" -- общий буфер обмена (Arch/Ubuntu)

-- ===========================
--         АВТОУСТАНОВКА LAZY.NVIM
-- ===========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	print("Устанавливаю lazy.nvim...")
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ===========================
--         НАСТРОЙКА ПЛАГИНОВ
-- ===========================
require("lazy").setup({

	-- ======== ТЕМЫ ========
	{ "folke/tokyonight.nvim", priority = 1000 },
	{ "ellisonleao/gruvbox.nvim", priority = 900 },
	{ "navarasu/onedark.nvim", priority = 800 },

	-- В lazy.nvim
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- ======== TELESCOPE ========
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({
					layout_strategy = "vertical",
					layout_config = { prompt_position = "top" },
				})
			end)
		end,
	},

	-- ======== КОММЕНТАРИИ ========
	{
		"numToStr/Comment.nvim",
		opts = {
			-- Конфигурация по умолчанию
			padding = true, -- Добавлять пробел после комментария
			sticky = true, -- Курсор остается на месте после комментирования
			ignore = nil, -- Регулярные выражения для игнорирования
			toggler = {
				line = "gcc", -- Комментирование одной строки
				block = "gbc", -- Комментирование блока
			},
			opleader = {
				line = "gc", -- Комментирование в визуальном режиме
				block = "gb", -- Комментирование блока в визуальном режиме
			},
			extra = {
				above = "gcO", -- Добавить комментарий выше
				below = "gco", -- Добавить комментарий ниже
				eol = "gcA", -- Добавить комментарий в конец строки
			},
			mappings = {
				basic = true, -- Включить базовые маппинги
				extra = true, -- Включить дополнительные маппинги
			},
		},
		config = function()
			require("Comment").setup()

			-- Кастомные маппинги для Space + /
			vim.keymap.set("n", "<leader>/", function()
				require("Comment.api").toggle.linewise.current()
			end, { desc = "Комментировать строку" })

			vim.keymap.set("v", "<leader>/", function()
				local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
				vim.api.nvim_feedkeys(esc, "nx", false)
				require("Comment.api").toggle.linewise(vim.fn.visualmode())
			end, { desc = "Комментировать выделение" })
		end,
	},

	-- ======== ФАЙЛОВЫЙ БРАУЗЕР ========
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = { width = 35 },
				renderer = { highlight_git = true },
				actions = { open_file = { quit_on_open = false } },
			})
			vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
		end,
	},

	-- ======== ПОДСВЕТКА ========
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({
					-- ===========================
					layout_strategy = "horizontal", -- 'horizontal' → список слева, предпросмотр справа
					-- 'vertical' → список сверху, предпросмотр снизу
					layout_config = {
						prompt_position = "top", -- строка поиска вверху
						preview_width = 0.5, -- сколько места занимает предпросмотр справа (0.0 - 1.0)
						width = 0.9, -- ширина всего окна Telescope (0.0 - 1.0)
						height = 0.8, -- высота окна (0.0 - 1.0)
						mirror = false, -- если true, меняет местами список и превью
					},
					sorting_strategy = "ascending", -- 'ascending' → список сверху вниз (Tab вниз)
					-- 'descending' → список снизу вверх
					-- ===========================
				})
			end)
		end,
	},

	-- ======== АВТОДОПОЛНЕНИЕ ========
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp-signature-help",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						local col = vim.fn.col(".") - 1
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
							-- Если в начале строки или перед курсором пробел, вставляем таб
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", true)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				-- ДОБАВЬТЕ ЭТОТ БЛОК ДЛЯ СТИЛЕЙ ОКОН:
				window = {
					completion = {
						border = "rounded",
						winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Search:None",
						scrollbar = true,
					},
					documentation = {
						border = "rounded",
						winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Search:None",
						scrollbar = true,
						max_width = 80,
						max_height = 20,
					},
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind_icons = {
							Text = "",
							Method = "󰆧",
							Function = "󰊕",
							Constructor = "",
							Field = "󰇽",
							Variable = "󰂡",
							Class = "󰠱",
							Interface = "",
							Module = "",
							Property = "󰜢",
							Unit = "",
							Value = "󰎠",
							Enum = "",
							Keyword = "󰌋",
							Snippet = "",
							Color = "󰏘",
							File = "󰈙",
							Reference = "",
							Folder = "󰉋",
							EnumMember = "",
							Constant = "󰏿",
							Struct = "",
							Event = "",
							Operator = "󰆕",
							TypeParameter = "󰅲",
						}

						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]

						return vim_item
					end,
				},
			})

			-- Стили для окон автодополнения
			vim.cmd([[
                highlight! NormalFloat guibg=#1a1b26
                highlight! FloatBorder guifg=#7aa2f7 guibg=#1a1b26
                highlight! PmenuSel guibg=#283457
            ]])
		end,
	},

	-- ======== LSP (СМАРТ-ПРОЕКТЫ) ========
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Настройка Mason
			require("mason").setup()
			require("mason-lspconfig").setup({
				automatic_installation = true,
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Настройка LSP серверов через новый API vim.lsp.start
			local servers = {
				clangd = {
					capabilities = capabilities,
				},
				pyright = {
					capabilities = capabilities,
				},
				lua_ls = {
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
						},
					},
				},
				zls = {
					capabilities = capabilities,
				},
			}

			-- Автоматический запуск LSP серверов при открытии файлов
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "c", "cpp", "python", "lua", "zig" },
				callback = function(args)
					local bufnr = args.buf
					local ft = vim.bo[bufnr].filetype

					-- Соответствие типов файлов и LSP серверов
					local servers_by_ft = {
						c = "clangd",
						cpp = "clangd",
						python = "pyright",
						lua = "lua_ls",
						zig = "zls",
					}

					local server_name = servers_by_ft[ft]
					if server_name and servers[server_name] then
						-- Используем новый API vim.lsp.start
						vim.lsp.start({
							name = server_name,
							bufnr = bufnr,
							capabilities = servers[server_name].capabilities,
							settings = servers[server_name].settings,
							root_dir = vim.fs.dirname(vim.fs.find({
								"CMakeLists.txt",
								"compile_commands.json",
								"pyproject.toml",
								"setup.py",
								"requirements.txt",
								"build.zig",
								".git",
							}, { upward = true })[1] or vim.loop.cwd()),
						})
					end
				end,
			})

			-- Ручной запуск LSP для уже открытых буферов
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_loaded(bufnr) then
							local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
							local servers_by_ft = {
								c = "clangd",
								cpp = "clangd",
								python = "pyright",
								lua = "lua_ls",
								zig = "zls",
							}

							local server_name = servers_by_ft[ft]
							if server_name and servers[server_name] then
								vim.lsp.start({
									name = server_name,
									bufnr = bufnr,
									capabilities = servers[server_name].capabilities,
									settings = servers[server_name].settings,
									root_dir = vim.fs.dirname(vim.fs.find({
										"CMakeLists.txt",
										"compile_commands.json",
										"pyproject.toml",
										"setup.py",
										"requirements.txt",
										"build.zig",
										".git",
									}, { upward = true })[1] or vim.loop.cwd()),
								})
							end
						end
					end
				end,
			})

			-- Клавиши для LSP
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Перейти к определению" })
			vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Найти ссылки" })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Показать документацию" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Переименовать" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Код действия" })

			-- Ошибки только при наведении
			vim.diagnostic.config({
				virtual_text = false,
				underline = true,
				signs = false,
				update_in_insert = true,
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
		end,
	},

	-- ======== ФОРМАТИРОВАНИЕ ========
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					c = { "clang-format" },
					cpp = { "clang-format" },
					python = { "black" },
					lua = { "stylua" },
					zig = { "zig fmt" },
				},
				format_on_save = { timeout_ms = 500, lsp_fallback = true },
			})
		end,
	},

	-- ======== ВКЛАДКИ ========
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({})
			vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
			vim.keymap.set("n", "<C-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
		end,
	},

	-- ======== АВТОСКОБКИ ========
	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },

	-- ======== СТАТУСБАР ========
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					section_separators = "",
					component_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = { "filename" },
					lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
})

-- ===========================
--         ДОПОЛНИТЕЛЬНО
-- ===========================
vim.cmd("colorscheme tokyonight")

-- Смена темы Space + t + h
vim.keymap.set("n", "<leader>th", function()
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

-- Очищать подсветку поиска по нажатию Escape в нормальном режиме
vim.keymap.set("n", "<Esc>", function()
	if vim.fn.getreg("/") ~= "" then -- если есть активный поиск
		vim.cmd("nohlsearch") -- очищаем подсветку
	end
	return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
end, { noremap = true, expr = true })
