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
    claudeCode = config.programs.claude-code.finalPackage;
  };
in
{
  imports = [ ../editor-tools ];
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
}
