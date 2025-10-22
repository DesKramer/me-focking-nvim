-- LSP, completion, and snippets configuration

return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
    },
    config = function()
      -- Setup neodev for Neovim Lua API
      require("neodev").setup()

      -- Setup mason
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- Auto-install LSP servers
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "eslint",
          "html",
          "cssls",
          "tailwindcss",
          "pyright",
          "rust_analyzer",
          "gopls",
          "jsonls",
          "yamlls",
        },
        automatic_installation = true,
      })

      -- LSP keymaps
      local on_attach = function(client, bufnr)
        local keymap = vim.keymap
        local opts = { buffer = bufnr, silent = true }

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Go to definition"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show hover information"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Go to implementation"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show signature help"
        keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

        opts.desc = "Go to type definition"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "Rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Code action"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Find references"
        keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Format document"
        keymap.set("n", "<leader>fm", function()
          vim.lsp.buf.format({ async = true })
        end, opts)

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show diagnostics list"
        keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts)
      end

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Setup LSP servers using vim.lsp.config (Neovim 0.11+)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Helper to merge common opts
      local function with_common(opts)
        opts = opts or {}
        opts.capabilities = capabilities
        opts.on_attach = on_attach
        return opts
      end

      -- Lua
      vim.lsp.config.lua_ls = with_common({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- TypeScript/JavaScript
      vim.lsp.config.ts_ls = with_common({})
      vim.lsp.enable("ts_ls")

      -- Python
      vim.lsp.config.pyright = with_common({
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })
      vim.lsp.enable("pyright")

      -- Rust
      vim.lsp.config.rust_analyzer = with_common({
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            diagnostics = {
              enable = true,
              experimental = {
                enable = true,
              },
            },
            hover = {
              actions = {
                enable = true,
              },
            },
            lens = {
              enable = true,
              methodReferences = true,
              references = true,
            },
            completion = {
              postfix = {
                enable = true,
              },
            },
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      -- Go
      vim.lsp.config.gopls = with_common({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
      vim.lsp.enable("gopls")

      -- Other servers with default config
      for _, server in ipairs({ "html", "cssls", "tailwindcss", "jsonls", "yamlls", "eslint" }) do
        vim.lsp.config[server] = with_common({})
        vim.lsp.enable(server)
      end
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- Load snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
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
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  -- Better LSP UI
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
        },
        symbol_in_winbar = {
          enable = false,
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Show outline" })
      vim.keymap.set("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { desc = "Rename" })
      vim.keymap.set("n", "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Show line diagnostics" })
      vim.keymap.set("n", "<leader>lD", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { desc = "Show cursor diagnostics" })
      vim.keymap.set("n", "<leader>la", "<cmd>Lspsaga code_action<CR>", { desc = "Code action" })
      vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
    end,
  },

  -- Format on save
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          -- Use eslint_d for JS/TS files to respect project ESLint config
          javascript = { "eslint_d" },
          typescript = { "eslint_d" },
          javascriptreact = { "eslint_d" },
          typescriptreact = { "eslint_d" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          rust = { "rustfmt" },
          go = { "gofmt", "goimports" },
        },
        format_on_save = function(bufnr)
          -- Disable format on save for specific filetypes if needed
          local disable_filetypes = {}
          if vim.tbl_contains(disable_filetypes, vim.bo[bufnr].filetype) then
            return
          end
          
          -- Check if there's an ESLint config for JS/TS files
          local is_js_ts = vim.tbl_contains(
            { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            vim.bo[bufnr].filetype
          )
          
          if is_js_ts then
            -- Use ESLint for formatting JS/TS files
            return {
              timeout_ms = 500,
              lsp_fallback = false,
            }
          else
            -- Use LSP or configured formatter for other files
            return {
              timeout_ms = 500,
              lsp_fallback = true,
            }
          end
        end,
      })
    end,
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        python = { "pylint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}