{
  config,
  lib,
  inputs,
  pkgs,
  settings,
  ...
}:
let
  # Plugins, tools and configuration are defined once in `spec.nix`.
  spec = import ./spec.nix {
    inherit
      pkgs
      lib
      inputs
      settings
      ;
    inherit (config.editor.neovim) features;
    claudeCode = config.programs.claude-code.finalPackage;
  };
in
{
  # `editor.neovim.features.*`: per-host switches for AI, debugging,
  # Treesitter grammars, and language tooling.
  imports = [ ./options.nix ];

  # Install Neovim for the current Home Manager user.
  programs.neovim = {
    enable = true;
    inherit (spec) package extraPackages plugins;
    defaultEditor = true;
    # Keep optional language-provider defaults explicit across Home Manager
    # releases. Enable them later only if your Neovim configuration needs them.
    withPython3 = false;
    withRuby = false;
  };

  # `source` makes Home Manager link this repository file into the user's
  # configuration directory instead of copying and maintaining it manually.
  xdg.configFile."nvim/init.lua".source = spec.configDir + "/init.lua";
  xdg.configFile."nvim/lua".source = spec.configDir + "/lua";
  xdg.configFile."nvim/colors".source = spec.configDir + "/colors";
  # oxfmt fallback for projects without their own configuration.
  xdg.configFile."nvim/oxfmtrc.json".source = spec.configDir + "/oxfmtrc.json";

  # Fallback formatter settings; project-local configuration wins.
  xdg.configFile."mago.toml".text = ''
    [formatter]
    tab-width = 2
    single-quote = false
  '';
  xdg.configFile."rumdl/rumdl.toml".text = ''
    [MD013]
    line-length = 80
    reflow = true
    reflow-mode = "normalize"
    code-blocks = false
    tables = false
    headings = false
    math-blocks = false
  '';
}
