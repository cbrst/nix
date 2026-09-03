{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";

  home.packages = [
    pkgs.bitwarden-desktop
    pkgs.bitwarden-cli
  ];

  programs.ssh = {
    enable = true;
    settings."*".IdentityAgent = "~/.bitwarden-ssh-agent.sock";
  };

  programs.firefox.profiles.default.extensions.packages = lib.mkIf config.programs.firefox.enable [
    pkgs.nur.repos.rycee.firefox-addons.bitwarden
  ];
}
