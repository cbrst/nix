;;; lsp-servers.el --- Explicit server definitions -*- lexical-binding: t; -*-
(defconst config-lsp-servers
  '((config-bash (sh-mode bash-ts-mode) ("bash-language-server" "start"))
    (config-zsh (zsh-mode) ("zshcs"))
    (config-python (python-mode python-ts-mode) ("zuban" "server"))
    (config-lua (lua-mode lua-ts-mode) ("lua-language-server"))
    (config-nix (nix-mode nix-ts-mode) ("nil"))
    (config-php (php-mode php-ts-mode) ("phpactor" "language-server"))
    (config-markdown (markdown-mode gfm-mode) ("rumdl" "server"))
    (config-sass (scss-mode sass-mode css-mode css-ts-mode less-css-mode)
                 ("some-sass-language-server" "--stdio"))
    (config-json (js-json-mode json-mode json-ts-mode)
                 ("vscode-json-language-server" "--stdio"))
    (config-yaml (yaml-mode yaml-ts-mode) ("yaml-language-server" "--stdio"))
    (config-typescript (js-mode js-ts-mode js-jsx-mode typescript-ts-mode tsx-ts-mode)
                       ("typescript-language-server" "--stdio")))
  "Server ID, exact major modes, command, and optional initialization options.
Exact modes prevent Bash from attaching to Zsh and TypeScript to JSON.")
