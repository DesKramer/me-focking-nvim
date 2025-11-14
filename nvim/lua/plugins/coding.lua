-- Coding assistance plugins

return {
	-- COSINE GENIE
	{
		dir = "/Users/desmondkramer/Documents/Code/cosine-monorepo/apps/neovim/",
		name = "cosine-neovim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim", -- optional for :CosinePickChanges
		},
		config = function()
			require("cosine").setup()
		end,
	},

	-- Treesitter for better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"c",
					"cpp",
					"css",
					"dockerfile",
					"go",
					"html",
					"javascript",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"rust",
					"tsx",
					"typescript",
					"vim",
					"yaml",
				},
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
				autotag = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["ii"] = "@conditional.inner",
							["ai"] = "@conditional.outer",
							["il"] = "@loop.inner",
							["al"] = "@loop.outer",
							["at"] = "@comment.outer",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
				},
			})
		end,
	},

	-- Show current context (function/class) at the top of the window
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 3, -- number of lines to show for context, 0 for unlimited
				multiline_threshold = 20,
				trim_scope = "outer",
				mode = "cursor",
				separator = "─",
				zindex = 20,
				on_attach = nil,
			})
			-- Keymaps
			vim.keymap.set("n", "<leader>uc", function()
				require("treesitter-context").toggle()
			end, { desc = "Toggle Treesitter Context" })
			vim.keymap.set("n", "[c", function()
				require("treesitter-context").go_to_context()
			end, { desc = "Jump to context" })
		end,
	},
 
	-- Debugging (simplified configuration)
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{ "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", desc = "Toggle breakpoint" },
			{ "<leader>dc", "<cmd>lua require('dap').continue()<CR>", desc = "Continue" },
			{ "<leader>di", "<cmd>lua require('dap').step_into()<CR>", desc = "Step into" },
			{ "<leader>do", "<cmd>lua require('dap').step_over()<CR>", desc = "Step over" },
			{ "<leader>dO", "<cmd>lua require('dap').step_out()<CR>", desc = "Step out" },
			{ "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", desc = "Open REPL" },
			{ "<leader>dl", "<cmd>lua require('dap').run_last()<CR>", desc = "Run last" },
			{ "<leader>dt", "<cmd>lua require('dap').terminate()<CR>", desc = "Terminate" },
		},
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				keys = {
					{ "<leader>du", "<cmd>lua require('dapui').toggle()<CR>", desc = "Toggle Debug UI" },
				},
				config = function()
					require("dapui").setup()
				end,
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				config = function()
					require("nvim-dap-virtual-text").setup()
				end,
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Automatically open and close dapui
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	-- Test runner
	{
		"nvim-neotest/neotest",
		lazy = true,
		ft = { "python", "javascript", "typescript", "go", "rust" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
		config = function()
			require("neotest").setup({
				adapters = {},
				status = {
					enabled = true,
					signs = true,
					virtual_text = false,
				},
				icons = {
					expanded = "",
					collapsed = "",
					failed = "",
					passed = "",
					running = "",
					skipped = "",
					unknown = "",
				},
			})

			-- Keymaps
			vim.keymap.set("n", "<leader>tt", function()
				require("neotest").run.run()
			end, { desc = "Run nearest test" })
			vim.keymap.set("n", "<leader>tf", function()
				require("neotest").run.run(vim.fn.expand("%"))
			end, { desc = "Run file tests" })
			vim.keymap.set("n", "<leader>ta", function()
				require("neotest").run.run(vim.fn.getcwd())
			end, { desc = "Run all tests" })
			vim.keymap.set("n", "<leader>ts", function()
				require("neotest").summary.toggle()
			end, { desc = "Toggle test summary" })
		end,
	},

	-- REST client
	{
		"rest-nvim/rest.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = "http",
		config = function()
			require("rest-nvim").setup({
				result_split_horizontal = false,
				result_split_in_place = false,
				skip_ssl_verification = false,
				encode_url = true,
				highlight = {
					enabled = true,
					timeout = 150,
				},
				result = {
					show_url = true,
					show_http_info = true,
					show_headers = true,
					formatters = {
						json = "jq",
						html = function(body)
							return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
						end,
					},
				},
			})

			vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim", { desc = "Run REST request" })
			vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview", { desc = "Preview REST request" })
			vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast", { desc = "Run last REST request" })
		end,
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		config = function()
			vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle markdown preview" })
		end,
	},

	-- Better folding
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})

			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except" })
			vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
		end,
	},
}
