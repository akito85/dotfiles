-- Plugins setup with lazy.nvim
require("lazy").setup({
  -- centered column mode or zen
  {"shortcuts/no-neck-pain.nvim", version = "*"},

  -- Mason for LSP installation
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "basedpyright", "ts_ls", "clangd", "rust_analyzer", "gopls", "julials", "cssls", "jsonls", "yamlls", "tailwindcss", "kotlin_language_server" },
        automatic_installation = true,
      }
    end,
  },

  -- nvim tmux navigation
  {
    'numToStr/Navigator.nvim',
    config = function()
      require('Navigator').setup()

      -- Setup keymaps
      vim.keymap.set({'n', 't'}, '<C-h>', '<CMD>NavigatorLeft<CR>')
      vim.keymap.set({'n', 't'}, '<C-l>', '<CMD>NavigatorRight<CR>')
      vim.keymap.set({'n', 't'}, '<C-k>', '<CMD>NavigatorUp<CR>')
      vim.keymap.set({'n', 't'}, '<C-j>', '<CMD>NavigatorDown<CR>')
    end
  },

  -- LSP
  -- AI completion via local llama2.cpp
  -- check the code below

  {
    "huggingface/llm.nvim",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {
      -- llama2.cpp speaks OpenAI API
      api_token = "",                     -- no token needed for local
      model = "", -- llama-2-7b-chat       -- more descriptive label
      url = "http://localhost:8012/v1/completions",
      
      -- Generation parameters - tuned for code completion
      max_tokens = 64,
      temperature = 0.1,                  -- Lower for more deterministic code
      top_p = 0.95,
      frequency_penalty = 0.0,
      presence_penalty = 0.0,
      
      -- Prompt engineering for better code completion
      query_params = {
        stop = { "\n\n", "\n    ", "```", "---" },  -- Better stop tokens
        stream = true,                    -- Enable streaming for faster response
      },
      
      -- Context configuration
      context_window = 2048,              -- Adjust based on your model
      enable_suggestions_on_startup = false,
      enable_suggestions_on_files = true,
      
      -- File type restrictions
      ft = { 
        "lua", "python", "rust", "go", "javascript", "typescript", 
        "c", "cpp", "julia", "bash", "sh", "vim", "markdown" 
      },
      
      -- Performance tuning
      debounce_ms = 150,
      request_timeout = 5000,             -- 5 second timeout
      max_context_after = 500,            -- Characters after cursor
      max_context_before = 1500,          -- Characters before cursor
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Use new vim.lsp.config API (Neovim 0.11+)
      local cmp_nvim_lsp = require('cmp_nvim_lsp')

      -- Enhanced capabilities with latest defaults
      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
      
      -- Enable additional capabilities
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = { 'documentation', 'detail', 'additionalTextEdits' }
      }
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
      capabilities.textDocument.colorProvider = { dynamicRegistration = false }

      -- Modern diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = '',
          source = 'if_many',
          spacing = 2,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '󰌵',
          }
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      })

      -- Modern LSP handlers with updated API
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = 'rounded',
          title = 'Hover',
        }
      )

      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = 'rounded',
          title = 'Signature Help',
        }
      )

      -- Common server setup function using new vim.lsp.config API
      local function setup_server(server_name, opts)
        local server_opts = {
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 150,
          },
        }

        if opts then
          server_opts = vim.tbl_deep_extend('force', server_opts, opts)
        end

        -- Use new vim.lsp.config API
        vim.lsp.config[server_name] = server_opts
      end

      -- Python - Basedpyright (modern successor to Pyright)
      setup_server('basedpyright', {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
              typeCheckingMode = 'standard', -- Updated from 'basic'
              autoImportCompletions = true,
              indexing = true,
              include = { "**/*.py" },
              exclude = {
                "**/node_modules",
                "**/__pycache__",
                "**/.*",
              },
            },
            disableOrganizeImports = false,
          },
        },
      })

      -- TypeScript/JavaScript - ts_ls with modern settings
      setup_server('ts_ls', {
        init_options = {
          preferences = {
            disableSuggestions = false,
            quotePreference = 'auto',
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            includeCompletionsWithSnippetText = true,
            includeAutomaticOptionalChainCompletions = true,
          },
        },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'literal',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayVariableTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            suggest = {
              includeCompletionsForModuleExports = true,
              includeAutomaticOptionalChainCompletions = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayVariableTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            suggest = {
              includeCompletionsForModuleExports = true,
              includeAutomaticOptionalChainCompletions = true,
            },
          },
        },
      })

      -- C/C++ - clangd with latest options
      setup_server('clangd', {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
          '--enable-config',
          '--offset-encoding=utf-16',
        },
        root_markers = {
          '.clangd',
          '.clang-tidy',
          '.clang-format',
          'compile_commands.json',
          'compile_flags.txt',
          'configure.ac',
          '.git'
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
      })

      -- Rust - rust_analyzer with comprehensive modern settings
      setup_server('rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {
            imports = {
              granularity = {
                group = 'module',
              },
              prefix = 'self',
              enforce = true,
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
              features = 'all',
              runBuildScripts = true,
            },
            procMacro = {
              enable = true,
              ignored = {},
            },
            checkOnSave = true,
            check = {
              command = 'clippy',
              features = 'all',
            },
            completion = {
              addCallArgumentSnippets = true,
              addCallParenthesis = true,
              autoimport = {
                enable = true,
              },
              autoself = {
                enable = true,
              },
              postfix = {
                enable = true,
              },
              privateEditable = {
                enable = false,
              },
            },
            diagnostics = {
              enable = true,
              experimental = {
                enable = false,
              },
            },
            hover = {
              actions = {
                enable = true,
                implementations = {
                  enable = true,
                },
                references = {
                  enable = true,
                },
                run = {
                  enable = true,
                },
              },
              documentation = {
                enable = true,
              },
              links = {
                enable = true,
              },
            },
            inlayHints = {
              bindingModeHints = {
                enable = false,
              },
              chainingHints = {
                enable = true,
              },
              closingBraceHints = {
                enable = true,
                minLines = 25,
              },
              closureReturnTypeHints = {
                enable = 'never',
              },
              discriminantHints = {
                enable = 'never',
              },
              expressionAdjustmentHints = {
                enable = 'never',
              },
              implicitDrops = {
                enable = false,
              },
              lifetimeElisionHints = {
                enable = 'never',
                useParameterNames = false,
              },
              maxLength = 25,
              parameterHints = {
                enable = true,
              },
              reborrowHints = {
                enable = 'never',
              },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
            joinLines = {
              joinElseIf = true,
              joinAssignments = true,
              removeTrailingComma = true,
              unwrapTrivialBlock = true,
            },
            lens = {
              enable = true,
              implementations = {
                enable = true,
              },
              references = {
                adt = {
                  enable = true,
                },
                enumVariant = {
                  enable = true,
                },
                method = {
                  enable = true,
                },
                trait = {
                  enable = true,
                },
              },
              run = {
                enable = true,
              },
            },
          },
        },
      })

      -- Go - gopls with latest features
      setup_server('gopls', {
        settings = {
          gopls = {
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
              shadow = true,
            },
            experimentalPostfixCompletions = true,
            gofumpt = true,
            staticcheck = true,
            usePlaceholders = true,
            completeUnimported = true,
            matcher = 'Fuzzy',
            diagnosticsDelay = '500ms',
            symbolMatcher = 'fuzzy',
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
          },
        },
      })

      -- Julia - julials with modern configuration
      setup_server('julials', {
        settings = {
          julia = {
            lint = {
              run = true,
              missingrefs = 'none',
              disabledDirs = { 'docs', 'test' },
            },
            completions = {
              enable = true,
            },
            hover = {
              enable = true,
            },
            format = {
              indent = 4,
              compile = 'system',
            },
          },
        },
      })

      -- CSS - cssls with enhanced features
      setup_server('cssls', {
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = 'ignore',
              vendorPrefix = 'warning',
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = 'ignore',
              vendorPrefix = 'warning',
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = 'ignore',
              vendorPrefix = 'warning',
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
        },
      })

      -- JSON - jsonls with comprehensive schema support
      setup_server('jsonls', {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas({
              select = {
                '.eslintrc',
                'package.json',
                'tsconfig.json',
                'jsconfig.json',
              },
            }),
            validate = { enable = true },
            format = {
              enable = true,
            },
            completion = {
              enable = true,
            },
          },
        },
      })

      -- YAML - yamlls with enhanced schema handling
      setup_server('yamlls', {
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = '',
            },
            schemas = require('schemastore').yaml.schemas({
              select = {
                'kustomization.yaml',
                'GitHub Workflow',
                'docker-compose.yml',
              },
            }),
            validate = true,
            format = {
              enable = true,
              singleQuote = false,
              bracketSpacing = true,
            },
            hover = true,
            completion = true,
            customTags = {
              '!fn',
              '!And',
              '!If',
              '!Not',
              '!Equals',
              '!Or',
              '!FindInMap sequence',
              '!Base64',
              '!Cidr',
              '!Ref',
              '!Sub',
              '!GetAtt',
              '!GetAZs',
              '!ImportValue',
              '!Select',
              '!Split',
              '!Join sequence',
            },
          },
        },
      })

      -- Tailwind CSS with modern configuration
      setup_server('tailwindcss', {
        filetypes = { 
          'html', 
          'css', 
          'scss', 
          'javascript', 
          'typescript', 
          'javascriptreact', 
          'typescriptreact', 
          'vue', 
          'svelte',
          'astro',
          'php',
          'twig',
          'erb',
          'slim',
          'haml',
          'blade',
          'liquid',
        },
        init_options = {
          userLanguages = {
            eelixir = 'html-eex',
            eruby = 'erb',
          },
        },
        settings = {
          tailwindCSS = {
            classAttributes = { 
              'class', 
              'className', 
              'class:list', 
              'classList', 
              'ngClass',
              'classes',
            },
            lint = {
              cssConflict = 'warning',
              invalidApply = 'error',
              invalidConfigPath = 'error',
              invalidScreen = 'error',
              invalidTailwindDirective = 'error',
              invalidVariant = 'error',
              recommendedVariantOrder = 'warning',
            },
            validate = true,
            experimental = {
              classRegex = {
                'tw`([^`]*)',
                { 'clsx\\(([^)]*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                { 'classnames\\(([^)]*)\\)', "'([^']*)'" },
              },
            },
          },
        },
      })

      -- Flutter & Dart - Using flutter-tools.nvim (DO NOT use dartls directly)
      -- Note: flutter-tools.nvim handles dartls automatically and provides enhanced features
      -- This should be configured as a separate plugin, not through lspconfig
      
      -- Kotlin Language Server
      setup_server('kotlin_language_server', {
        settings = {
          kotlin = {
            compiler = {
              jvm = {
                target = '17',
              },
            },
            completion = {
              snippets = {
                enabled = true,
              },
            },
            linting = {
              debounceTime = 250,
            },
            indexing = {
              enabled = true,
            },
            externalSources = {
              useKlsScheme = true,
              autoConvertToKotlin = true,
            },
            inlayHints = {
              typeHints = true,
              parameterHints = true,
              chainingHints = true,
            },
          },
        },
        root_markers = { 'settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts', '.git' },
        init_options = {
          storagePath = vim.fn.expand('~/.cache/kotlin-language-server'),
        },
      })

      -- Java - Eclipse JDT LS (Use nvim-jdtls plugin for enhanced features)
      -- Note: For full Java support, use nvim-jdtls plugin instead of basic lspconfig
      -- This is a fallback configuration for basic Java support
      local function get_jdtls_config()
        local home = vim.fn.expand('~')
        local workspace_path = home .. '/.cache/jdtls/workspace/'
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        local workspace_dir = workspace_path .. project_name
        
        return {
          cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xmx1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
            '-configuration', home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',
            '-data', workspace_dir,
          },
          root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts' },
          settings = {
            java = {
              home = '/usr/lib/jvm/java-21-openjdk', -- Adjust to your Java 21+ installation
              eclipse = {
                downloadSources = true,
              },
              configuration = {
                updateBuildConfiguration = 'interactive',
                runtimes = {
                  {
                    name = 'JavaSE-21',
                    path = '/usr/lib/jvm/java-21-openjdk',
                    default = true,
                  },
                },
              },
              maven = {
                downloadSources = true,
              },
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
              },
              references = {
                includeDecompiledSources = true,
              },
              format = {
                enabled = true,
                settings = {
                  url = vim.fn.stdpath('config') .. '/lang-servers/intellij-java-google-style.xml',
                  profile = 'GoogleStyle',
                },
              },
              signatureHelp = { enabled = true },
              contentProvider = { preferred = 'fernflower' },
              completion = {
                favoriteStaticMembers = {
                  'org.hamcrest.MatcherAssert.assertThat',
                  'org.hamcrest.Matchers.*',
                  'org.hamcrest.CoreMatchers.*',
                  'org.junit.jupiter.api.Assertions.*',
                  'java.util.Objects.requireNonNull',
                  'java.util.Objects.requireNonNullElse',
                  'org.mockito.Mockito.*',
                },
                importOrder = {
                  'java',
                  'javax',
                  'com',
                  'org',
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              codeGeneration = {
                toString = {
                  template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                },
                useBlocks = true,
              },
            },
          },
          capabilities = capabilities,
          flags = {
            allow_incremental_sync = true,
          },
        }
      end

      -- Only setup basic jdtls if nvim-jdtls is not available
      local ok, _ = pcall(require, 'jdtls')
      if not ok then
        setup_server('jdtls', get_jdtls_config())
      end

      -- Spring Boot Language Server (STS4) - handled by nvim-java plugin
      -- Note: Spring Boot Tools (STS4) is automatically handled by nvim-java
      -- No separate mason installation needed - it's included with nvim-java setup
      
      -- Dart Language Server setup
      -- Note: Dart LSP is bundled with Flutter/Dart SDK, no Mason installation needed
      -- flutter-tools.nvim will handle dartls automatically

      -- Auto-enable LSP servers on FileType (required for vim.lsp.config API)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local bufnr = args.buf
          local filetype = vim.bo[bufnr].filetype

          -- Map of filetypes to server names
          local ft_to_server = {
            python = 'basedpyright',
            javascript = 'ts_ls',
            javascriptreact = 'ts_ls',
            typescript = 'ts_ls',
            typescriptreact = 'ts_ls',
            c = 'clangd',
            cpp = 'clangd',
            objc = 'clangd',
            objcpp = 'clangd',
            cuda = 'clangd',
            rust = 'rust_analyzer',
            go = 'gopls',
            gomod = 'gopls',
            gowork = 'gopls',
            gotmpl = 'gopls',
            julia = 'julials',
            css = 'cssls',
            scss = 'cssls',
            less = 'cssls',
            json = 'jsonls',
            jsonc = 'jsonls',
            yaml = 'yamlls',
            html = 'tailwindcss',
            vue = 'tailwindcss',
            svelte = 'tailwindcss',
            kotlin = 'kotlin_language_server',
            java = 'jdtls',
          }

          local server = ft_to_server[filetype]
          if server and vim.lsp.config[server] then
            vim.lsp.enable(server)
          end
        end,
      })

      -- Enhanced keymaps with modern vim.keymap.set
      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.silent = opts.silent ~= false
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      -- LSP navigation and actions
      map('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      map('n', '<leader>gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
      map('n', '<leader>gr', vim.lsp.buf.references, { desc = 'Show references' })
      map('n', '<leader>gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
      map('n', '<leader>gt', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })
      map('n', '<leader>gh', vim.lsp.buf.hover, { desc = 'Show hover information' })
      map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
      map({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
      
      -- Formatting
      map({'n', 'v'}, '<leader>f', function()
        vim.lsp.buf.format({ 
          async = true,
          filter = function(client)
            return client.name ~= 'ts_ls' -- Prefer prettier for TS/JS
          end
        })
      end, { desc = 'Format buffer/selection' })

      -- Diagnostics
      map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })
      map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
      map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
      map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Add diagnostics to location list' })
      map('n', '<leader>Q', vim.diagnostic.setqflist, { desc = 'Add diagnostics to quickfix list' })

      -- Signature help
      map('i', '<C-h>', vim.lsp.buf.signature_help, { desc = 'Signature help' })

      -- Inlay hints toggle (Neovim 0.10+)
      map('n', '<leader>ih', function()
        local current_buf = vim.api.nvim_get_current_buf()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = current_buf })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = current_buf })
      end, { desc = 'Toggle inlay hints' })

      -- Modern LspAttach autocmd
      local lsp_group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })
      
      vim.api.nvim_create_autocmd('LspAttach', {
        group = lsp_group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          -- Enable inlay hints if supported (Neovim 0.10+)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          -- Enable completion triggered by <c-x><c-o>
          vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Enable document highlighting if supported
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = bufnr,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd('CursorMoved', {
              buffer = bufnr,
              group = highlight_group,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- LspDetach autocmd to clean up
      vim.api.nvim_create_autocmd('LspDetach', {
        group = lsp_group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
          end
          vim.lsp.buf.clear_references()
        end,
      })
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'b0o/schemastore.nvim',
      
      -- Optional but highly recommended for enhanced features:
      {
        'akinsho/flutter-tools.nvim', -- Updated package name
        lazy = false,
        ft = { 'dart' },
        dependencies = {
          'nvim-lua/plenary.nvim',
          'stevearc/dressing.nvim', -- optional for vim.ui.select
        },
        config = function()
          require('flutter-tools').setup({
            ui = {
              border = 'rounded',
              notification_style = 'native',
            },
            decorations = {
              statusline = {
                app_version = false,
                device = true,
                project_config = false,
              },
            },
            debugger = {
              enabled = false,
              run_via_dap = false,
              exception_breakpoints = {},
              evaluate_to_string_in_debug_views = true,
              register_configurations = function(paths)
                require('dap').configurations.dart = {
                  {
                    type = 'dart',
                    request = 'launch',
                    name = 'Launch flutter',
                    dartSdkPath = paths.dart_sdk,
                    flutterSdkPath = paths.flutter_sdk,
                    program = '${workspaceFolder}/lib/main.dart',
                    cwd = '${workspaceFolder}',
                  },
                }
              end,
            },
            flutter_path = nil, -- <-- this takes priority over the lookup
            flutter_lookup_cmd = nil, -- example "dirname $(which flutter)" or "asdf where flutter"
            root_patterns = { '.git', 'pubspec.yaml' }, -- patterns to find the root of your flutter project
            fvm = false, -- takes priority over path, uses <workspace>/.fvm/flutter_sdk if enabled
            widget_guides = {
              enabled = false,
            },
            closing_tags = {
              highlight = 'ErrorMsg', -- highlight for the closing tag
              prefix = '>', -- character to use for close tag e.g. > Widget
              priority = 10, -- priority of virtual text
              enabled = true -- set to false to disable
            },
            dev_log = {
              enabled = true,
              notify_errors = false, -- if there is an error whilst running then notify the user
              open_cmd = 'tabedit', -- command to use to open the log buffer
            },
            dev_tools = {
              autostart = false, -- autostart devtools server if not detected
              auto_open_browser = false, -- Automatically opens devtools in the browser
            },
            outline = {
              open_cmd = '30vnew', -- command to use to open the outline buffer
              auto_open = false -- if true this will open the outline automatically when it is first populated
            },
            lsp = {
              color = { -- show the derived colours for dart variables
                enabled = false, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
                background = false, -- highlight the background
                background_color = nil, -- required, when background is transparent (i.e. background_color = { r = 19, g = 17, b = 24},)
                foreground = false, -- highlight the foreground
                virtual_text = true, -- show the highlight using virtual text
                virtual_text_str = '■', -- the virtual text character to highlight
              },
              on_attach = function(client, bufnr)
                -- Enhanced on_attach for Flutter
                local opts = { buffer = bufnr, silent = true }
                vim.keymap.set('n', '<leader>Fc', '<cmd>Telescope flutter commands<CR>', opts)
                vim.keymap.set('n', '<leader>Fr', '<cmd>FlutterReload<CR>', opts)
                vim.keymap.set('n', '<leader>FR', '<cmd>FlutterRestart<CR>', opts)
                vim.keymap.set('n', '<leader>Fq', '<cmd>FlutterQuit<CR>', opts)
                vim.keymap.set('n', '<leader>Fd', '<cmd>FlutterDevices<CR>', opts)
                vim.keymap.set('n', '<leader>Fe', '<cmd>FlutterEmulators<CR>', opts)
                vim.keymap.set('n', '<leader>Fo', '<cmd>FlutterOutlineToggle<CR>', opts)
                vim.keymap.set('n', '<leader>Ft', '<cmd>FlutterDevTools<CR>', opts)
                vim.keymap.set('n', '<leader>Fl', '<cmd>FlutterLogClear<CR>', opts)
              end,
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
              -- OR you can specify a function to deactivate or change or control how the config is created
              capabilities = function(config)
                config.specificThingIDontWant = false
                return config
              end,
              -- see the link below for details on each option:
              -- https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#client-workspace-configuration
              settings = {
                showTodos = true,
                completeFunctionCalls = true,
                analysisExcludedFolders = {
                  vim.fn.expand('$HOME/AppData/Local/Pub/Cache'),
                  vim.fn.expand('$HOME/.pub-cache'),
                  vim.fn.expand('/opt/homebrew/'),
                  vim.fn.expand('$HOME/tools/flutter/'),
                },
                renameFilesWithClasses = 'prompt', -- "always"
                enableSnippets = true,
                updateImportsOnRename = true, -- Whether to update imports and other directives when files are renamed. Required for `FlutterRename` command.
              }
            }
          })
        end,
      },
      
      {
        'nvim-java/nvim-java', -- For comprehensive Java support
        ft = { 'java' },
        config = function()
          require('java').setup({
            -- Your nvim-java configuration
            root_markers = {
              'settings.gradle',
              'settings.gradle.kts',
              'pom.xml',
              'build.gradle',
              'mvnw',
              'gradlew',
              'build.gradle.kts',
              '.git',
            },
            java_test = {
              enable = true,
            },
            java_debug_adapter = {
              enable = true,
            },
            spring_boot_tools = {
              enable = true,
            },
            jdk = {
              auto_install = false,
            },
            notifications = {
              dap = true,
            },
          })
        end,
      },

      -- Alternative: Manual nvim-jdtls setup (if you prefer more control)
      {
        'mfussenegger/nvim-jdtls',
        ft = { 'java' },
        config = function()
          local function jdtls_setup()
            local jdtls = require('jdtls')
            local home = vim.fn.expand('~')
            local workspace_path = home .. '/.cache/jdtls/workspace/'
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
            local workspace_dir = workspace_path .. project_name

            -- Lombok support
            local lombok_path = home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar'
            
            local config = {
              cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-javaagent:' .. lombok_path,
                '-Xbootclasspath/a:' .. lombok_path,
                '-Xmx4g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '--add-opens', 'java.base/sun.nio.fs=ALL-UNNAMED',
                '-jar', vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
                '-configuration', home .. '/.local/share/nvim/mason/packages/jdtls/config_' .. (vim.fn.has('mac') == 1 and 'mac' or 'linux'),
                '-data', workspace_dir,
              },
              root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts'}),
              settings = {
                java = {
                  home = vim.fn.expand('~/.sdkman/candidates/java/current'), -- Adjust to your Java installation
                  eclipse = {
                    downloadSources = true,
                  },
                  configuration = {
                    updateBuildConfiguration = 'interactive',
                    runtimes = {
                      {
                        name = 'JavaSE-21',
                        path = vim.fn.expand('~/.sdkman/candidates/java/21.0.1-oracle/'),
                      },
                      {
                        name = 'JavaSE-17',
                        path = vim.fn.expand('~/.sdkman/candidates/java/17.0.9-oracle/'),
                      },
                    },
                  },
                  maven = {
                    downloadSources = true,
                  },
                  implementationsCodeLens = {
                    enabled = true,
                  },
                  referencesCodeLens = {
                    enabled = true,
                  },
                  references = {
                    includeDecompiledSources = true,
                  },
                  format = {
                    enabled = true,
                  },
                  signatureHelp = { enabled = true },
                  contentProvider = { preferred = 'fernflower' },
                  completion = {
                    favoriteStaticMembers = {
                      'org.hamcrest.MatcherAssert.assertThat',
                      'org.hamcrest.Matchers.*',
                      'org.hamcrest.CoreMatchers.*',
                      'org.junit.jupiter.api.Assertions.*',
                      'java.util.Objects.requireNonNull',
                      'java.util.Objects.requireNonNullElse',
                      'org.mockito.Mockito.*',
                      'org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*',
                      'org.springframework.test.web.servlet.result.MockMvcResultMatchers.*',
                    },
                    importOrder = {
                      'java',
                      'javax',
                      'com',
                      'org',
                    },
                  },
                  sources = {
                    organizeImports = {
                      starThreshold = 9999,
                      staticStarThreshold = 9999,
                    },
                  },
                  codeGeneration = {
                    toString = {
                      template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                    },
                    useBlocks = true,
                  },
                  inlayHints = {
                    parameterNames = {
                      enabled = 'all',
                    },
                  },
                },
              },
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
              on_attach = function(client, bufnr)
                -- JDTLS-specific keymaps
                local opts = { buffer = bufnr, silent = true }
                vim.keymap.set('n', '<leader>Jo', jdtls.organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize imports' }))
                vim.keymap.set('n', '<leader>Jv', jdtls.extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
                vim.keymap.set('n', '<leader>Jc', jdtls.extract_constant, vim.tbl_extend('force', opts, { desc = 'Extract constant' }))
                vim.keymap.set('v', '<leader>Jm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], vim.tbl_extend('force', opts, { desc = 'Extract method' }))
                vim.keymap.set('n', '<leader>Jt', jdtls.test_nearest_method, vim.tbl_extend('force', opts, { desc = 'Test nearest method' }))
                vim.keymap.set('n', '<leader>JT', jdtls.test_class, vim.tbl_extend('force', opts, { desc = 'Test class' }))
                vim.keymap.set('n', '<leader>Ju', '<CMD>JdtUpdateConfig<CR>', vim.tbl_extend('force', opts, { desc = 'Update config' }))
              end,
              init_options = {
                bundles = {}
              },
            }
            
            jdtls.start_or_attach(config)
          end

          vim.api.nvim_create_autocmd('FileType', {
            pattern = 'java',
            callback = jdtls_setup,
          })
        end,
      },

      -- Kotlin support
      {
        'udalov/kotlin-vim',
        ft = 'kotlin',
      },

      -- Additional LSP utilities
      {
        'j-hui/fidget.nvim', -- LSP progress notifications
        opts = {
          notification = {
            window = {
              winblend = 100,
            },
          },
        },
      },

      -- Better quickfix and location list
      {
        'kevinhwang91/nvim-bqf',
        ft = 'qf',
        config = function()
          require('bqf').setup({
            auto_enable = true,
            auto_resize_height = true,
            preview = {
              win_height = 12,
              win_vheight = 12,
              delay_syntax = 80,
              border_chars = { '┃', '┃', '━', '━', '┏', '┓', '┗', '┛', '█' },
              show_title = false,
              should_preview_cb = function(bufnr, qwinid)
                local ret = true
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                local fsize = vim.fn.getfsize(bufname)
                if fsize > 100 * 1024 then
                  ret = false
                end
                return ret
              end
            },
            func_map = {
              drop = 'o',
              openc = 'O',
              split = '<C-s>',
              tabdrop = '<C-t>',
              tabc = '',
              ptogglemode = 'z,',
            },
            filter = {
              fzf = {
                action_for = { ['ctrl-s'] = 'split', ['ctrl-t'] = 'tab drop' },
                extra_opts = { '--bind', 'ctrl-o:toggle-all', '--prompt', '> ' }
              }
            }
          })
        end,
      },
    },
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",             -- LSP completions
      "hrsh7th/cmp-buffer",               -- Buffer completions
      "hrsh7th/cmp-path",                 -- Path completions
      "hrsh7th/cmp-cmdline",              -- Command line completions
      "L3MON4D3/LuaSnip",                 -- Snippet engine
      "saadparwaiz1/cmp_luasnip",         -- Snippet completions
      "rafamadriz/friendly-snippets",     -- Predefined snippets
      "onsails/lspkind.nvim",             -- VS Code-like icons
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')
      
      -- Load VS Code style snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        
        -- Enhanced key mappings
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ 
            behavior = cmp.ConfirmBehavior.Replace,
            select = true 
          }),
          
          -- Tab/S-Tab for navigation with snippet support
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        
        -- Source priority and configuration
        sources = cmp.config.sources({
          { name = "nvim_lsp",  priority = 1000, max_item_count = 15 },
          { name = "luasnip",   priority = 900,  max_item_count = 5 },
          { name = "llm",       priority = 800,  max_item_count = 3 },  -- AI suggestions
        }, {
          { name = "buffer",    priority = 500,  max_item_count = 5, keyword_length = 3 },
          { name = "path",      priority = 400,  max_item_count = 5 },
        }),
        
        -- Formatting with icons
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
            before = function(entry, vim_item)
              -- Add source indicator
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                llm = "[AI]",
                buffer = "[Buf]",
                path = "[Path]",
              })[entry.source.name]
              return vim_item
            end,
          }),
        },
        
        -- Performance optimization
        performance = {
          debounce = 60,                  -- Faster debounce for better UX
          throttle = 30,                  -- Faster throttle
          fetching_timeout = 500,         -- Reasonable timeout
          max_view_entries = 12,          -- Limit visible items
        },
        
        -- Experimental features
        experimental = {
          ghost_text = true,              -- Show ghost text preview
        },
        
        -- Window configuration
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        
        -- Sorting for better relevance
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })
      
      -- Specific configuration for different file types
      cmp.setup.filetype({ 'json', 'yaml', 'toml' }, {
        sources = cmp.config.sources({
          { name = 'nvim_lsp', max_item_count = 15 },
          { name = 'buffer',   max_item_count = 8, keyword_length = 3 },
          { name = 'path',     max_item_count = 5 },
        }),
      })
      
      -- Command line completion
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
      
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end,
  },

  -- Telescope (file finder, grep)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
          },
          initial_mode = 'insert',
          selection_strategy = 'reset',
          sorting_strategy = 'ascending',
          layout_strategy = 'horizontal',
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "%.cache/",
          },
          generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          file_previewer = require('telescope.previewers').vim_buffer_cat.new,
          grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
          qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
          layout_config = {
            horizontal = { preview_width = 0.5 },
          },
          preview = {
            timeout = 200,
            filesize_limit = 1,
          },
        }
      }
    end
  },

  -- Neo-tree (file explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle Explorer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          scan_mode = "deep",
          bind_to_cwd = false,
          cwd_target = {
            sidebar = "tab",
            current = "window",
          },
        },
        window = {
          position = 'left',
          width = 30,
          mappings = {
            ["<space>"] = "none",
            -- Add a toggle mapping for <C-h> to toggle between neotree and buffer
            ["<C-h>"] = "toggle_preview", -- Use preview toggle as an example action
          },
        },
        event_handlers = {
          -- Fix for buffer clearing issue - don't unload current buffer on file_open
          {
            event = "file_opened",
            handler = function(file_path)
              -- Don't close the tree when opening a file
              -- and don't clear the buffer
              -- require("neo-tree.sources.manager").close_all()
              -- Optionally focus the opened file
              -- vim.cmd("e " .. vim.fn.fnameescape(file_path))
              vim.defer_fn(function()
                vim.cmd("e " .. vim.fn.fnameescape(file_path))
              end, 10)
            end
          },
        },
        enable_diagnostics = false,
        enable_git_status = false,
        enable_modified_markers = false,
        log_level = "warn",
        log_to_file = false,
        use_popups_for_input = true, -- Avoid floating windows that might use Tree-sitter
      })
    end
  },

  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'storm',
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = 'dark',
          floats = 'dark',
        },
      })
      vim.cmd('colorscheme tokyonight-storm')
    end
  },
  {
      'ggandor/leap.nvim',
      event = "VeryLazy",
      config = function()
          local leap = require('leap')
          leap.add_default_mappings()
          -- Reset 's' for compatibility with vim-surround if needed
          vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap-forward-to)', {})
          vim.keymap.set({'n', 'x', 'o'}, 'S', '<Plug>(leap-backward-to)', {})
      end,
  },
  {
      'ThePrimeagen/harpoon',
      branch = "harpoon2", -- Using the newer version
      dependencies = { "nvim-lua/plenary.nvim" },
      event = "VeryLazy",
      config = function()
          local harpoon = require("harpoon")
          harpoon:setup()

          -- FIXED: Changed append() to add() for Harpoon 2
          vim.keymap.set("n", "<leader>m", function() harpoon:list():add() end)
          vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

          -- Quick file navigation
          vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
          vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
          vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
          vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
      end,
  },
  {
      'unblevable/quick-scope',
      event = "VeryLazy",
      config = function()
          -- Trigger a highlight in the appropriate direction when pressing these keys
          vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}
      end,
  },

  -- file type plugin - SIMPLIFIED
  {
    "nathom/filetype.nvim",
    lazy = false, -- Load during startup
    priority = 1000, -- High priority to load before other plugins
    config = function()
      -- Simplified setup without complex overrides
      require("filetype").setup({
        overrides = {
          extensions = {
            lua = "lua", -- Use standard lua filetype
          },
        },
      })
    end
  },

  -- vim-gigutter - Lightweight git gutter for large files
  {
    "airblade/vim-gitgutter",
    event = "BufReadPre",
    init = function()
      -- Optimize gitgutter for performance
      vim.g.gitgutter_max_signs = 500
      vim.g.gitgutter_realtime = 0
      vim.g.gitgutter_eager = 0
      vim.g.gitgutter_sign_priority = 5
      vim.g.LargeFile = 10 -- 10 MB, matches LSP max_filesize

      -- Disable gitgutter for large files
      local git_group = vim.api.nvim_create_augroup("GitGutterLargeFiles", { clear = true })
      vim.api.nvim_create_autocmd({"BufReadPre"}, {
        group = git_group,
        pattern = "*", -- Added explicit pattern
        callback = function(ev)
          local max_filesize = vim.g.LargeFile * 1024 * 1024 -- Convert MB to bytes
          -- FIXED: Use vim.uv or vim.loop for fs_stat
          local stat = vim.uv and vim.uv.fs_stat or vim.loop.fs_stat
          local ok, stats = pcall(stat, ev.match)
          if ok and stats and (stats.size > max_filesize or stats.type == "directory") then
            vim.b.gitgutter_enabled = 0
          end
        end,
      })
    end
  },
  
  -- far.vim - Find and replace with performance in mind
  {
    "brooth/far.vim",
    cmd = {"Far", "Farp", "F", "Refar"},
    keys = {
      { "<leader>ffr", ":Far ", desc = "Find and Replace" },
      { "<leader>ffd", ":Fardo<CR>", desc = "Execute Far Replace" },
    },
    init = function()
      -- Configure Far.vim for better performance
      vim.g['far#source'] = vim.fn.executable("rg") == 1 and "rg" or "vimgrep"
      vim.g['far#limit'] = 1000
      vim.g['far#window_width'] = 60
      vim.g['far#file_mask_favorites'] = { "**/*.*", "**/*.lua", "**/*.vim", "**/*.txt" }
    end
  },

  -- nvim-lsp-file-operations - LSP-aware file operations
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    event = "LspAttach",
    config = function()
      require("lsp-file-operations").setup({
        -- Disable for large files
        enabled = function(bufnr)
          return not vim.b[bufnr].large_file
        end
      })
    end
  },

  -- Low-resource status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = false, -- Disable icons for performance
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
          disabled_filetypes = {},
          always_divide_middle = false,
          globalstatus = false, -- Use per-window statuslines
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'filename'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {'filename'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {'location'}
        },
        -- Optimize for large files
        extensions = {
          function()
            -- Custom extension for large files
            local large_file_extension = {
              sections = {
                lualine_a = {'mode'},
                lualine_b = {'filename'},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {'progress'},
                lualine_z = {}
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
              },
              filetypes = {'*'}
            }

            return large_file_extension
          end
        }
      }

      -- Create a custom status line for large files
      local status_group = vim.api.nvim_create_augroup("StatuslineLargeFiles", { clear = true })
      vim.api.nvim_create_autocmd({"BufReadPre", "FileReadPre"}, {
        group = status_group,
        pattern = "*", -- Added explicit pattern
        callback = function(ev)
          local file_size = vim.fn.getfsize(ev.match)
          if file_size > (vim.g.LargeFile or 10) * 1024 * 1024 or file_size == -2 then
            vim.opt_local.statusline = " %f %m%r%h%w [%{&ff}] "
            vim.opt_local.ruler = true
            vim.opt_local.laststatus = 1 -- Use a simplified statusline
          end
        end,
      })
    end
  },

  -- buffer manager that's light on resources
  {
    "j-morano/buffer_manager.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>b", "<cmd>lua require('buffer_manager.ui').toggle_quick_menu()<CR>", desc = "Buffer Manager" },
    },
    config = function()
      require("buffer_manager").setup({
        line_keys = "1234567890",
        select_menu_item_commands = {
          v = {
            key = "<C-v>",
            command = "vsplit"
          },
          h = {
            key = "<C-h>",
            command = "split"
          }
        },
        focus_alternate_buffer = false,
        short_file_names = true,
        short_term_names = true,
        loop_nav = true,
      })
    end
  },

  -- TreeSitter configuration with unified and optimized performance thresholds
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- File size thresholds
      local MAX_FILE_SIZE = 10 * 1024 * 1024 -- 10MB

      -- Get file size helper
      local function get_file_size(buf)
        local name = vim.api.nvim_buf_get_name(buf or 0)
        if name == "" then return 0 end
        
        local stat = vim.uv and vim.uv.fs_stat or vim.loop.fs_stat
        local ok, stats = pcall(stat, name)
        if ok and stats then
          return stats.size or 0
        end
        
        local size = vim.fn.getfsize(name)
        return size > 0 and size or 0
      end

      -- Disable function for large files
      local function disable_for_large_files(lang, buf)
        return get_file_size(buf) > MAX_FILE_SIZE
      end

      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "rust", "go", "python", "javascript", "typescript", "tsx",
          "json", "yaml", "markdown", "markdown_inline",
          "bash", "sql", "html", "css", "c", "cpp"
        },

        sync_install = false,
        auto_install = true,

        highlight = {
          enable = true,
          disable = disable_for_large_files,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
          disable = disable_for_large_files,
        },

        incremental_selection = {
          enable = true,
          disable = disable_for_large_files,
          keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
          },
        },

        textobjects = {
          select = {
            enable = true,
            disable = disable_for_large_files,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer", 
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
          },

          move = {
            enable = true,
            disable = disable_for_large_files,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer", 
              ["]a"] = "@parameter.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer", 
              ["[C"] = "@class.outer",
            },
          },

          swap = {
            enable = true,
            disable = disable_for_large_files,
            swap_next = {
              ["<leader>sp"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>sP"] = "@parameter.inner",
            },
          },

          lsp_interop = {
            enable = true,
            disable = disable_for_large_files,
            border = 'rounded',
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dc"] = "@class.outer",
            },
          },
        },
      })

      -- Performance optimization for large files
      vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
        group = vim.api.nvim_create_augroup("TreeSitterPerformance", { clear = true }),
        callback = function(ev)
          local filesize = get_file_size(ev.buf)
          if filesize > MAX_FILE_SIZE then
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":t")
            vim.notify(string.format("Large file detected: %s (%.1fMB) - TreeSitter disabled", 
              filename, filesize / 1024 / 1024), vim.log.levels.WARN)
            
            -- Additional performance optimizations for large files
            vim.bo[ev.buf].synmaxcol = 200
            vim.bo[ev.buf].syntax = ""
          end
        end
      })

      -- Utility commands
      vim.api.nvim_create_user_command("TSStatus", function()
        local buf = vim.api.nvim_get_current_buf()
        local filesize = get_file_size(buf)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
        local enabled = filesize <= MAX_FILE_SIZE
        
        print(string.format("File: %s (%.2fMB)", filename, filesize / 1024 / 1024))
        print(string.format("TreeSitter: %s", enabled and "ENABLED" or "DISABLED (>10MB)"))
      end, { desc = "Show TreeSitter status for current buffer" })
    end,
  },

  -- Only include necessary dependencies
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Flutter specific configuration
  {
      'nvim-flutter/flutter-tools.nvim',
      lazy = false,
      dependencies = {
          'nvim-lua/plenary.nvim',
          'stevearc/dressing.nvim', -- optional for vim.ui.select
      },
      config = true,
  }

}, {
  checker = { enabled = false }, -- Disable update checking
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  install = {
    colorscheme = { "tokyonight-storm" },
  },
})
