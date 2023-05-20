return {
    {
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            vim.keymap.set('n', '<leader>pv', '<C-w>v<Cmd>Oil<CR>', { desc = "Open Oil file explorer" })
            require("oil").setup({
                keymaps = {
                    ["g?"] = "actions.show_help",
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = "actions.select_vsplit",
                    ["<C-h>"] = "actions.select_split",
                    ["<C-t>"] = "actions.select_tab",
                    -- ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = "actions.close",
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = "actions.parent",
                    ["_"] = "actions.open_cwd",
                    ["`"] = "actions.cd",
                    ["~"] = "actions.tcd",
                    ["g."] = "actions.toggle_hidden",
                },
                use_default_keymaps = false,
                view_options = {
                    show_hidden = true
                }
            })
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            -- name Telescope group in which-key
            require('which-key').register({ ['<leader>'] = { f = { name = " Telescope" } } })

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Telescope: Find files" })
            vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = "Telescope: Git files" })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Telescope: Live grep" })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Telescope: Buffers" })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Telescope: Help tags" })
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = "Telescope: References" })
            require("telescope").setup()
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                current_line_blame = true,
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then return ']c' end
                        vim.schedule(function() gs.next_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = "Git: next hunk" })

                    map('n', '[c', function()
                        if vim.wo.diff then return '[c' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = "Git: previous hunk" })

                    -- Register mapping group in which-key
                    local wk = require("which-key")
                    wk.register({ ["<leader>"] = { g = { name = " Gitsigns" } } })

                    -- Actions
                    map('n', '<leader>gs', gs.stage_hunk, { desc = "Stage hunk" })
                    map('n', '<leader>gr', gs.reset_hunk, { desc = "Reset hunk" })
                    map('v', '<leader>gs', function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                        { desc = "Stage hunk" })
                    map('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                        { desc = "Reset hunk" })

                    map('n', '<leader>gS', gs.stage_buffer, { desc = "Stage buffer" })
                    map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
                    map('n', '<leader>gR', gs.reset_buffer, { desc = "Reset buffer" })
                    map('n', '<leader>gp', gs.preview_hunk, { desc = "Preview hunk" })
                    map('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
                    map('n', '<leader>gl', gs.toggle_current_line_blame, { desc = "Toggle current line blame" })
                    map('n', '<leader>gt', gs.diffthis, { desc = "Diff this" })
                    map('n', '<leader>gT', function() gs.diffthis('~') end, { desc = "Diff this ~" })
                    map('n', '<leader>gd', gs.toggle_deleted, { desc = "Toggle deleted" })

                    -- Text object
                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            })
        end,
    },
}
