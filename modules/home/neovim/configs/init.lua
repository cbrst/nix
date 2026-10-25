-- ┌────────────────────────┐
-- │ Core editor setup      │
-- └────────────────────────┘
require("init6.config.globals").setup()
require("init6.options")
require("init6.keymap")
require("init6.autocmds")
require("init6.languages").setup()

-- ┌────────────────────────┐
-- │ Plugins and appearance │
-- └────────────────────────┘
require("init6.plugins").setup()

-- Apply the theme after every startup plugin has defined its highlight groups.
require("init6.config.theme").set_colorscheme()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
