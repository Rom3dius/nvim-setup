-- PACKER SETUP
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

function CheckBackspace()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.')[col]:match('%s') ~= nil
end

local packer_bootstrap = ensure_packer()
-- END PACKER SETUP

return require('packer').startup(function(use)
  -- ADD PLUGINS HERE
  use 'wbthomason/packer.nvim'
  use {'neoclide/coc.nvim', branch='release'}
  use 'tpope/vim-fugitive'
  use {
  "max397574/better-escape.nvim",
  config = function()
    require("better_escape").setup()
  end,
  }
  use {'Yggdroot/LeaderF', run=':LeaderfInstallCExtension'}
  use 'github/copilot.vim'
  use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use {
  'gelguy/wilder.nvim',
  config = function()
    wilder = require('wilder')
    wilder.setup({modes = {':', '/', '?'}})
  end,
  }
  use 'glepnir/dashboard-nvim'
  use {"EdenEast/nightfox.nvim"}
  use {'psf/black', branch='stable'}
  use 'skywind3000/asyncrun.vim'
  use {
	"windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }
  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}
  use('mrjones2014/smart-splits.nvim')
  use({
    "giusgad/pets.nvim",
    requires = {
      "edluffy/hologram.nvim",
      "MunifTanjim/nui.nvim",
    }
  })
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }
  use({
	"Pocco81/auto-save.nvim",
	config = function()
		 require("auto-save").setup {
    			enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
    			execution_message = {
			message = function() -- message to print on save
				return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
			end,
			dim = 0.18, -- dim the color of `message`
			cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
			},
    			trigger_events = {"InsertLeave"}, -- vim events that trigger auto-save. See :h events
			-- function that determines whether to save the current buffer or not
			-- return true: if buffer is ok to be saved
			-- return false: if it's not ok to be saved
			condition = function(buf)
			local fn = vim.fn
			local utils = require("auto-save.utils.data")
				if
					fn.getbufvar(buf, "&modifiable") == 1 and
					utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
					return true -- met condition(s), can save
				end
				return false -- can't save
			end,
    			write_all_buffers = false, -- write all buffers when the current one meets `condition`
  			debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
			callbacks = { -- functions to be executed at different intervals
			enabling = nil, -- ran when enabling auto-save
			disabling = nil, -- ran when disabling auto-save
			before_asserting_save = nil, -- ran before checking `condition`
			before_saving = nil, -- ran before doing the actual save
			after_saving = nil -- ran after doing the actual save
			}
	}
	end,
  })
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
  -- SETUP for COC
  -- Some servers have issues with backup files, see #649
  vim.opt.backup = false
  vim.opt.writebackup = false
  
  -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
  -- delays and poor user experience
  vim.opt.updatetime = 300
  
  -- Always show the signcolumn, otherwise it would shift the text each time
  -- diagnostics appeared/became resolved
  vim.opt.signcolumn = "yes"
  
  local keyset = vim.keymap.set
  -- Autocomplete
  function _G.check_back_space()
      local col = vim.fn.col('.') - 1
      return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
  end
  
  -- Use Tab for trigger completion with characters ahead and navigate
  -- NOTE: There's always a completion item selected by default, you may want to enable
  -- no select by setting `"suggest.noselect": true` in your configuration file
  -- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
  -- other plugins before putting this into your config
  local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
  keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
  keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
  
  -- Make <CR> to accept selected completion item or notify coc.nvim to format
  -- <C-g>u breaks current undo, please make your own choice
  keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
  
  -- Use <c-j> to trigger snippets
  keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
  -- Use <c-space> to trigger completion
  keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})
  
  -- Use `[g` and `]g` to navigate diagnostics
  -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
  keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
  keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})
  
  -- GoTo code navigation
  keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
  keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
  keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
  keyset("n", "gr", "<Plug>(coc-references)", {silent = true})


  -- Use K to show documentation in preview window
  function _G.show_docs()
      local cw = vim.fn.expand('<cword>')
      if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
      elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
      else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
      end
  end
  keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
  
  
  -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
  vim.api.nvim_create_augroup("CocGroup", {})
  vim.api.nvim_create_autocmd("CursorHold", {
      group = "CocGroup",
      command = "silent call CocActionAsync('highlight')",
      desc = "Highlight symbol under cursor on CursorHold"
  })
  
  
  -- Symbol renaming
  keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})
  
  
  -- Formatting selected code
  keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
  keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
  
  
  -- Setup formatexpr specified filetype(s)
  vim.api.nvim_create_autocmd("FileType", {
      group = "CocGroup",
      pattern = "typescript,json",
      command = "setl formatexpr=CocAction('formatSelected')",
      desc = "Setup formatexpr specified filetype(s)."
  })
  
  -- Update signature help on jump placeholder
  vim.api.nvim_create_autocmd("User", {
      group = "CocGroup",
      pattern = "CocJumpPlaceholder",
      command = "call CocActionAsync('showSignatureHelp')",
      desc = "Update signature help on jump placeholder"
  })
  
  -- Apply codeAction to the selected region
  -- Example: `<leader>aap` for current paragraph
  local opts = {silent = true, nowait = true}
  keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
  keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
  
  -- Remap keys for apply code actions at the cursor position.
  keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
  -- Remap keys for apply code actions affect whole buffer.
  keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
  -- Remap keys for applying codeActions to the current buffer
  keyset("n", "<leader>ac", "<Plug>(coc-codeaction)", opts)
  -- Apply the most preferred quickfix action on the current line.
  keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)
  
  -- Remap keys for apply refactor code actions.
  keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
  keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
  keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
  
  -- Run the Code Lens actions on the current line
  keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)
  
  
  -- Map function and class text objects
  -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
  keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
  keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
  keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
  keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
  keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
  keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
  keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
  keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)
  
  
  -- Remap <C-f> and <C-b> to scroll float windows/popups
  ---@diagnostic disable-next-line: redefined-local
  local opts = {silent = true, nowait = true, expr = true}
  keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
  keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
  keyset("i", "<C-f>",
         'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
  keyset("i", "<C-b>",
         'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
  keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
  keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
  
  
  -- Use CTRL-S for selections ranges
  -- Requires 'textDocument/selectionRange' support of language server
  keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
  keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
  
  
  -- Add `:Format` command to format current buffer
  vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
  
  -- " Add `:Fold` command to fold current buffer
  vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})
  
  -- Add `:OR` command for organize imports of the current buffer
  vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
  
  -- Add (Neo)Vim's native statusline support
  -- NOTE: Please see `:h coc-status` for integrations with external plugins that
  -- provide custom statusline: lightline.vim, vim-airline
  vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
  
  -- Mappings for CoCList
  -- code actions and coc stuff
  ---@diagnostic disable-next-line: redefined-local
  local opts = {silent = true, nowait = true}
  -- Show all diagnostics
  keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
  -- Manage extensions
  keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
  -- Show commands
  keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
  -- Find symbol of current document
  keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
  -- Search workspace symbols
  keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
  -- Do default action for next item
  keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
  -- Do default action for previous item
  keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
  -- Resume latest coc list
  keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)  -- SETUP MAPLEADER
  vim.g.mapleader = ","
  -- SMART SPLIT SETUP
  -- resizing splits
  -- amount defaults to 3 if not specified
  -- use absolute values, no + or -
  require('smart-splits').resize_up(amount)
  require('smart-splits').resize_down(amount)
  require('smart-splits').resize_left(amount)
  require('smart-splits').resize_right(amount)
  -- moving between splits
  -- pass same_row as a boolean to override the default
  -- for the move_cursor_same_row config option.
  -- See Configuration.
  require('smart-splits').move_cursor_up()
  require('smart-splits').move_cursor_down()
  require('smart-splits').move_cursor_left(same_row)
  require('smart-splits').move_cursor_right(same_row)
  -- persistent resize mode
  -- temporarily remap your configured resize keys to
  -- smart resize left, down, up, and right, respectively,
  -- press <ESC> to stop resize mode (unless you've set a different key in config)
  -- resize keys also accept a range, e.e. pressing `5j` will resize down 5 times the default_amount
  -- require('smart-splits').start_resize_mode()
  
  -- recommended mappings
  -- resizing splits
  vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
  vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
  vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
  vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)
  -- moving between splits
  vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
  vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
  vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
  vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right) 
  -- do a split
  vim.keymap.set('','<leader>h', ':split<CR>')
  vim.keymap.set('','<leader>v', ':vsplit<CR>')
  -- SETUP PETS
  require("pets").setup({
    -- your options here
  })
  -- SETUP TOGGLETERM
  require("toggleterm").setup()
  vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>', {noremap = true, silent = true})
  vim.keymap.set('', '<leader>tt', ':ToggleTerm<CR>')
  -- SETUP FILETREE 
  require('nvim-tree').setup({
	git = {
		ignore = false
	}
  })
  vim.keymap.set('', '<leader>ft', ':NvimTreeFocus<CR>')
  -- NIGHTFOX SETUP
  require('nightfox').setup({
    options = {
      -- Compiled file's destination location
      compile_path = vim.fn.stdpath("cache") .. "/nightfox",
      compile_file_suffix = "_compiled", -- Compiled file suffix
      transparent = false,     -- Disable setting background
      terminal_colors = true,  -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
      dim_inactive = false,    -- Non focused panes set to alternative background
      module_default = true,   -- Default enable value for modules
      colorblind = {
        enable = false,        -- Enable colorblind support
        simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
        severity = {
          protan = 0,          -- Severity [0,1] for protan (red)
          deutan = 0,          -- Severity [0,1] for deutan (green)
          tritan = 0,          -- Severity [0,1] for tritan (blue)
        },
      },
      styles = {               -- Style to be applied to different syntax groups
        comments = "NONE",     -- Value is any valid attr-list value `:help attr-list`
        conditionals = "NONE",
        constants = "NONE",
        functions = "NONE",
        keywords = "NONE",
        numbers = "NONE",
        operators = "NONE",
        strings = "NONE",
        types = "NONE",
        variables = "NONE",
      },
      inverse = {             -- Inverse highlight for different types
        match_paren = false,
        visual = false,
        search = false,
      },
      modules = {             -- List of various plugins and additional options
        -- ...
      },
    },
    palettes = {},
    specs = {},
    groups = {},
  })
  vim.cmd("colorscheme nightfox")
  vim.keymap.set('', '<leader>cn', ':<C-U>colorscheme nightfox<CR>')
  vim.keymap.set('', '<leader>cd', ':<C-U>colorscheme dawnfox<CR>')
  -- LEADERF SETUP
  vim.g['g:Lf_WindowPosition'] = 'popup'
  vim.keymap.set('', '<leader>ff', ':<C-U>Leaderf file --popup<CR>')
  vim.keymap.set('', '<leader>fg', ':<C-U>Leaderf rg --popup<CR>')
  vim.keymap.set('', '<leader>fh', ':<C-U>Leaderf help<CR>')
  -- SETUP COPILOT
  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-E>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  -- SETUP FUGITIVE
  --vim.keymap.set('', '<leader>gs', ':Git<CR>')
  ---- vim.keymap.set('<silent>', '<leader>gw', ':Gwrite<CR>')
  --vim.keymap.set('', '<leader>gc', ':Git commit<CR>')
  --vim.keymap.set('', '<leader>gd', ':Gdiffsplit<CR>')
  --vim.keymap.set('', '<leader>gp', ':Git pull<CR>')
  --vim.keymap.set('', '<leader>ge', ':Git push<CR>')
  -- SETUP ASYNCRUN // keybind for shell commands
  vim.keymap.set('', '<leader>r', ':AsyncRun -mode=term ')
  vim.keymap.set('', '<leader>e', ':! ')
  -- SETUP LUALINE
  require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "auto",
    -- component_separators = { left = "", right = "" },
    -- section_separators = { left = "", right = "" },
    section_separators = "",
    component_separators = "",
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = {
      "filename",
      {
        ime_state,
        color = {fg = 'black', bg = '#f46868'}
      },
      {
        spell,
        color = {fg = 'black', bg = '#a7c080'}
      },
    },
    lualine_x = {
      "encoding",
      {
        "fileformat",
        symbols = {
          unix = "unix",
          dos = "win",
          mac = "mac",
        },
      },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = {
      "location",
      {
        "diagnostics",
        sources = { "nvim_diagnostic" }
      },
      {
        trailing_space,
        color = "WarningMsg"
      },
      {
        mixed_indent,
        color = "WarningMsg"
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {'fugitive'},
  })
  -- DASHBOARD NVIM SETUP
  dashboard = require("dashboard")
  home = os.getenv('HOME')
  dashboard.custom_header={
  '',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⢄⢄⠢⡠⡀⢀⠄⡀⡀⠄⠄⠄⠄⠐⠡⠄⠉⠻⣻⣟⣿⣿⣄⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⢠⢣⠣⡎⡪⢂⠊⡜⣔⠰⡐⠠⠄⡾⠄⠈⠠⡁⡂⠄⠔⠸⣻⣿⣿⣯⢂⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⡀⠄⠄⠄⠄⠄⠄⠄⠐⢰⡱⣝⢕⡇⡪⢂⢊⢪⢎⢗⠕⢕⢠⣻⠄⠄⠄⠂⠢⠌⡀⠄⠨⢚⢿⣿⣧⢄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⡐⡈⠌⠄⠄⠄⠄⠄⠄⠄⡧⣟⢼⣕⢝⢬⠨⡪⡚⡺⡸⡌⡆⠜⣾⠄⠄⠄⠁⡐⠠⣐⠨⠄⠁⠹⡹⡻⣷⡕⢄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⢄⠇⠂⠄⠄⠄⠄⠄⠄⠄⢸⣻⣕⢗⠵⣍⣖⣕⡼⡼⣕⢭⢮⡆⠱⣽⡇⠄⠄⠂⠁⠄⢁⠢⡁⠄⠄⠐⠈⠺⢽⣳⣄⠄⠄',
  '⠄⠄⠄⠄⠄⢔⢕⢌⠄⠄⠄⠄⠄⢀⠄⠄⣾⢯⢳⠹⠪⡺⡺⣚⢜⣽⣮⣳⡻⡇⡙⣜⡇⠄⠄⢸⠄⠄⠂⡀⢠⠂⠄⢶⠊⢉⡁⠨⡒⠄⠄',
  '⠄⠄⠄⠄⡨⣪⣿⢰⠈⠄⠄⠄⡀⠄⠄⠄⣽⣵⢿⣸⢵⣫⣳⢅⠕⡗⣝⣼⣺⠇⡘⡲⠇⠄⠄⠨⠄⠐⢀⠐⠐⠡⢰⠁⠄⣴⣾⣷⣮⣇⠄',
  '⠄⠄⠄⠄⡮⣷⣿⠪⠄⠄⠄⠠⠄⠂⠠⠄⡿⡞⡇⡟⣺⣺⢷⣿⣱⢕⢵⢺⢼⡁⠪⣘⡇⠄⠄⢨⠄⠐⠄⠄⢀⠄⢸⠄⠄⣿⣿⣿⣿⣿⡆',
  '⠄⠄⠄⢸⣺⣿⣿⣇⠄⠄⠄⠄⢀⣤⣖⢯⣻⡑⢕⢭⢷⣻⣽⡾⣮⡳⡵⣕⣗⡇⠡⡣⣃⠄⠄⠸⠄⠄⠄⠄⠄⠄⠈⠄⠄⢻⣿⣿⣵⡿⣹',
  '⠄⠄⠄⢸⣿⣿⣟⣯⢄⢤⢲⣺⣻⣻⡺⡕⡔⡊⡎⡮⣿⣿⣽⡿⣿⣻⣼⣼⣺⡇⡀⢎⢨⢐⢄⡀⠄⢁⠠⠄⠄⠐⠄⠣⠄⠸⣿⣿⣯⣷⣿',
  '⠄⠄⠄⢸⣿⣿⣿⢽⠲⡑⢕⢵⢱⢪⡳⣕⢇⢕⡕⣟⣽⣽⣿⣿⣿⣿⣿⣿⣿⢗⢜⢜⢬⡳⣝⢸⣢⢀⠄⠄⠐⢀⠄⡀⠆⠄⠸⣿⣿⣿⣿',
  '⠄⠄⠄⢸⣿⣿⣿⢽⣝⢎⡪⡰⡢⡱⡝⡮⡪⡣⣫⢎⣿⣿⣿⣿⣿⣿⠟⠋⠄⢄⠄⠈⠑⠑⠭⡪⡪⢏⠗⡦⡀⠐⠄⠄⠈⠄⠄⠙⣿⣿⣿',
  '⠄⠄⠄⠘⣿⣿⣿⣿⡲⣝⢮⢪⢊⢎⢪⢺⠪⣝⢮⣯⢯⣟⡯⠷⠋⢀⣠⣶⣾⡿⠿⢀⣴⣖⢅⠪⠘⡌⡎⢍⣻⠠⠅⠄⠄⠈⠢⠄⠄⠙⠿',
  '⠄⠄⠄⠄⣿⣿⣿⣿⣽⢺⢍⢎⢎⢪⡪⡮⣪⣿⣞⡟⠛⠋⢁⣠⣶⣿⡿⠛⠋⢀⣤⢾⢿⣕⢇⠡⢁⢑⠪⡳⡏⠄⠄⠄⠄⠄⠄⢑⠤⢀⢠',
  '⠄⠄⠄⠄⢸⣿⣿⣿⣟⣮⡳⣭⢪⡣⡯⡮⠗⠋⠁⠄⠄⠈⠿⠟⠋⣁⣀⣴⣾⣿⣗⡯⡳⡕⡕⡕⡡⢂⠊⢮⠃⠄⠄⠄⠄⠄⢀⠐⠨⢁⠨',
  '⠄⠄⠄⠄⠈⢿⣿⣿⣿⠷⠯⠽⠐⠁⠁⢀⡀⣤⢖⣽⢿⣦⣶⣾⣿⣿⣿⣿⣿⣿⢎⠇⡪⣸⡪⡮⠊⠄⠌⠎⡄⠄⠄⠄⠄⠄⠄⡂⢁⠉⡀',
  '⠄⠄⠄⠄⠄⠈⠛⠚⠒⠵⣶⣶⣶⣶⢪⢃⢇⠏⡳⡕⣝⢽⡽⣻⣿⣿⣿⣿⡿⣺⠰⡱⢜⢮⡟⠁⠄⠄⠅⠅⢂⠐⠄⠐⢀⠄⠄⠄⠂⡁⠂',
  '⠄⠄⠄⠄⠄⠄⠄⠰⠄⠐⢒⣠⣿⣟⢖⠅⠆⢝⢸⡪⡗⡅⡯⣻⣺⢯⡷⡯⡏⡇⡅⡏⣯⡟⠄⠄⠄⠨⡊⢔⢁⠠⠄⠄⠄⠄⠄⢀⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠹⣿⣿⣿⣿⢿⢕⢇⢣⢸⢐⢇⢯⢪⢪⠢⡣⠣⢱⢑⢑⠰⡸⡸⡇⠁⠄⠄⠠⡱⠨⢘⠄⠂⡀⠂⠄⠄⠄⠄⠈⠂⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⢻⣿⣿⣿⣟⣝⢔⢅⠸⡘⢌⠮⡨⡪⠨⡂⠅⡑⡠⢂⢇⢇⢿⠁⠄⢀⠠⠨⡘⢌⡐⡈⠄⠄⠠⠄⠄⠄⠄⠄⠄⠁',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠹⣿⣿⣿⣯⢢⢊⢌⢂⠢⠑⠔⢌⡂⢎⠔⢔⢌⠎⡎⡮⡃⢀⠐⡐⠨⡐⠌⠄⡑⠄⢂⠐⢀⠄⠄⠈⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠙⣿⣿⣿⣯⠂⡀⠔⢔⠡⡹⠰⡑⡅⡕⡱⠰⡑⡜⣜⡅⡢⡈⡢⡑⡢⠁⠰⠄⠨⢀⠐⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠻⢿⣿⣷⣢⢱⠡⡊⢌⠌⡪⢨⢘⠜⡌⢆⢕⢢⢇⢆⢪⢢⡑⡅⢁⡖⡄⠄⠄⠄⢀⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠛⢿⣿⣵⡝⣜⢐⠕⢌⠢⡑⢌⠌⠆⠅⠑⠑⠑⠝⢜⠌⠠⢯⡚⡜⢕⢄⠄⠁⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠙⢿⣷⡣⣇⠃⠅⠁⠈⡠⡠⡔⠜⠜⣿⣗⡖⡦⣰⢹⢸⢸⢸⡘⠌⠄⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠋⢍⣠⡤⡆⣎⢇⣇⢧⡳⡍⡆⢿⣯⢯⣞⡮⣗⣝⢎⠇⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠁⣿⣿⣎⢦⠣⠳⠑⠓⠑⠃⠩⠉⠈⠈⠉⠄⠁⠉⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⡿⡞⠁⠄⠄⢀⠐⢐⠠⠈⡌⠌⠂⡁⠌⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⢂⢂⢀⠡⠄⣈⠠⢄⠡⠒⠈⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄',
  '⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠢⠠⠊⠨⠐⠈⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄',
  ''}

  dashboard.custom_center = {
    {
      icon = "  ",
      desc = "Find  File                              ",
      action = "Leaderf file --popup",
      shortcut = "<Leader> f f",
    },
    {
      icon = "  ",
      desc = "Recently opened files                   ",
      action = "Leaderf mru --popup",
      shortcut = "<Leader> f r",
    },
    {
      icon = "  ",
      desc = "Project grep                            ",
      action = "Leaderf rg --popup",
      shortcut = "<Leader> f g",
    },
    {
      icon = "  ",
      desc = "Open Nvim config                        ",
      action = "tabnew $MYVIMRC | tcd %:p:h",
      shortcut = "<Leader> e v",
    },
    {
      icon = "  ",
      desc = "New file                                ",
      action = "enew",
      shortcut = "e           ",
    },
    {
      icon = "  ",
      desc = "Quit Nvim                               ",
      -- desc = "Quit Nvim                               ",
      action = "qa",
      shortcut = "q           "
    }
  }
  -- END DASHBOARD SETUP
  -- MISC SETUP
  vim.cmd("set clipboard=unnamedplus") -- COPY TO SYSTEM CLIPBOARD
  vim.cmd("set number") -- ENABLE LINE NUMBERS
  vim.cmd("set noshowmode") -- DISABLE MODE INDICATOR
  vim.cmd("set termguicolors") -- ENABLE TRUE COLOR
  vim.cmd("NvimTreeToggle")
  -- END MISC SETUP
end)


