{ config, pkgs, ... }:
{
  # Start with the minimal environment, then add development-specific tools.
  imports = [
    ./minimal.nix
    ../../modules/home/code
    ../../modules/home/neovim
    # ../../modules/home/emacs
    ../../modules/home/ai
    ../../modules/home/direnv.nix
    ../../modules/home/lazydocker.nix
  ];

  home.packages = [ pkgs.nodejs ];
  home.sessionPath = [ "${config.xdg.dataHome}/npm/bin" ];
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm";
}
